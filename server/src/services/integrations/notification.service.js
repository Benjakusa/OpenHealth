const axios = require('axios');
const config = require('../../config');

class NotificationService {
  constructor() {
    this.smsProvider = config.notifications?.smsProvider || process.env.SMS_PROVIDER || 'twilio';
    this.emailProvider = config.notifications?.emailProvider || process.env.EMAIL_PROVIDER || 'smtp';
    
    this.twilio = {
      accountSid: config.notifications?.twilio?.accountSid || process.env.TWILIO_ACCOUNT_SID,
      authToken: config.notifications?.twilio?.authToken || process.env.TWILIO_AUTH_TOKEN,
      fromNumber: config.notifications?.twilio?.fromNumber || process.env.TWILIO_FROM_NUMBER
    };

    this.smtp = {
      host: config.notifications?.smtp?.host || process.env.SMTP_HOST,
      port: config.notifications?.smtp?.port || process.env.SMTP_PORT || 587,
      secure: config.notifications?.smtp?.secure || process.env.SMTP_SECURE === 'true',
      user: config.notifications?.smtp?.user || process.env.SMTP_USER,
      password: config.notifications?.smtp?.password || process.env.SMTP_PASSWORD,
      from: config.notifications?.smtp?.from || process.env.SMTP_FROM || 'noreply@openhealth.com'
    };

    this.africasTalking = {
      apiKey: config.notifications?.africasTalking?.apiKey || process.env.AFRICAS_TALKING_API_KEY,
      username: config.notifications?.africasTalking?.username || process.env.AFRICAS_TALKING_USERNAME
    };

    this.emailEnabled = !!(this.smtp.host && this.smtp.user);
    this.smsEnabled = !!(this.twilio.accountSid || this.africasTalking.apiKey);
  }

  formatPhoneNumber(phone) {
    if (!phone) return null;
    let cleaned = phone.replace(/\D/g, '');
    if (cleaned.startsWith('0')) {
      cleaned = '+254' + cleaned.substring(1);
    }
    if (!cleaned.startsWith('+')) {
      cleaned = '+' + cleaned;
    }
    return cleaned;
  }

  async sendSMS(phoneNumber, message) {
    if (!this.smsEnabled) {
      console.log('SMS not configured, would send:', { phoneNumber, message });
      return { success: true, simulated: true };
    }

    const formattedPhone = this.formatPhoneNumber(phoneNumber);

    if (this.smsProvider === 'twilio') {
      return this.sendTwilioSMS(formattedPhone, message);
    } else if (this.smsProvider === 'africas_talking') {
      return this.sendAfricastalkingSMS(formattedPhone, message);
    }

    throw new Error(`Unknown SMS provider: ${this.smsProvider}`);
  }

  async sendTwilioSMS(to, message) {
    try {
      const client = require('twilio')(this.twilio.accountSid, this.twilio.authToken);
      const result = await client.messages.create({
        body: message,
        from: this.twilio.fromNumber,
        to: to
      });

      return {
        success: true,
        messageId: result.sid,
        status: result.status
      };
    } catch (error) {
      console.error('Twilio SMS error:', error.message);
      throw new Error(`SMS send failed: ${error.message}`);
    }
  }

  async sendAfricastalkingSMS(to, message) {
    try {
      const response = await axios.post(
        'https://api.africastalking.com/version1/messaging',
        {
          username: this.africasTalking.username,
          to: to.replace('+', ''),
          message: message
        },
        {
          headers: {
            'apiKey': this.africasTalking.apiKey,
            'Content-Type': 'application/x-www-form-urlencoded'
          }
        }
      );

      const data = response.data;
      if (data.SMSMessageData && data.SMSMessageData.Recipients) {
        const recipient = data.SMSMessageData.Recipients[0];
        return {
          success: recipient.status === 'Success',
          messageId: recipient.messageId,
          cost: recipient.cost
        };
      }

      return { success: true, response: data };
    } catch (error) {
      console.error('Africa\'s Talking SMS error:', error.response?.data || error.message);
      throw new Error(`SMS send failed: ${error.message}`);
    }
  }

