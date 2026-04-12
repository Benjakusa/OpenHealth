const axios = require('axios');
const crypto = require('crypto');
const config = require('../../config');

const BASE_URL = 'https://api.safaricom.co.ke';
const LIVE_BASE_URL = 'https://api.safaricom.co.ke';
const SANDBOX_BASE_URL = 'https://sandbox.safaricom.co.ke';

class MpesaService {
  constructor() {
    this.baseUrl = config.mpesa?.sandbox ? SANDBOX_BASE_URL : LIVE_BASE_URL;
    this.clientKey = config.mpesa?.consumerKey || process.env.MPESA_CONSUMER_KEY;
    this.clientSecret = config.mpesa?.consumerSecret || process.env.MPESA_CONSUMER_SECRET;
    this.shortCode = config.mpesa?.shortCode || process.env.MPESA_SHORTCODE;
    this.paybillNumber = config.mpesa?.paybillNumber || process.env.MPESA_PAYBILL;
    this.passkey = config.mpesa?.passkey || process.env.MPESA_PASSKEY;
    this.callbackUrl = config.mpesa?.callbackUrl || process.env.MPESA_CALLBACK_URL;
    this.transactionLimit = config.mpesa?.transactionLimit || 150000;
  }

  async getAuthToken() {
    const auth = Buffer.from(`${this.clientKey}:${this.clientSecret}`).toString('base64');
    
    try {
      const response = await axios.get(`${this.baseUrl}/oauth/v1/generate?grant_type=client_credentials`, {
        headers: {
          'Authorization': `Basic ${auth}`
        }
      });
      return response.data.access_token;
    } catch (error) {
      console.error('M-Pesa auth error:', error.response?.data || error.message);
      throw new Error('Failed to obtain M-Pesa auth token');
    }
  }

