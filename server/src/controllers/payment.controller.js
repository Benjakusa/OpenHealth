const { Op } = require('sequelize');
const db = require('../database');
const mpesaService = require('../services/integrations/mpesa.service');
const notificationService = require('../services/integrations/notification.service');

const Payment = db.Payment;
const Invoice = db.Invoice;
const InvoiceItem = db.InvoiceItem;
const Patient = db.Patient;
const Tenant = db.Tenant;
const User = db.User;

class PaymentController {
  async initiateMpesaPayment(req, res) {
    try {
      const { invoiceId, phoneNumber, amount } = req.body;
      const tenantId = req.user?.tenantId;

      let invoice;
      let paymentAmount;

      if (invoiceId) {
        invoice = await Invoice.findOne({
          where: { id: invoiceId, tenantId, status: 'pending' },
          include: [{
            model: Patient,
            as: 'patient'
          }]
        });

        if (!invoice) {
          return res.status(404).json({ error: 'Invoice not found or already paid' });
        }

        const paid = await Payment.sum('amount', {
          where: { invoiceId, status: 'completed' }
        });
        paymentAmount = invoice.totalAmount - (paid || 0);
      } else {
        paymentAmount = amount;
      }

      if (!paymentAmount || paymentAmount <= 0) {
        return res.status(400).json({ error: 'Invalid payment amount' });
      }

      if (paymentAmount > 150000) {
        return res.status(400).json({ error: 'Amount exceeds M-Pesa transaction limit' });
      }

      const accountReference = invoice 
        ? `INV-${invoice.invoiceNumber}` 
        : `PAY-${Date.now()}`;

      const transactionDesc = invoice 
        ? `Payment for Invoice ${invoice.invoiceNumber}` 
        : `Bill Payment`;

      const mpesaResult = await mpesaService.stkPush(
        phoneNumber,
        paymentAmount,
        accountReference,
        transactionDesc,
        tenantId
      );

      const payment = await Payment.create({
        tenantId,
        invoiceId: invoice?.id,
        patientId: invoice?.patientId,
        amount: paymentAmount,
        paymentMethod: 'mpesa',
        reference: mpesaResult.checkoutRequestId,
        externalReference: mpesaResult.merchantRequestId,
        status: 'pending',
        phoneNumber,
        description: transactionDesc,
        createdBy: req.user?.id
      });

      res.json({
        success: true,
        paymentId: payment.id,
        checkoutRequestId: mpesaResult.checkoutRequestId,
        merchantRequestId: mpesaResult.merchantRequestId,
        amount: paymentAmount,
        accountReference
      });
    } catch (error) {
      console.error('M-Pesa payment initiation error:', error);
      res.status(500).json({ 
        error: 'Failed to initiate payment',
        details: error.errorMessage || error.message
      });
    }
  }