  async sendEmail(to, subject, htmlContent, textContent) {
    if (!this.emailEnabled) {
      console.log('Email not configured, would send:', { to, subject });
      return { success: true, simulated: true };
    }

    try {
      const nodemailer = require('nodemailer');
      const transporter = nodemailer.createTransport({
        host: this.smtp.host,
        port: this.smtp.port,
        secure: this.smtp.secure,
        auth: {
          user: this.smtp.user,
          pass: this.smtp.password
        }
      });

      const result = await transporter.sendMail({
        from: this.smtp.from,
        to: Array.isArray(to) ? to : [to],
        subject: subject,
        text: textContent || htmlContent.replace(/<[^>]*>/g, ''),
        html: htmlContent
      });

      return {
        success: true,
        messageId: result.messageId,
        response: result.response
      };
    } catch (error) {
      console.error('Email send error:', error.message);
      throw new Error(`Email send failed: ${error.message}`);
    }
  }

  async sendBulkSMS(phoneNumbers, message) {
    const results = [];
    for (const phone of phoneNumbers) {
      try {
        const result = await this.sendSMS(phone, message);
        results.push({ phone, ...result });
      } catch (error) {
        results.push({ phone, success: false, error: error.message });
      }
    }
    return results;
  }

  async sendPatientRegistrationSMS(patient) {
    const message = `Karibu ${patient.firstName}! You have been registered at ${patient.facilityName || 'our facility'}. Your Patient ID is ${patient.patientNumber}. For assistance, call ${patient.facilityPhone || 'us'}.`;
    return this.sendSMS(patient.phone, message);
  }

  async sendAppointmentReminder(patient, appointment) {
    const message = `Reminder: You have an appointment on ${this.formatDateTime(appointment.dateTime || appointment.startTime)} with Dr. ${appointment.doctorName || 'your doctor'} at ${appointment.location || 'our facility'}. Reply CANCEL to cancel.`;
    return this.sendSMS(patient.phone, message);
  }

  async sendLabResultsNotification(patient, testName) {
    const message = `Your lab results for ${testName} are ready. Please visit ${patient.facilityName || 'our facility'} to collect your results or view them on your patient portal.`;
    return this.sendSMS(patient.phone, message);
  }

  async sendPrescriptionReady(patient, prescriptionId) {
    const message = `Your prescription (Ref: ${prescriptionId}) is ready for pickup at ${patient.facilityName || 'our pharmacy'}.`;
    return this.sendSMS(patient.phone, message);
  }

  async sendPaymentConfirmation(patient, amount, reference) {
    const message = `Payment of KES ${amount.toLocaleString()} received. Ref: ${reference}. Thank you for choosing ${patient.facilityName || 'us'}.`;
    return this.sendSMS(patient.phone, message);
  }

  async sendMpesaPrompt(patient, amount, reference) {
    const message = `Please check your phone and enter your M-Pesa PIN to complete payment of KES ${amount.toLocaleString()}. Ref: ${reference}. This expires in 5 minutes.`;
    return this.sendSMS(patient.phone, message);
  }

  async sendMpesaSuccess(patient, amount, reference) {
    const message = `Payment of KES ${amount.toLocaleString()} received. Ref: ${reference}. Transaction complete. Thank you!`;
    return this.sendSMS(patient.phone, message);
  }

  async sendInsuranceClaimConfirmation(patient, claimReference) {
    const message = `Your insurance claim Ref: ${claimReference} has been submitted successfully. You will be notified of the outcome.`;
    return this.sendSMS(patient.phone, message);
  }

  async sendAdmissionNotification(patient, admission) {
    const message = `Dear ${patient.firstName}, you have been admitted to ${admission.wardName}. Bed: ${admission.bedNumber}. Please report to reception. For queries, call ${patient.facilityPhone || 'us'}.`;
    return this.sendSMS(patient.phone, message);
  }

  async sendDischargeNotification(patient, dischargeDate) {
    const message = `Dear ${patient.firstName}, you have been discharged. Please settle your bill at the billing desk before leaving. Wishing you a speedy recovery!`;
    return this.sendSMS(patient.phone, message);
  }

  async sendBirthNotification(patient, babyDetails) {
    const message = `Congratulations! A baby ${babyDetails.gender || 'has been born'} was registered under your name. Birth Record: ${babyDetails.recordNumber}.`;
    return this.sendSMS(patient.phone, message);
  }

