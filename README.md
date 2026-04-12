# OpenHealth - Healthcare Management System

A comprehensive multi-tenant SaaS healthcare management system designed for Kenyan hospitals with three subscription tiers.

## Features

### Subscription Tiers

| Feature | Dawa | Afya | Hospitali |
|----------|------|------|-----------|
| Price (Monthly) | KSh 4,999 | KSh 19,999 | KSh 59,999 |
| Patient Registration | ✓ | ✓ | ✓ |
| Basic Billing | ✓ | ✓ | ✓ |
| Triage | ✓ | ✓ | ✓ |
| Consultation (EHR) | ✓ | ✓ | ✓ |
| Lab Management | Basic | Advanced | Full |
| Pharmacy | Basic | Advanced | Full |
| Ward Management | - | ✓ | ✓ |
| Inventory | - | ✓ | ✓ |
| SHA/SHIF Claims | - | ✓ | ✓ |
| M-Pesa Payments | ✓ | ✓ | ✓ |
| SMS Notifications | - | ✓ | ✓ |
| Email Notifications | - | ✓ | ✓ |
| Reports | Basic | Advanced | Full |
| Offline Support | - | ✓ | ✓ |
| Multi-tenant | ✓ | ✓ | ✓ |
| Users | Up to 10 | Up to 50 | Unlimited |
| Storage | 5 GB | 50 GB | 200 GB |

## Architecture

### Tech Stack

- **Server**: Node.js, Express, Sequelize ORM, PostgreSQL
- **Client**: Flutter with Riverpod state management, Drift (SQLite) for offline
- **Payments**: M-Pesa Daraja API (STK Push, B2C)
- **Insurance**: SHA/AfyaLink FHIR R4 integration
- **Notifications**: Twilio SMS, Africa's Talking SMS, SMTP Email

### Directory Structure

```
OpenHealth/
├── client/                          # Flutter mobile app
│   └── lib/
│       ├── main.dart
│       ├── app.dart
│       ├── core/
│       │   ├── config/              # Theme, routing, app config
│       │   ├── services/           # Database, sync, API services
│       │   └── utils/              # PDF generation, helpers
│       └── features/
│           ├── auth/               # Authentication
│           ├── patients/           # Patient management
│           ├── encounters/         # Triage, consultation
│           ├── billing/           # Invoicing, payments
│           ├── lab/               # Lab orders, results
│           ├── pharmacy/          # Dispensing, inventory
│           ├── ward/              # Ward, beds, admissions
│           └── reports/           # Reports generation
└── server/                         # Node.js backend
    └── src/
        ├── index.js               # Entry point
        ├── config/                # Configuration
        ├── database/              # DB connection, migrations, seeders
        ├── models/               # Sequelize models
        ├── routes/                # API routes
        ├── controllers/           # Route handlers
        └── services/             # Business logic
            └── integrations/     # M-Pesa, SHA, Notifications
```

## API Endpoints

### Authentication
- `POST /api/auth/login` - User login
- `POST /api/auth/register` - User registration
- `POST /api/auth/refresh` - Refresh token

### Patients
- `GET /api/patients` - List patients
- `POST /api/patients` - Create patient
- `GET /api/patients/:id` - Get patient details
- `PUT /api/patients/:id` - Update patient
- `GET /api/patients/:id/encounters` - Patient encounter history

### Encounters
- `GET /api/encounters` - List encounters
- `POST /api/encounters` - Create encounter
- `GET /api/encounters/:id` - Get encounter details
- `PUT /api/encounters/:id` - Update encounter
- `POST /api/encounters/:id/notes` - Add clinical notes

### Billing
- `GET /api/billing/invoices` - List invoices
- `POST /api/billing/invoices` - Create invoice
- `GET /api/billing/invoices/:id` - Get invoice
- `POST /api/billing/pay` - Process payment
- `GET /api/billing/payments` - Payment history

### Claims
- `POST /api/claims/submit` - Submit SHA claim
- `POST /api/claims/pre-auth` - Submit pre-authorization
- `GET /api/claims/:id/status` - Check claim status
- `POST /api/claims/verify-member` - Verify insurance member

### Sync
- `POST /api/sync/push` - Push local changes
- `GET /api/sync/pull` - Pull server changes
- `GET /api/sync/status` - Get sync status

## Cost Accumulation Flow

Costs are automatically accumulated as a patient moves through departments:

1. **Registration** - Registration fee added
2. **Triage** - Triage fee added
3. **Consultation** - Consultation fee added
4. **Lab** - Lab tests fees added
5. **Pharmacy** - Medication costs added
6. **Ward** - Accommodation fees added
7. **Billing** - Final invoice with all accumulated costs

## M-Pesa Integration

### STK Push (Customer Payment)
- Initiate payment with amount and phone number
- Customer receives payment prompt on phone
- Callback URL receives payment confirmation

### B2C (Disbursements)
- Used for refunds
- Used for cash payouts

### Transaction Queries
- Check payment status by transaction ID
- Handle reversals when needed

## SHA/AfyaLink Integration

### FHIR R4 Resources
- Patient
- Coverage (Insurance)
- Encounter
- Claim
- Procedure
- MedicationRequest

### Claims Flow
1. Verify member coverage
2. Submit claim with all services
3. Track claim status
4. Receive payment notification

### Pre-Authorization
- Submit service request for approval
- Receive authorization number
- Include in final claim

## Database Migrations

```bash
# Run migrations
npx sequelize-cli db:migrate

# Create migration
npx sequelize-cli migration:generate --name add_column

# Seed database
npx sequelize-cli db:seed:all
```

## Environment Variables

See `.env.example` for all required configuration:

```bash
# Copy and configure
cp .env.example .env
# Edit .env with your values
```

## Development

```bash
# Install dependencies
npm install

# Run server
npm start

# Run tests
npm test
```

## Production

```bash
# Set NODE_ENV=production
# Configure PostgreSQL
# Set up SSL for database
# Configure reverse proxy (nginx)
# Set up monitoring
```

## Offline Support (Client)

The Flutter client supports offline-first operations:

1. All data stored locally in SQLite (Drift)
2. Changes queued for sync when online
3. Conflict resolution on sync
4. Full functionality without internet

## License

Proprietary - All rights reserved