  async mpesaCallback(req, res) {
    try {
      const { Body } = req.body;
      const resultCode = Body?.stkCallback?.ResultCode;
      const resultDesc = Body?.stkCallback?.ResultDesc;
      const checkoutRequestId = Body?.stkCallback?.CheckoutRequestID;
      const merchantRequestId = Body?.stkCallback?.MerchantRequestID;

      let payment = await Payment.findOne({
        where: { reference: checkoutRequestId },
        include: [
          { model: Patient, as: 'patient' },
          { model: Invoice, as: 'invoice', include: [{ model: Tenant, as: 'tenant' }] }
        ]
      });

      if (!payment) {
        console.error('Payment not found for callback:', checkoutRequestId);
        return res.json({ ResultCode: 0, ResultDesc: 'Accepted' });
      }

      if (resultCode === 0) {
        const callbackMetadata = Body?.stkCallback?.CallbackMetadata?.Item || [];
        const amount = callbackMetadata.find(i => i.Name === 'Amount')?.Value;
        const receiptNumber = callbackMetadata.find(i => i.Name === 'MpesaReceiptNumber')?.Value;
        const transactionDate = callbackMetadata.find(i => i.Name === 'TransactionDate')?.Value;
        const phoneNumber = callbackMetadata.find(i => i.Name === 'PhoneNumber')?.Value;

        payment.amount = amount || payment.amount;
        payment.receiptNumber = receiptNumber;
        payment.status = 'completed';
        payment.completedAt = new Date();
        payment.transactionDate = transactionDate;
        payment.rawResponse = JSON.stringify(req.body);
        await payment.save();

        if (payment.invoiceId) {
          const invoice = payment.invoice;
          const totalPaid = await Payment.sum('amount', {
            where: { invoiceId: invoice.id, status: 'completed' }
          });

          if (totalPaid >= invoice.totalAmount) {
            invoice.status = 'paid';
          } else {
            invoice.status = 'partial';
            invoice.paidAmount = totalPaid;
            invoice.balance = invoice.totalAmount - totalPaid;
          }
          await invoice.save();
        }

        if (payment.patient?.phone && payment.patient?.tenantId) {
          const tenant = payment.invoice?.tenant || payment.tenant;
          notificationService.sendMpesaSuccess(
            { ...payment.patient.toJSON(), facilityName: tenant?.name },
            payment.amount,
            receiptNumber || payment.reference
          ).catch(err => console.error('SMS notification error:', err));
        }

        if (payment.invoice?.patient) {
          notificationService.sendPaymentConfirmation(
            { ...payment.invoice.patient.toJSON(), facilityName: payment.tenant?.name },
            payment.amount,
            receiptNumber || payment.reference
          ).catch(err => console.error('Email notification error:', err));
        }

        req.io?.to(`tenant:${payment.tenantId}`).emit('payment:completed', {
          paymentId: payment.id,
          invoiceId: payment.invoiceId,
          amount: payment.amount,
          status: 'completed'
        });

      } else {
        payment.status = 'failed';
        payment.failureReason = resultDesc;
        payment.rawResponse = JSON.stringify(req.body);
        await payment.save();
      }

      res.json({ ResultCode: 0, ResultDesc: 'Accepted' });
    } catch (error) {
      console.error('M-Pesa callback error:', error);
      res.status(500).json({ error: 'Callback processing failed' });
    }
  }

  async checkMpesaStatus(req, res) {
    try {
      const { checkoutRequestId } = req.params;

      const payment = await Payment.findOne({
        where: { reference: checkoutRequestId }
      });

      if (!payment) {
        return res.status(404).json({ error: 'Payment not found' });
      }

      if (payment.status !== 'pending') {
        return res.json({
          status: payment.status,
          receiptNumber: payment.receiptNumber,
          completedAt: payment.completedAt
        });
      }

      const statusResult = await mpesaService.stkPushStatus(checkoutRequestId);

      if (statusResult.resultCode === 0) {
        payment.status = 'completed';
        payment.completedAt = new Date();
        await payment.save();

        if (payment.invoiceId) {
          const invoice = await Invoice.findByPk(payment.invoiceId);
          const totalPaid = await Payment.sum('amount', {
            where: { invoiceId: invoice.id, status: 'completed' }
          });

          if (totalPaid >= invoice.totalAmount) {
            invoice.status = 'paid';
          } else {
            invoice.status = 'partial';
            invoice.paidAmount = totalPaid;
            invoice.balance = invoice.totalAmount - totalPaid;
          }
          await invoice.save();
        }
      } else if (statusResult.resultCode === 1032 || statusResult.resultCode === '1032') {
        payment.status = 'cancelled';
        payment.failureReason = 'Customer cancelled';
        await payment.save();
      } else if (statusResult.resultCode === 'OTHER') {
        payment.status = 'pending';
        await payment.save();
      }

      res.json({
        status: payment.status,
        resultCode: statusResult.resultCode,
        resultDesc: statusResult.resultDesc,
        receiptNumber: payment.receiptNumber,
        completedAt: payment.completedAt
      });
    } catch (error) {
      console.error('M-Pesa status check error:', error);
      res.status(500).json({ error: 'Failed to check payment status' });
    }
  }