  async sendDeathNotification(relativePhone, patientName, recordNumber) {
    const message = `We regret to inform you of the passing of ${patientName}. Death Record: ${recordNumber}. For assistance, please contact our facility.`;
    return this.sendSMS(relativePhone, message);
  }

  async sendInsuranceVerification(patient, result) {
    if (result.valid) {
      const message = `Insurance verification successful. Member: ${result.memberName}, Cover: ${result.coverageType}.`;
      return this.sendSMS(patient.phone, message);
    } else {
      const message = `Insurance verification failed. Please check your details or contact ${patient.facilityPhone || 'our office'}.`;
      return this.sendSMS(patient.phone, message);
    }
  }

  async sendReferralNotification(patient, referral) {
    const message = `You have been referred to ${referral.facilityName}. Please carry your referral letter and ID. For emergencies, call ${patient.facilityPhone || 'us'}.`;
    return this.sendSMS(patient.phone, message);
  }

  async sendLowStockAlert(pharmacist, item) {
    const message = `Low stock alert: ${item.name} (${item.currentStock} units remaining). Reorder level: ${item.reorderLevel}. Please restock.`;
    return this.sendSMS(pharmacist.phone, message);
  }

  async sendVaccinationReminder(patient, vaccineName, dueDate) {
    const message = `Reminder: ${vaccineName} vaccination is due on ${this.formatDate(dueDate)}. Visit ${patient.facilityName || 'our facility'} for immunization.`;
    return this.sendSMS(patient.phone, message);
  }

  async sendAppointmentCancellation(patient, appointment) {
    const message = `Your appointment on ${this.formatDateTime(appointment.dateTime || appointment.startTime)} with Dr. ${appointment.doctorName} has been cancelled. Please call to reschedule.`;
    return this.sendSMS(patient.phone, message);
  }

  async sendWardTransferNotification(patient, transfer) {
    const message = `You have been transferred from ${transfer.fromWard} to ${transfer.toWard}, Bed ${transfer.toBed}. Please cooperate with staff.`;
    return this.sendSMS(patient.phone, message);
  }

  async sendBirthCertificateReady(patient, certificateNumber) {
    const message = `Birth certificate for baby is ready. Certificate No: ${certificateNumber}. Collect from registry or visit ${patient.facilityName || 'our facility'}.`;
    return this.sendSMS(patient.phone, message);
  }

  async sendDeathCertificateReady(relativePhone, certificateNumber) {
    const message = `Death certificate is ready for collection. Certificate No: ${certificateNumber}. Visit registry with ID.`;
    return this.sendSMS(relativePhone, message);
  }

  formatDate(date) {
    if (!date) return '';
    const d = new Date(date);
    return d.toLocaleDateString('en-KE', { day: 'numeric', month: 'long', year: 'numeric' });
  }

