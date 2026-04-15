const jwt = require('jsonwebtoken');
const config = require('../config');

const authenticate = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'No token provided' });
    }

    const token = authHeader.split(' ')[1];
    const decoded = jwt.verify(token, config.jwt.secret);
    
    // Store full user info in request
    req.user = decoded;
    next();
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({ error: 'Token expired', code: 'TOKEN_EXPIRED' });
    }
    return res.status(401).json({ error: 'Invalid token' });
  }
};

const authorize = (...roles) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({ error: 'Not authenticated' });
    }

    // Platform admin has access to everything
    if (req.user.isPlatformAdmin) {
      return next();
    }

    if (!roles.includes(req.user.role)) {
      return res.status(403).json({ error: 'Insufficient permissions' });
    }

    next();
  };
};

const checkPermission = (...permissions) => {
  return async (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({ error: 'Not authenticated' });
    }

    // Platform admin has all permissions
    if (req.user.isPlatformAdmin) {
      return next();
    }

    const { User } = require('../database');
    const user = await User.findByPk(req.user.userId);

    if (!user) {
      return res.status(401).json({ error: 'User not found' });
    }

    const hasPermission = permissions.some(p => user.permissions && user.permissions.includes(p));
    if (!hasPermission && !user.role.includes('SUPER_ADMIN') && !user.role.includes('FACILITY_ADMIN')) {
      return res.status(403).json({ error: 'Insufficient permissions' });
    }

    next();
  };
};

const checkTenantAccess = async (req, res, next) => {
  if (!req.user) {
    return res.status(401).json({ error: 'Not authenticated' });
  }

  // Platform admin has access to everything
  if (req.user.isPlatformAdmin) {
    return next();
  }

  const tenantId = req.params.tenantId || req.body.tenantId || req.query.tenantId;
  
  if (tenantId && tenantId !== req.user.tenantId && req.user.role !== 'SUPER_ADMIN') {
    return res.status(403).json({ error: 'Access denied to this tenant' });
  }

  next();
};

// Middleware to ensure data isolation based on facility
const checkFacilityAccess = async (req, res, next) => {
  if (!req.user) {
    return res.status(401).json({ error: 'Not authenticated' });
  }

  // Platform admin and super admin can view all
  if (req.user.isPlatformAdmin || req.user.role === 'SUPER_ADMIN') {
    return next();
  }

  const facilityId = req.params.facilityId || req.body.facilityId || req.query.facilityId;
  
  // If user has a facilityId, they can only access that facility's data
  if (facilityId && facilityId !== req.user.facilityId) {
    return res.status(403).json({ error: 'Access denied to this facility' });
  }

  next();
};

module.exports = {
  authenticate,
  authorize,
  checkPermission,
  checkTenantAccess,
  checkFacilityAccess
};