  async processRefund(req, res) {
    try {
      const { paymentId, amount, reason } = req.body;
      const tenantId = req.user?.tenantId;

      const originalPayment = await Payment.findOne({
        where: { id: paymentId, tenantId, status: 'completed' },
        include: [{ model: Patient, as: 'patient' }]
      });

      if (!originalPayment) {
        return res.status(404).json({ error: 'Original payment not found' });
      }

      const refundAmount = amount || originalPayment.amount;

      if (refundAmount > originalPayment.amount) {
        return res.status(400).json({ error: 'Refund amount exceeds original payment' });
      }

      const refund = await Payment.create({
        tenantId,
        invoiceId: originalPayment.invoiceId,
        patientId: originalPayment.patientId,
        amount: -refundAmount,
        paymentMethod: originalPayment.paymentMethod,
        reference: `REF-${Date.now()}`,
        status: 'pending',
        type: 'refund',
        description: `Refund for ${originalPayment.receiptNumber || originalPayment.reference}`,
        createdBy: req.user?.id
      });

      if (originalPayment.paymentMethod === 'mpesa') {
        const mpesaResult = await mpesaService.b2cPayment(
          originalPayment.phoneNumber || originalPayment.patient?.phone,
          refundAmount,
          `Refund: ${reason || 'As requested'}`,
          `Refund-${refund.reference}`,
          tenantId
        );

        refund.externalReference = mpesaResult.conversationId;
        refund.status = 'completed';
        refund.completedAt = new Date();
        await refund.save();

        if (originalPayment.invoiceId) {
          const invoice = await Invoice.findByPk(originalPayment.invoiceId);
          invoice.paidAmount = Math.max(0, (invoice.paidAmount || 0) - refundAmount);
          invoice.balance = invoice.totalAmount - invoice.paidAmount;
          invoice.status = invoice.balance <= 0 ? 'paid' : 'partial';
          await invoice.save();
        }
      }

      res.json({
        success: true,
        refundId: refund.id,
        status: refund.status,
        amount: refundAmount
      });
    } catch (error) {
      console.error('Refund processing error:', error);
      res.status(500).json({ error: 'Failed to process refund' });
    }
  }

  async recordCashPayment(req, res) {
    try {
      const { invoiceId, amount, collectedBy, notes } = req.body;
      const tenantId = req.user?.tenantId;

      const invoice = await Invoice.findOne({
        where: { id: invoiceId, tenantId },
        include: [{ model: Patient, as: 'patient' }]
      });

      if (!invoice) {
        return res.status(404).json({ error: 'Invoice not found' });
      }

      const payment = await Payment.create({
        tenantId,
        invoiceId: invoice.id,
        patientId: invoice.patientId,
        amount,
        paymentMethod: 'cash',
        reference: `CSH-${Date.now()}`,
        status: 'completed',
        collectedBy,
        description: 'Cash payment',
        notes,
        completedAt: new Date(),
        createdBy: req.user?.id
      });

      const totalPaid = await Payment.sum('amount', {
        where: { invoiceId: invoice.id, status: 'completed' }
      });

      if (totalPaid >= invoice.totalAmount) {
        invoice.status = 'paid';
      } else {
        invoice.status = 'partial';
      }
      invoice.paidAmount = totalPaid;
      invoice.balance = invoice.totalAmount - totalPaid;
      await invoice.save();

      res.json({
        success: true,
        paymentId: payment.id,
        receiptNumber: payment.reference,
        totalPaid,
        balance: invoice.balance,
        status: invoice.status
      });
    } catch (error) {
      console.error('Cash payment error:', error);
      res.status(500).json({ error: 'Failed to record payment' });
    }
  }

  async recordCardPayment(req, res) {
    try {
      const { invoiceId, amount, cardType, lastFourDigits, authorizationCode, collectedBy, notes } = req.body;
      const tenantId = req.user?.tenantId;

      const invoice = await Invoice.findOne({
        where: { id: invoiceId, tenantId },
        include: [{ model: Patient, as: 'patient' }]
      });

      if (!invoice) {
        return res.status(404).json({ error: 'Invoice not found' });
      }

      const payment = await Payment.create({
        tenantId,
        invoiceId: invoice.id,
        patientId: invoice.patientId,
        amount,
        paymentMethod: 'card',
        reference: authorizationCode || `CRD-${Date.now()}`,
        status: 'completed',
        collectedBy,
        cardType,
        lastFourDigits,
        description: `Card payment (${cardType} ***${lastFourDigits})`,
        notes,
        completedAt: new Date(),
        createdBy: req.user?.id
      });

      const totalPaid = await Payment.sum('amount', {
        where: { invoiceId: invoice.id, status: 'completed' }
      });

      if (totalPaid >= invoice.totalAmount) {
        invoice.status = 'paid';
      } else {
        invoice.status = 'partial';
      }
      invoice.paidAmount = totalPaid;
      invoice.balance = invoice.totalAmount - totalPaid;
      await invoice.save();

      res.json({
        success: true,
        paymentId: payment.id,
        receiptNumber: payment.reference,
        totalPaid,
        balance: invoice.balance
      });
    } catch (error) {
      console.error('Card payment error:', error);
      res.status(500).json({ error: 'Failed to record payment' });
    }
  }

