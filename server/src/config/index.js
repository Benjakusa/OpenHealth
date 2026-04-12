require('dotenv').config();

module.exports = {
  port: process.env.PORT || 3000,
  nodeEnv: process.env.NODE_ENV || 'development',
  
  database: {
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 5432,
    name: process.env.DB_NAME || 'openhealth',
    username: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD || 'postgres',
    pool: {
      max: 10,
      min: 0,
      acquire: 30000,
      idle: 10000
    }
  },

  jwt: {
    secret: process.env.JWT_SECRET || 'openhealth-secret-key-change-in-production',
    expiresIn: '24h',
    refreshExpiresIn: '7d'
  },

  sync: {
    enabled: true,
    interval: 30000,
    retryAttempts: 3,
    retryDelay: 5000
  },

  pagination: {
    defaultLimit: 50,
    maxLimit: 100
  },

  packages: {
    DAWA: {
      name: 'Dawa',
      price: 4999,
      users: 3,
      devices: 1,
      storage: 5 * 1024 * 1024 * 1024
    },
    AFYA: {
      name: 'Afya',
      price: 19999,
      users: 15,
      devices: 5,
      storage: 50 * 1024 * 1024 * 1024
    },
    HOSPITALI: {
      name: 'Hospitali',
      price: 59999,
      users: Infinity,
      devices: Infinity,
      storage: 500 * 1024 * 1024 * 1024
    }
  },

  billing: {
    gracePeriodDays: 7,
    suspensionDays: 30,
    dataRetentionDays: 90
  },

  mpesa: {
    sandbox: process.env.MPESA_SANDBOX === 'true',
    consumerKey: process.env.MPESA_CONSUMER_KEY,
    consumerSecret: process.env.MPESA_CONSUMER_SECRET,
    shortCode: process.env.MPESA_SHORTCODE,
    paybillNumber: process.env.MPESA_PAYBILL,
    passkey: process.env.MPESA_PASSKEY,
    callbackUrl: process.env.MPESA_CALLBACK_URL || 'https://your-domain.com/api/v1/payments/mpesa',
    transactionLimit: 150000,
    initiatorName: process.env.MPESA_INITIATOR_NAME,
    securityCredential: process.env.MPESA_SECURITY_CREDENTIAL
  },

  sha: {
    baseUrl: process.env.SHA_BASE_URL || 'https://api.sha.go.ke',
    clientId: process.env.SHA_CLIENT_ID,
    clientSecret: process.env.SHA_CLIENT_SECRET,
    apiKey: process.env.SHA_API_KEY,
    facilityCode: process.env.SHA_FACILITY_CODE,
    webhookSecret: process.env.SHA_WEBHOOK_SECRET
  },

  notifications: {
    smsProvider: process.env.SMS_PROVIDER || 'twilio',
    emailProvider: process.env.EMAIL_PROVIDER || 'smtp',
    twilio: {
      accountSid: process.env.TWILIO_ACCOUNT_SID,
      authToken: process.env.TWILIO_AUTH_TOKEN,
      fromNumber: process.env.TWILIO_FROM_NUMBER
    },
    smtp: {
      host: process.env.SMTP_HOST,
      port: parseInt(process.env.SMTP_PORT) || 587,
      secure: process.env.SMTP_SECURE === 'true',
      user: process.env.SMTP_USER,
      password: process.env.SMTP_PASSWORD,
      from: process.env.SMTP_FROM
    },
    africasTalking: {
      apiKey: process.env.AFRICAS_TALKING_API_KEY,
      username: process.env.AFRICAS_TALKING_USERNAME
    }
  }
};
