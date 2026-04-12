const { Tenant, User } = require('../database');
const config = require('../config');

class TenantController {
  async list(req, res) {
    try {
      const { page = 1, limit = 50, status, package: pkgFilter } = req.query;

      const where = {};
      if (status) where.status = status;
      if (pkgFilter) where.package = pkgFilter;

      const offset = (page - 1) * limit;
      const { count, rows: tenants } = await Tenant.findAndCountAll({
        where,
        limit: parseInt(limit),
        offset,
        order: [['createdAt', 'DESC']],
        attributes: { exclude: ['insuranceCredentials'] }
      });

      res.json({
        data: tenants,
        pagination: {
          total: count,
          page: parseInt(page),
          limit: parseInt(limit),
          pages: Math.ceil(count / limit)
        }
      });
    } catch (error) {
      console.error('List tenants error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }

  async get(req, res) {
    try {
      const tenant = await Tenant.findByPk(req.params.id, {
        attributes: { exclude: ['insuranceCredentials'] }
      });

      if (!tenant) {
        return res.status(404).json({ error: 'Tenant not found' });
      }

      const userCount = await User.count({ where: { tenantId: req.params.id } });
      const activeUserCount = await User.count({ where: { tenantId: req.params.id, isActive: true } });

      res.json({
        ...tenant.toJSON(),
        userCount,
        activeUserCount
      });
    } catch (error) {
      console.error('Get tenant error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }

  async create(req, res) {
    try {
      const { name, package: pkg, facilityType, contacts, address } = req.body;

      const slug = name.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)/g, '');
      const schema = `tenant_${slug}`;
      const packageConfig = config.packages[pkg] || config.packages.DAWA;

      const tenant = await Tenant.create({
        name,
        slug,
        schema,
        package: pkg || 'DAWA',
        facilityType,
        address: address || {},
        contacts: contacts || {},
        status: 'trial',
        storageLimit: packageConfig.storage,
        expiresAt: new Date(Date.now() + 14 * 24 * 60 * 60 * 1000),
        settings: {
          registrationFee: 200,
          consultationFee: 500,
          triageFee: 100,
          dispensingFee: 80,
          mpesaShortcode: '',
          shaCoveragePercent: 70
        }
      });

      if (req.body.adminEmail) {
        await User.create({
          email: req.body.adminEmail,
          passwordHash: req.body.adminPassword || 'ChangeMe123!',
          firstName: req.body.adminFirstName || 'Admin',
          lastName: req.body.adminLastName || 'User',
          tenantId: tenant.id,
          role: 'FACILITY_ADMIN'
        });
      }

      res.status(201).json({
        message: 'Tenant created successfully',
        tenant: {
          id: tenant.id,
          name: tenant.name,
          slug: tenant.slug,
          package: tenant.package,
          status: tenant.status,
          expiresAt: tenant.expiresAt
        }
      });
    } catch (error) {
      console.error('Create tenant error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }

  async update(req, res) {
    try {
      const tenant = await Tenant.findByPk(req.params.id);

      if (!tenant) {
        return res.status(404).json({ error: 'Tenant not found' });
      }

      if (req.body.package && req.body.package !== tenant.package) {
        const newPackage = config.packages[req.body.package];
        if (newPackage) {
          req.body.storageLimit = newPackage.storage;
        }
      }

      await tenant.update(req.body);

      res.json({
        message: 'Tenant updated successfully',
        tenant
      });
    } catch (error) {
      console.error('Update tenant error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }

  async suspend(req, res) {
    try {
      const tenant = await Tenant.findByPk(req.params.id);

      if (!tenant) {
        return res.status(404).json({ error: 'Tenant not found' });
      }

      tenant.status = 'suspended';
      await tenant.save();

      res.json({ message: 'Tenant suspended', tenant });
    } catch (error) {
      console.error('Suspend tenant error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }

  async reactivate(req, res) {
    try {
      const tenant = await Tenant.findByPk(req.params.id);

      if (!tenant) {
        return res.status(404).json({ error: 'Tenant not found' });
      }

      tenant.status = 'active';
      tenant.expiresAt = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000);
      await tenant.save();

      res.json({ message: 'Tenant reactivated', tenant });
    } catch (error) {
      console.error('Reactivate tenant error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }
}

module.exports = new TenantController();