  formatDateTime(date) {
    if (!date) return '';
    const d = new Date(date);
    return d.toLocaleString('en-KE', { 
      day: 'numeric', 
      month: 'short', 
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  }

  buildEmailTemplate(templateName, data) {
    const templates = {
      welcome: `
        <h1>Welcome to OpenHealth</h1>
        <p>Dear ${data.firstName},</p>
        <p>Welcome to our healthcare facility. You have been successfully registered.</p>
        <p><strong>Patient ID:</strong> ${data.patientNumber}</p>
        <p><strong>Registration Date:</strong> ${this.formatDate(data.registrationDate)}</p>
        <p>If you have any questions, please don't hesitate to contact us.</p>
        <p>Best regards,<br/>The Healthcare Team</p>
      `,
      appointment: `
        <h1>Appointment Confirmation</h1>
        <p>Dear ${data.patientName},</p>
        <p>Your appointment has been confirmed:</p>
        <ul>
          <li><strong>Date:</strong> ${this.formatDateTime(data.dateTime)}</li>
          <li><strong>Doctor:</strong> Dr. ${data.doctorName}</li>
          <li><strong>Department:</strong> ${data.department}</li>
          <li><strong>Location:</strong> ${data.location}</li>
        </ul>
        <p>Please arrive 15 minutes early with your ID.</p>
        <p>To cancel or reschedule, call us or reply to this email.</p>
      `,
      labResults: `
        <h1>Lab Results Available</h1>
        <p>Dear ${data.patientName},</p>
        <p>Your lab results are now available:</p>
        <p><strong>Test:</strong> ${data.testName}</p>
        <p><strong>Results Date:</strong> ${this.formatDate(data.resultDate)}</p>
        <p>Please schedule a follow-up appointment with your doctor to discuss the results.</p>
        <p>You can also view your results in the patient portal.</p>
      `,
      prescription: `
        <h1>Prescription Ready</h1>
        <p>Dear ${data.patientName},</p>
        <p>Your prescription is ready for pickup:</p>
        <p><strong>Prescription ID:</strong> ${data.prescriptionId}</p>
        <p><strong>Date:</strong> ${this.formatDate(data.date)}</p>
        <p>Please collect your medication from the pharmacy within 7 days.</p>
        <p>Follow the dosage instructions carefully.</p>
      `,
      billing: `
        <h1>Billing Statement</h1>
        <p>Dear ${data.patientName},</p>
        <p>Here is your billing statement:</p>
        <p><strong>Invoice Number:</strong> ${data.invoiceNumber}</p>
        <p><strong>Date:</strong> ${this.formatDate(data.date)}</p>
        <p><strong>Amount Due:</strong> KES ${data.amountDue?.toLocaleString()}</p>
        <p><strong>Status:</strong> ${data.status}</p>
        <p>Please settle your bill at the billing desk or via M-Pesa.</p>
        <p>M-Pesa Paybill: ${data.paybillNumber}<br/>Account: ${data.accountNumber}</p>
      `,
      admission: `
        <h1>Admission Confirmation</h1>
        <p>Dear ${data.patientName},</p>
        <p>You have been admitted to our facility:</p>
        <ul>
          <li><strong>Admission Date:</strong> ${this.formatDateTime(data.admissionDate)}</li>
          <li><strong>Ward:</strong> ${data.wardName}</li>
          <li><strong>Bed:</strong> ${data.bedNumber}</li>
          <li><strong>Attending Physician:</strong> Dr. ${data.attendingPhysician}</li>
        </ul>
        <p>Please report to the ward within the specified time.</p>
        <p>For any queries, contact our admissions desk.</p>
      `,
      discharge: `
        <h1>Discharge Summary</h1>
        <p>Dear ${data.patientName},</p>
        <p>You have been discharged:</p>
        <ul>
          <li><strong>Discharge Date:</strong> ${this.formatDateTime(data.dischargeDate)}</li>
          <li><strong>Diagnosis:</strong> ${data.diagnosis}</li>
          <li><strong>Follow-up:</strong> ${data.followUpDate ? this.formatDate(data.followUpDate) : 'As advised'}</li>
        </ul>
        <p><strong>Discharge Instructions:</strong></p>
        <p>${data.instructions || 'Please follow your prescribed treatment plan.'}</p>
        <p>Please settle your bill at the billing desk before leaving.</p>
        <p>Get well soon!</p>
      `,
      insuranceClaim: `
        <h1>Insurance Claim Submitted</h1>
        <p>Dear ${data.patientName},</p>
        <p>Your insurance claim has been submitted:</p>
        <p><strong>Claim Reference:</strong> ${data.claimReference}</p>
        <p><strong>Date:</strong> ${this.formatDate(data.submissionDate)}</p>
        <p><strong>Total Amount:</strong> KES ${data.totalAmount?.toLocaleString()}</p>
        <p>You will be notified once the claim has been processed.</p>
        <p>Please settle any co-payment or non-covered amounts at the billing desk.</p>
      `,
      receipt: `
        <h1>Payment Receipt</h1>
        <p>Dear ${data.patientName},</p>
        <p>Payment received:</p>
        <p><strong>Receipt Number:</strong> ${data.receiptNumber}</p>
        <p><strong>Date:</strong> ${this.formatDateTime(data.paymentDate)}</p>
        <p><strong>Amount Paid:</strong> KES ${data.amountPaid?.toLocaleString()}</p>
        <p><strong>Payment Method:</strong> ${data.paymentMethod}</p>
        <p><strong>Reference:</strong> ${data.reference}</p>
        <p><strong>Balance:</strong> KES ${data.balance?.toLocaleString()}</p>
        <p>Thank you for your payment!</p>
      `
    };

    return templates[templateName] || `<p>${data.message || 'No content'}</p>`;
  }
}

module.exports = new NotificationService();