  async recordInsurancePayment(req, res) {
    try {
      const { invoiceId, amount, insuranceScheme, claimReference, collectedBy, notes } = req.body;
      const tenantId = req.user?.tenantId;

      const invoice = await Invoice.findOne({
        where: { id: invoiceId, tenantId }
      });

      if (!invoice) {
        return res.status(404).json({ error: 'Invoice not found' });
      }

      const payment = await Payment.create({
        tenantId,
        invoiceId: invoice.id,
        patientId: invoice.patientId,
        amount,
        paymentMethod: 'insurance',
        reference: claimReference || `INS-${Date.now()}`,
        status: 'completed',
        collectedBy,
        description: `Insurance payment (${insuranceScheme})`,
        notes,
        completedAt: new Date(),
        createdBy: req.user?.id
      });

      const totalPaid = await Payment.sum('amount', {
        where: { invoiceId: invoice.id, status: 'completed' }
      });

      if (totalPaid >= invoice.totalAmount) {
        invoice.status = 'paid';
      } else {
        invoice.status = 'partial';
      }
      invoice.paidAmount = totalPaid;
      invoice.balance = invoice.totalAmount - totalPaid;
      await invoice.save();

      res.json({
        success: true,
        paymentId: payment.id,
        totalPaid,
        balance: invoice.balance
      });
    } catch (error) {
      console.error('Insurance payment error:', error);
      res.status(500).json({ error: 'Failed to record payment' });
    }
  }

  async recordBankTransfer(req, res) {
    try {
      const { invoiceId, amount, bankName, transactionReference, transferDate, collectedBy, notes } = req.body;
      const tenantId = req.user?.tenantId;

      const invoice = await Invoice.findOne({
        where: { id: invoiceId, tenantId }
      });

      if (!invoice) {
        return res.status(404).json({ error: 'Invoice not found' });
      }

      const payment = await Payment.create({
        tenantId,
        invoiceId: invoice.id,
        patientId: invoice.patientId,
        amount,
        paymentMethod: 'bank_transfer',
        reference: transactionReference || `BNK-${Date.now()}`,
        status: 'pending',
        collectedBy,
        description: `Bank transfer via ${bankName}`,
        notes,
        transferDate,
        createdBy: req.user?.id
      });

      if (transferDate && new Date(transferDate) <= new Date()) {
        payment.status = 'completed';
        payment.completedAt = new Date();

        const totalPaid = await Payment.sum('amount', {
          where: { invoiceId: invoice.id, status: 'completed' }
        });

        if (totalPaid >= invoice.totalAmount) {
          invoice.status = 'paid';
        } else {
          invoice.status = 'partial';
        }
        invoice.paidAmount = totalPaid;
        invoice.balance = invoice.totalAmount - totalPaid;
        await invoice.save();
      }

      await payment.save();

      res.json({
        success: true,
        paymentId: payment.id,
        status: payment.status
      });
    } catch (error) {
      console.error('Bank transfer error:', error);
      res.status(500).json({ error: 'Failed to record transfer' });
    }
  }

  async getPayments(req, res) {
    try {
      const { invoiceId, patientId, status, paymentMethod, startDate, endDate, page = 1, limit = 50 } = req.query;
      const tenantId = req.user?.tenantId;

      const where = { tenantId };
      if (invoiceId) where.invoiceId = invoiceId;
      if (patientId) where.patientId = patientId;
      if (status) where.status = status;
      if (paymentMethod) where.paymentMethod = paymentMethod;
      if (startDate || endDate) {
        where.createdAt = {};
        if (startDate) where.createdAt[Op.gte] = new Date(startDate);
        if (endDate) where.createdAt[Op.lte] = new Date(endDate + 'T23:59:59');
      }

      const { rows: payments, count } = await Payment.findAndCountAll({
        where,
        include: [
          { model: Patient, as: 'patient', attributes: ['id', 'patientNumber', 'firstName', 'lastName', 'phone'] },
          { model: Invoice, as: 'invoice', attributes: ['id', 'invoiceNumber', 'totalAmount', 'status'] }
        ],
        order: [['createdAt', 'DESC']],
        limit: parseInt(limit),
        offset: (parseInt(page) - 1) * parseInt(limit)
      });

      res.json({
        payments,
        pagination: {
          total: count,
          page: parseInt(page),
          limit: parseInt(limit),
          pages: Math.ceil(count / parseInt(limit))
        }
      });
    } catch (error) {
      console.error('Get payments error:', error);
      res.status(500).json({ error: 'Failed to fetch payments' });
    }
  }

