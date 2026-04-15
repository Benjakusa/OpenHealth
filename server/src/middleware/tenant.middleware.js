/**
 * Middleware to handle Multi-Tenant and Multi-Facility isolation.
 * Extracts X-Tenant-ID and X-Facility-ID from headers and attaches them to req.
 */
const tenantIsolation = async (req, res, next) => {
  const tenantId = req.headers['x-tenant-id'];
  const facilityId = req.headers['x-facility-id'];

  // If user is authenticated, verify tenant access
  if (req.user) {
    // Regular users MUST match their assigned tenant
    if (req.user.role !== 'SUPER_ADMIN') {
      if (tenantId && tenantId !== req.user.tenantId) {
        return res.status(403).json({ error: 'Tenant access denied' });
      }
      req.tenantId = req.user.tenantId;
    } else {
      // Super admin can specify any tenant via header
      req.tenantId = tenantId || req.user.tenantId;
    }

    // Facility isolation
    if (facilityId) {
      // TODO: Verify if user has access to this specific facility
      // For now, we trust the header if the tenant ID matches
      req.facilityId = facilityId;
    } else if (req.user.facilityId) {
      // Use user's primary facility if none specified
      req.facilityId = req.user.facilityId;
    }
  } else {
    // Unauthenticated requests (e.g. login) can specify tenantId
    req.tenantId = tenantId;
  }

  next();
};

module.exports = { tenantIsolation };
