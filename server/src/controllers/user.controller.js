const { User, Tenant } = require('../database');

class UserController {
  async list(req, res) {
    try {
      const { page = 1, limit = 50, role, department, isActive } = req.query;

      const where = { tenantId: req.user.tenantId };
      if (role) where.role = role;
      if (department) where.department = department;
      if (isActive !== undefined) where.isActive = isActive === 'true';

      const offset = (page - 1) * limit;
      const { count, rows: users } = await User.findAndCountAll({
        where,
        limit: parseInt(limit),
        offset,
        order: [['createdAt', 'DESC']],
        attributes: { exclude: ['passwordHash'] }
      });

      res.json({
        data: users,
        pagination: {
          total: count,
          page: parseInt(page),
          limit: parseInt(limit),
          pages: Math.ceil(count / limit)
        }
      });
    } catch (error) {
      console.error('List users error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }

  async get(req, res) {
    try {
      const user = await User.findOne({
        where: { id: req.params.id, tenantId: req.user.tenantId },
        attributes: { exclude: ['passwordHash'] }
      });

      if (!user) {
        return res.status(404).json({ error: 'User not found' });
      }

      res.json(user);
    } catch (error) {
      console.error('Get user error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }

  async create(req, res) {
    try {
      const tenant = await Tenant.findByPk(req.user.tenantId);
      if (!tenant) {
        return res.status(404).json({ error: 'Tenant not found' });
      }

      const userCount = await User.count({ where: { tenantId: req.user.tenantId, isActive: true } });
      const packageConfig = require('../config').packages[tenant.package];

      if (packageConfig.users !== Infinity && userCount >= packageConfig.users) {
        return res.status(403).json({ error: 'User limit reached for current package', upgrade: true });
      }

      const user = await User.create({
        ...req.body,
        tenantId: req.user.tenantId,
        passwordHash: req.body.password || 'ChangeMe123!'
      });

      res.status(201).json({
        message: 'User created successfully',
        user: {
          id: user.id,
          email: user.email,
          firstName: user.firstName,
          lastName: user.lastName,
          role: user.role,
          department: user.department
        }
      });
    } catch (error) {
      console.error('Create user error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }

  async update(req, res) {
    try {
      const user = await User.findOne({
        where: { id: req.params.id, tenantId: req.user.tenantId }
      });

      if (!user) {
        return res.status(404).json({ error: 'User not found' });
      }

      if (req.body.password) {
        req.body.passwordHash = req.body.password;
        delete req.body.password;
      }

      await user.update(req.body);

      res.json({
        message: 'User updated successfully',
        user: {
          id: user.id,
          email: user.email,
          firstName: user.firstName,
          lastName: user.lastName,
          role: user.role,
          department: user.department
        }
      });
    } catch (error) {
      console.error('Update user error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }

  async deactivate(req, res) {
    try {
      const user = await User.findOne({
        where: { id: req.params.id, tenantId: req.user.tenantId }
      });

      if (!user) {
        return res.status(404).json({ error: 'User not found' });
      }

      await user.update({ isActive: false });

      res.json({ message: 'User deactivated' });
    } catch (error) {
      console.error('Deactivate user error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }

  async activate(req, res) {
    try {
      const user = await User.findOne({
        where: { id: req.params.id, tenantId: req.user.tenantId }
      });

      if (!user) {
        return res.status(404).json({ error: 'User not found' });
      }

      await user.update({ isActive: true });

      res.json({ message: 'User activated' });
    } catch (error) {
      console.error('Activate user error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }
}

module.exports = new UserController();