  async stkPush(phoneNumber, amount, accountReference, transactionDesc, tenantId) {
    const token = await this.getAuthToken();
    const timestamp = this.formatTimestamp();
    const password = this.generatePassword(timestamp);
    
    const formattedPhone = this.formatPhoneNumber(phoneNumber);
    
    const requestBody = {
      BusinessShortCode: parseInt(this.shortCode),
      Password: password,
      Timestamp: timestamp,
      TransactionType: 'CustomerPayBillOnline',
      Amount: Math.round(amount),
      PartyA: formattedPhone,
      PartyB: parseInt(this.paybillNumber || this.shortCode),
      PhoneNumber: formattedPhone,
      CallBackURL: `${this.callbackUrl}/stk/callback`,
      AccountReference: accountReference.substring(0, 20),
      TransactionDesc: transactionDesc.substring(0, 100)
    };

    try {
      const response = await axios.post(
        `${this.baseUrl}/mpesa/stkpush/v1/processrequest`,
        requestBody,
        {
          headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json'
          }
        }
      );
      
      return {
        success: true,
        checkoutRequestId: response.data.CheckoutRequestID,
        merchantRequestId: response.data.MerchantRequestID,
        responseCode: response.data.ResponseCode,
        responseDescription: response.data.ResponseDescription,
        customerMessage: response.data.CustomerMessage
      };
    } catch (error) {
      console.error('M-Pesa STK Push error:', error.response?.data || error.message);
      throw {
        success: false,
        errorCode: error.response?.data?.errorCode || 'STK_PUSH_FAILED',
        errorMessage: error.response?.data?.errorMessage || 'Failed to initiate M-Pesa payment'
      };
    }
  }

  async stkPushStatus(checkoutRequestId) {
    const token = await this.getAuthToken();
    const timestamp = this.formatTimestamp();
    const password = this.generatePassword(timestamp);

    const requestBody = {
      BusinessShortCode: parseInt(this.shortCode),
      Password: password,
      Timestamp: timestamp,
      CheckoutRequestID: checkoutRequestId
    };

    try {
      const response = await axios.post(
        `${this.baseUrl}/mpesa/stkpush/v1/query`,
        requestBody,
        {
          headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json'
          }
        }
      );

      return {
        success: true,
        responseCode: response.data.ResponseCode,
        responseDescription: response.data.ResponseDescription,
        merchantRequestId: response.data.MerchantRequestID,
        checkoutRequestId: response.data.CheckoutRequestID,
        resultCode: response.data.ResultCode,
        resultDesc: response.data.ResultDesc
      };
    } catch (error) {
      console.error('M-Pesa STK Status query error:', error.response?.data || error.message);
      throw new Error('Failed to query transaction status');
    }
  }

  async b2cPayment(phoneNumber, amount, remarks, occasion, tenantId) {
    const token = await this.getAuthToken();
    const initiatorName = config.mpesa?.initiatorName || process.env.MPESA_INITIATOR_NAME;
    const securityCredential = config.mpesa?.securityCredential || process.env.MPESA_SECURITY_CREDENTIAL;
    
    const formattedPhone = this.formatPhoneNumber(phoneNumber);

    const requestBody = {
      InitiatorName: initiatorName,
      SecurityCredential: securityCredential,
      CommandID: 'BusinessPayment',
      Amount: Math.round(amount),
      PartyA: parseInt(this.shortCode),
      PartyB: formattedPhone,
      Remarks: remarks.substring(0, 100),
      QueueTimeOutURL: `${this.callbackUrl}/b2c/timeout`,
      ResultURL: `${this.callbackUrl}/b2c/result`,
      Occasion: occasion?.substring(0, 100) || ''
    };

    try {
      const response = await axios.post(
        `${this.baseUrl}/mpesa/b2c/v1/paymentrequest`,
        requestBody,
        {
          headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json'
          }
        }
      );

      return {
        success: true,
        conversationId: response.data.ConversationID,
        originatorConversationId: response.data.OriginatorConversationID,
        responseCode: response.data.ResponseCode,
        responseDescription: response.data.ResponseDescription
      };
    } catch (error) {
      console.error('M-Pesa B2C error:', error.response?.data || error.message);
      throw new Error('Failed to process B2C payment');
    }
  }

  async reverseTransaction(transactionId, amount, receiverParty, remarks, occasion) {
    const token = await this.getAuthToken();
    const initiatorName = config.mpesa?.initiatorName || process.env.MPESA_INITIATOR_NAME;
    const securityCredential = config.mpesa?.securityCredential || process.env.MPESA_SECURITY_CREDENTIAL;

    const requestBody = {
      CommandID: 'TransactionReversal',
      TransactionID: transactionId,
      Amount: Math.round(amount),
      ReceiverParty: parseInt(receiverParty),
      ReverserParty: parseInt(this.shortCode),
      ResultURL: `${this.callbackUrl}/reversal/result`,
      QueueTimeOutURL: `${this.callbackUrl}/reversal/timeout`,
      Remarks: remarks?.substring(0, 100) || '',
      Occasion: occasion?.substring(0, 100) || ''
    };

    try {
      const response = await axios.post(
        `${this.baseUrl}/mpesa/reversal/v1/request`,
        requestBody,
        {
          headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json'
          }
        }
      );

      return {
        success: true,
        responseCode: response.data.ResponseCode,
        responseDescription: response.data.ResponseDescription
      };
    } catch (error) {
      console.error('M-Pesa reversal error:', error.response?.data || error.message);
      throw new Error('Failed to reverse transaction');
    }
  }

  async registerUrls() {
    const token = await this.getAuthToken();

    const requestBody = {
      ShortCode: parseInt(this.shortCode),
      ResponseType: 'Completed',
      ConfirmationURL: `${this.callbackUrl}/c2b/confirmation`,
      ValidationURL: `${this.callbackUrl}/c2b/validation`
    };

    try {
      const response = await axios.post(
        `${this.baseUrl}/mpesa/c2b/v1/registerurl`,
        requestBody,
        {
          headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json'
          }
        }
      );

      return {
        success: true,
        responseDescription: response.data.ResponseDescription
      };
    } catch (error) {
      console.error('M-Pesa URL registration error:', error.response?.data || error.message);
      throw new Error('Failed to register URLs');
    }
  }

  formatPhoneNumber(phone) {
    if (!phone) return null;
    let cleaned = phone.replace(/\D/g, '');
    if (cleaned.startsWith('0')) {
      cleaned = '254' + cleaned.substring(1);
    }
    if (!cleaned.startsWith('254')) {
      cleaned = '254' + cleaned;
    }
    return cleaned;
  }

  formatTimestamp() {
    const now = new Date();
    const year = now.getFullYear();
    const month = String(now.getMonth() + 1).padStart(2, '0');
    const day = String(now.getDate()).padStart(2, '0');
    const hours = String(now.getHours()).padStart(2, '0');
    const minutes = String(now.getMinutes()).padStart(2, '0');
    const seconds = String(now.getSeconds()).padStart(2, '0');
    return `${year}${month}${day}${hours}${minutes}${seconds}`;
  }

  generatePassword(timestamp) {
    const passwordString = `${this.shortCode}${this.passkey}${timestamp}`;
    return Buffer.from(passwordString).toString('base64');
  }

  validateAmount(amount) {
    return amount > 0 && amount <= this.transactionLimit;
  }

  generateTransactionId() {
    return 'TX' + Date.now() + crypto.randomBytes(4).toString('hex').toUpperCase();
  }
}

module.exports = new MpesaService();
