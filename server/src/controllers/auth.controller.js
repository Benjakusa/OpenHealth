const jwt = require('jsonwebtoken');
const config = require('../config');
const { User, Tenant } = require('../database');

class AuthController {
  async login(req, res) {
    try {
      const { email, password, tenantId } = req.body;

      if (!email || !password) {
        return res.status(400).json({ error: 'Email and password are required' });
      }

      const whereClause = tenantId ? { email, tenantId } : { email };
      const user = await User.findOne({
        where: whereClause,
        include: [{ model: Tenant, as: 'tenant' }]
      });

      if (!user) {
        return res.status(401).json({ error: 'Invalid credentials' });
      }

      const isMatch = await user.comparePassword(password);
      if (!isMatch) {
        return res.status(401).json({ error: 'Invalid credentials' });
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
      const { email, password, firstName, lastName, tenantId, ...otherFields } = req.body;

      if (!email || !password || !firstName || !lastName) {
        return res.status(400).json({ error: 'Missing required fields' });
      }

      if (tenantId) {
        const tenant = await Tenant.findByPk(tenantId);
        if (!tenant) {
          return res.status(404).json({ error: 'Tenant not found' });
        }
      }

      const existing = await User.findOne({ where: { email } });
      if (existing) {
        return res.status(409).json({ error: 'Email already in use' });
      }

      const user = await User.create({
        email,
        passwordHash: password,
        firstName,
        lastName,
        tenantId,
        ...otherFields
      });

      res.status(201).json({
        message: 'User created successfully',
        userId: user.id
      });
    } catch (error) {
      console.error('Registration error:', error);
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
      
      const user = await User.findByPk(decoded.userId);
      if (!user || !user.isActive) {
        return res.status(401).json({ error: 'Invalid token' });
      }

      const payload = {
        userId: user.id,
        tenantId: user.tenantId,
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
      const user = await User.findByPk(req.user.userId, {
        include: [{ model: Tenant, as: 'tenant' }]
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
        permissions: user.permissions,
        tenant: user.tenant
      });
    } catch (error) {
      console.error('Get current user error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }
}

module.exports = new AuthController();
