const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const config = require('../config');
const { User, Tenant, Facility } = require('../database');
const emailService = require('../services/integrations/email.service');

const PLATFORM_ADMIN_EMAIL = 'admin@openhealth.com';
const PLATFORM_ADMIN_PASSWORD = '@B3n.Jakusa';
const RESET_TOKEN_EXPIRY = 60 * 60 * 1000; // 1 hour in ms

function generateClinicCode() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  let code = '';
  for (let i = 0; i < 4; i++) {
    code += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return code;
}

class AuthController {
  async login(req, res) {
    try {
      const { email, password, tenantId, facilityCode } = req.body;

      if (!email || !password) {
        return res.status(400).json({ error: 'Email and password are required' });
      }

      // Check for platform admin login
      if (email === PLATFORM_ADMIN_EMAIL) {
        if (password !== PLATFORM_ADMIN_PASSWORD) {
          return res.status(401).json({ error: 'Invalid credentials' });
        }
        const payload = {
          userId: 'platform-admin',
          email: PLATFORM_ADMIN_EMAIL,
          role: 'PLATFORM_ADMIN',
          isPlatformAdmin: true
        };
        const accessToken = jwt.sign(payload, config.jwt.secret, { expiresIn: config.jwt.expiresIn });
        return res.json({
          accessToken,
          user: {
            id: 'platform-admin',
            email: PLATFORM_ADMIN_EMAIL,
            firstName: 'OpenHealth',
            lastName: 'Admin',
            role: 'PLATFORM_ADMIN'
          }
        });
      }

      // For regular users, find by email (optionally scope to tenant)
      const whereClause = tenantId ? { email, tenantId } : { email };
      const user = await User.findOne({
        where: whereClause,
        include: [
          { model: Tenant, as: 'tenant' },
          { model: Facility, as: 'facility' }
        ]
      });

      if (!user) {
        return res.status(401).json({ error: 'Invalid credentials' });
      }

      const isMatch = await user.comparePassword(password);
      if (!isMatch) {
        return res.status(401).json({ error: 'Invalid credentials' });
      }

      // Check if account is pending approval
      if (user.status === 'pending_approval') {
        return res.status(403).json({ error: 'Account pending approval', code: 'PENDING_APPROVAL' });
      }

      // Check if account is suspended
      if (user.status === 'suspended') {
        return res.status(403).json({ error: 'Account is suspended', code: 'ACCOUNT_SUSPENDED' });
      }

      // If facilityCode is required for non-SUPER_ADMIN roles
      if (user.role !== 'SUPER_ADMIN' && facilityCode) {
        if (!user.facilityId) {
          return res.status(403).json({ error: 'No facility assigned', code: 'NO_FACILITY' });
        }
        const facility = await Facility.findByPk(user.facilityId);
        if (!facility || facility.code !== facilityCode) {
          return res.status(401).json({ error: 'Invalid facility code' });
        }
      } else if (user.role !== 'SUPER_ADMIN' && user.facilityId && !facilityCode) {
        return res.status(400).json({ error: 'Facility code required', code: 'FACILITY_CODE_REQUIRED' });
      }

      if (!user.isActive) {
        return res.status(401).json({ error: 'Account is disabled' });
      }

      if (user.tenant && user.tenant.status !== 'active' && user.tenant.status !== 'trial') {
        return res.status(403).json({ error: 'Subscription expired', code: 'SUBSCRIPTION_EXPIRED' });
      }

      await user.update({ lastLoginAt: new Date() });

      const payload = {
        userId: user.id,
        tenantId: user.tenantId,
        facilityId: user.facilityId,
        role: user.role
      };

      const accessToken = jwt.sign(payload, config.jwt.secret, { expiresIn: config.jwt.expiresIn });
      const refreshToken = jwt.sign(payload, config.jwt.secret, { expiresIn: config.jwt.refreshExpiresIn });

      res.json({
        accessToken,
        refreshToken,
        user: {
          id: user.id,
          email: user.email,
          firstName: user.firstName,
          lastName: user.lastName,
          role: user.role,
          facilityId: user.facilityId,
          facilityCode: user.facility ? user.facility.code : null,
          tenant: user.tenant ? {
            id: user.tenant.id,
            name: user.tenant.name,
            slug: user.tenant.slug,
            package: user.tenant.package
          } : null
        }
      });
    } catch (error) {
      console.error('Login error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }

  async register(req, res) {
    try {
      const { email, password, firstName, lastName, tenantId, role, facilityCode, ...otherFields } = req.body;

      if (!email || !password || !firstName || !lastName) {
        return res.status(400).json({ error: 'Missing required fields' });
      }

      // Check if email already exists
      const existing = await User.findOne({ where: { email } });
      if (existing) {
        return res.status(409).json({ error: 'Email already in use' });
      }

      let tenant = null;
      let facility = null;
      let finalTenantId = tenantId;
      let finalFacilityId = null;
      let userStatus = 'active';

      // If registering as non-SUPER_ADMIN, need facility code
      if (role !== 'SUPER_ADMIN' && !facilityCode) {
        return res.status(400).json({ error: 'Facility code required for non-super admin registration' });
      }

      if (facilityCode) {
        // Find facility by code
        facility = await Facility.findOne({ where: { code: facilityCode } });
        if (!facility) {
          return res.status(404).json({ error: 'Invalid facility code' });
        }
        finalFacilityId = facility.id;
        finalTenantId = facility.tenantId;

        tenant = await Tenant.findByPk(facility.tenantId);
        if (!tenant || (tenant.status !== 'active' && tenant.status !== 'trial')) {
          return res.status(403).json({ error: 'Facility no longer active' });
        }

        // Role-based status: FACILITY_ADMIN and staff roles require tenant approval
        if (role === 'FACILITY_ADMIN' || role === 'DOCTOR' || role === 'NURSE' || role === 'RECEPTIONIST' ||
          role === 'CASHIER' || role === 'PHARMACIST' || role === 'LAB_TECHNICIAN' || role === 'RADIOLOGIST') {
          userStatus = 'pending_approval';
        }
      } else if (tenantId) {
        tenant = await Tenant.findByPk(tenantId);
        if (!tenant) {
          return res.status(404).json({ error: 'Tenant not found' });
        }
      }

      const user = await User.create({
        email,
        passwordHash: password,
        firstName,
        lastName,
        tenantId: finalTenantId,
        facilityId: finalFacilityId,
        role: role || 'RECEPTIONIST',
        status: userStatus,
        ...otherFields
      });

      res.status(201).json({
        message: userStatus === 'pending_approval'
          ? 'Registration pending approval by organization admin'
          : 'User created successfully',
        userId: user.id,
        status: userStatus
      });
    } catch (error) {
      console.error('Registration error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }

  async tenantRegister(req, res) {
    try {
      const {
        email,
        password,
        firstName,
        lastName,
        organizationName,
        numberOfClinics,
        clinics
      } = req.body;

      if (!email || !password || !firstName || !lastName || !organizationName) {
        return res.status(400).json({ error: 'Missing required fields' });
      }

      // Check if email already exists
      const existing = await User.findOne({ where: { email } });
      if (existing) {
        return res.status(409).json({ error: 'Email already in use' });
      }

      // Generate tenant slug
      let slug = organizationName.toLowerCase().replace(/[^a-z0-9]/g, '-');
      const uniqueSuffix = Date.now().toString(36);
      slug = `${slug}-${uniqueSuffix}`;
      const schema = `tenant_${slug}`;

      // Create tenant
      const tenant = await Tenant.create({
        name: organizationName,
        slug,
        schema,
        status: 'active'
      });

      // Set up clinic data
      const clinicData = [];
      if (clinics && clinics.length > 0) {
        for (const clinic of clinics) {
          let code = (clinic.code || generateClinicCode()).toUpperCase();

          // Ensure code is unique in the database
          let attempts = 0;
          let isUnique = false;
          while (!isUnique && attempts < 100) {
            const existingCode = await Facility.findOne({ where: { code } });
            if (!existingCode) {
              isUnique = true;
            } else if (clinic.code && attempts === 0) {
              // If user provided a code that's taken, error out or keep trying?
              // User requirement: "This code must be unique across all clinics in the system."
              // Better to error out if the user's SPECIFIC code is taken.
              return res.status(409).json({ error: `Clinic code ${code} is already in use` });
            } else {
              code = generateClinicCode();
              attempts++;
            }
          }

          clinicData.push({
            tenantId: tenant.id,
            name: clinic.name,
            code,
            type: clinic.type || 'HOSPITAL',
            address: clinic.address || {},
            contacts: clinic.contacts || {},
            status: 'active'
          });
        }
      }

      // Create facilities
      if (clinicData.length > 0) {
        await Facility.bulkCreate(clinicData);
      }

      // Create super admin user
      const user = await User.create({
        email,
        passwordHash: password,
        firstName,
        lastName,
        tenantId: tenant.id,
        role: 'SUPER_ADMIN',
        status: 'active'
      });

      res.status(201).json({
        message: 'Organization registered successfully',
        tenantId: tenant.id,
        userId: user.id,
        facilities: clinicData.map(c => ({
          name: c.name,
          code: c.code,
          type: c.type
        }))
      });
    } catch (error) {
      console.error('Tenant registration error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }

  async forgotPassword(req, res) {
    try {
      const { email } = req.body;

      if (!email) {
        return res.status(400).json({ error: 'Email is required' });
      }

      // Check if platform admin - deny password reset
      if (email === PLATFORM_ADMIN_EMAIL) {
        return res.status(403).json({ error: 'Platform admin password reset not allowed' });
      }

      const user = await User.findOne({ where: { email } });

      // Always return success to prevent email enumeration
      res.json({ message: 'If email exists, password reset link will be sent' });

      if (!user) return;

      // Generate reset token
      const resetToken = crypto.randomBytes(32).toString('hex');
      const resetTokenExpiry = new Date(Date.now() + RESET_TOKEN_EXPIRY);

      await user.update({
        passwordResetToken: resetToken,
        passwordResetExpiry: resetTokenExpiry
      });

      // Send email with reset link
      try {
        await emailService.sendPasswordReset(email, resetToken);
      } catch (emailError) {
        console.error('Failed to send reset email:', emailError);
        // We don't return error to user here as we already sent the generic success message
      }
    } catch (error) {
      console.error('Forgot password error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }

  async resetPassword(req, res) {
    try {
      const { token, newPassword } = req.body;

      if (!token || !newPassword) {
        return res.status(400).json({ error: 'Token and new password required' });
      }

      const user = await User.findOne({
        where: {
          passwordResetToken: token,
          passwordResetExpiry: {
            [require('sequelize').Op.gt]: new Date()
          }
        }
      });

      if (!user) {
        return res.status(400).json({ error: 'Invalid or expired reset token' });
      }

      // Update password
      await user.update({
        passwordHash: newPassword,
        passwordResetToken: null,
        passwordResetExpiry: null
      });

      res.json({ message: 'Password reset successfully' });
    } catch (error) {
      console.error('Reset password error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }

  async refresh(req, res) {
    try {
      const { refreshToken } = req.body;

      if (!refreshToken) {
        return res.status(400).json({ error: 'Refresh token required' });
      }

      const decoded = jwt.verify(refreshToken, config.jwt.secret);

      if (decoded.isPlatformAdmin) {
        const accessToken = jwt.sign({
          userId: 'platform-admin',
          email: PLATFORM_ADMIN_EMAIL,
          role: 'PLATFORM_ADMIN',
          isPlatformAdmin: true
        }, config.jwt.secret, { expiresIn: config.jwt.expiresIn });
        return res.json({ accessToken });
      }

      const user = await User.findByPk(decoded.userId);
      if (!user || !user.isActive) {
        return res.status(401).json({ error: 'Invalid token' });
      }

      const payload = {
        userId: user.id,
        tenantId: user.tenantId,
        facilityId: user.facilityId,
        role: user.role
      };

      const accessToken = jwt.sign(payload, config.jwt.secret, { expiresIn: config.jwt.expiresIn });

      res.json({ accessToken });
    } catch (error) {
      if (error.name === 'TokenExpiredError') {
        return res.status(401).json({ error: 'Token expired', code: 'TOKEN_EXPIRED' });
      }
      res.status(401).json({ error: 'Invalid token' });
    }
  }

  async logout(req, res) {
    res.json({ message: 'Logged out successfully' });
  }

  async me(req, res) {
    try {
      if (req.user.isPlatformAdmin) {
        return res.json({
          id: 'platform-admin',
          email: PLATFORM_ADMIN_EMAIL,
          firstName: 'OpenHealth',
          lastName: 'Admin',
          role: 'PLATFORM_ADMIN'
        });
      }

      const user = await User.findByPk(req.user.userId, {
        include: [
          { model: Tenant, as: 'tenant' },
          { model: Facility, as: 'facility' }
        ]
      });

      if (!user) {
        return res.status(404).json({ error: 'User not found' });
      }

      res.json({
        id: user.id,
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
        role: user.role,
        facilityId: user.facilityId,
        facilityCode: user.facility ? user.facility.code : null,
        permissions: user.permissions,
        tenant: user.tenant
      });
    } catch (error) {
      console.error('Get current user error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }

  async approveUser(req, res) {
    try {
      const { userId } = req.params;
      const { approved } = req.body;

      if (!req.user.isPlatformAdmin && req.user.role !== 'SUPER_ADMIN') {
        return res.status(403).json({ error: 'Only super admins can approve users' });
      }

      const user = await User.findByPk(userId);
      if (!user) {
        return res.status(404).json({ error: 'User not found' });
      }

      // For platform admin, can approve anyone
      // For super admin, can only approve users in their tenant
      if (!req.user.isPlatformAdmin && user.tenantId !== req.user.tenantId) {
        return res.status(403).json({ error: 'Cannot approve users from other tenant' });
      }

      await user.update({
        status: approved ? 'active' : 'suspended'
      });

      // Send notification email
      try {
        await emailService.sendApprovalNotification(user.email, user.firstName, approved);
      } catch (emailError) {
        console.error('Failed to send approval email:', emailError);
      }

      res.json({
        message: approved ? 'User approved' : 'User suspended',
        userId: user.id,
        status: user.status
      });
    } catch (error) {
      console.error('Approve user error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }

  async getPendingUsers(req, res) {
    try {
      const whereClause = { status: 'pending_approval' };
      if (!req.user.isPlatformAdmin) {
        whereClause.tenantId = req.user.tenantId;
      }

      const users = await User.findAll({
        where: whereClause,
        include: [{ model: Facility, as: 'facility' }]
      });

      res.json(users);
    } catch (error) {
      console.error('Get pending users error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }

  async listClinics(req, res) {
    try {
      if (!req.user.isPlatformAdmin && req.user.role !== 'SUPER_ADMIN') {
        return res.status(403).json({ error: 'Insufficient permissions' });
      }

      const whereClause = {};
      if (!req.user.isPlatformAdmin) {
        whereClause.tenantId = req.user.tenantId;
      }

      const clinics = await Facility.findAll({
        where: whereClause,
        include: [
          {
            model: User,
            as: 'users',
            attributes: ['id', 'status']
          }
        ]
      });

      res.json(clinics);
    } catch (error) {
      console.error('List clinics error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }
}

module.exports = new AuthController();