  async getPaymentById(req, res) {
    try {
      const { id } = req.params;
      const tenantId = req.user?.tenantId;

      const payment = await Payment.findOne({
        where: { id, tenantId },
        include: [
          { model: Patient, as: 'patient' },
          { model: Invoice, as: 'invoice' },
          { model: User, as: 'creator', attributes: ['id', 'firstName', 'lastName'] }
        ]
      });

      if (!payment) {
        return res.status(404).json({ error: 'Payment not found' });
      }

      res.json(payment);
    } catch (error) {
      console.error('Get payment error:', error);
      res.status(500).json({ error: 'Failed to fetch payment' });
    }
  }

  async reversePayment(req, res) {
    try {
      const { id } = req.params;
      const { reason } = req.body;
      const tenantId = req.user?.tenantId;

      const payment = await Payment.findOne({
        where: { id, tenantId, status: 'completed' }
      });

      if (!payment) {
        return res.status(404).json({ error: 'Payment not found' });
      }

      if (payment.type === 'refund') {
        return res.status(400).json({ error: 'Cannot reverse a refund' });
      }

      const reversedPayment = await Payment.create({
        tenantId: payment.tenantId,
        invoiceId: payment.invoiceId,
        patientId: payment.patientId,
        amount: -payment.amount,
        paymentMethod: payment.paymentMethod,
        reference: `REV-${payment.reference}`,
        status: 'completed',
        description: `Reversal of ${payment.reference}: ${reason || 'No reason provided'}`,
        type: 'reversal',
        completedAt: new Date(),
        createdBy: req.user?.id
      });

      if (payment.invoiceId) {
        const invoice = await Invoice.findByPk(payment.invoiceId);
        const totalPaid = await Payment.sum('amount', {
          where: { invoiceId: invoice.id, status: 'completed' }
        });

        invoice.paidAmount = totalPaid;
        invoice.balance = invoice.totalAmount - totalPaid;
        invoice.status = invoice.balance <= 0 ? 'paid' : 'partial';
        await invoice.save();
      }

      res.json({
        success: true,
        originalPayment: payment.id,
        reversedPayment: reversedPayment.id
      });
    } catch (error) {
      console.error('Payment reversal error:', error);
      res.status(500).json({ error: 'Failed to reverse payment' });
    }
  }

  async getPaymentStats(req, res) {
    try {
      const tenantId = req.user?.tenantId;
      const { startDate, endDate } = req.query;

      const where = { tenantId, status: 'completed', type: { [Op.ne]: 'refund' }, amount: { [Op.gt]: 0 } };
      if (startDate || endDate) {
        where.completedAt = {};
        if (startDate) where.completedAt[Op.gte] = new Date(startDate);
        if (endDate) where.completedAt[Op.lte] = new Date(endDate + 'T23:59:59');
      }

      const totalCollection = await Payment.sum('amount', { where });
      
      const byMethod = await Payment.findAll({
        where: { ...where, paymentMethod: { [Op.ne]: null } },
        attributes: [
          'paymentMethod',
          [db.sequelize.fn('SUM', db.sequelize.col('amount')), 'total'],
          [db.sequelize.fn('COUNT', db.sequelize.col('id')), 'count']
        ],
        group: ['paymentMethod'],
        raw: true
      });

      const refunds = await Payment.sum('amount', {
        where: { tenantId, status: 'completed', type: 'refund' }
      });

      const pendingPayments = await Payment.count({
        where: { tenantId, status: 'pending' }
      });

      res.json({
        totalCollection: totalCollection || 0,
        refunds: Math.abs(refunds || 0),
        netCollection: (totalCollection || 0) - Math.abs(refunds || 0),
        pendingPayments,
        byMethod: byMethod.map(m => ({
          method: m.paymentMethod,
          total: parseFloat(m.total) || 0,
          count: parseInt(m.count) || 0
        }))
      });
    } catch (error) {
      console.error('Payment stats error:', error);
      res.status(500).json({ error: 'Failed to fetch payment stats' });
    }
  }
}

module.exports = new PaymentController();
