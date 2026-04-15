const { Facility } = require('../database');

class FacilityController {
    async list(req, res) {
        try {
            const { tenantId } = req.query;
            const where = {};
            if (tenantId) where.tenantId = tenantId;
            // If not super admin, restrict to user's tenant
            if (req.user.role !== 'SUPER_ADMIN') {
                where.tenantId = req.user.tenantId;
            }

            const facilities = await Facility.findAll({
                where,
                order: [['name', 'ASC']]
            });

            res.json(facilities);
        } catch (error) {
            console.error('List facilities error:', error);
            res.status(500).json({ error: 'Internal server error' });
        }
    }

    async get(req, res) {
        try {
            const facility = await Facility.findByPk(req.params.id);
            if (!facility) return res.status(404).json({ error: 'Facility not found' });

            // Access control
            if (req.user.role !== 'SUPER_ADMIN' && facility.tenantId !== req.user.tenantId) {
                return res.status(403).json({ error: 'Forbidden' });
            }

            res.json(facility);
        } catch (error) {
            console.error('Get facility error:', error);
            res.status(500).json({ error: 'Internal server error' });
        }
    }

    async create(req, res) {
        try {
            const { name, code, type, kephLevel, registrationNumber, address, contacts } = req.body;
            const tenantId = req.user.role === 'SUPER_ADMIN' ? (req.body.tenantId || req.user.tenantId) : req.user.tenantId;

            const facility = await Facility.create({
                tenantId,
                name,
                code,
                type,
                kephLevel,
                registrationNumber,
                address,
                contacts
            });

            res.status(201).json(facility);
        } catch (error) {
            console.error('Create facility error:', error);
            res.status(500).json({ error: 'Internal server error' });
        }
    }

    async update(req, res) {
        try {
            const facility = await Facility.findByPk(req.params.id);
            if (!facility) return res.status(404).json({ error: 'Facility not found' });

            if (req.user.role !== 'SUPER_ADMIN' && facility.tenantId !== req.user.tenantId) {
                return res.status(403).json({ error: 'Forbidden' });
            }

            await facility.update(req.body);
            res.json(facility);
        } catch (error) {
            console.error('Update facility error:', error);
            res.status(500).json({ error: 'Internal server error' });
        }
    }
}

module.exports = new FacilityController();
