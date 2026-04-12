const { Op } = require('sequelize');
const { Patient, Encounter, User, Billing, Inventory, Tenant } = require('../database');

class SyncController {
  async push(req, res) {
    try {
      const { changes, lastSyncAt, deviceId } = req.body;
      const tenantId = req.user.tenantId;

      const results = {
        patients: { created: 0, updated: 0, errors: [] },
        encounters: { created: 0, updated: 0, errors: [] },
        billing: { created: 0, updated: 0, errors: [] },
        inventory: { created: 0, updated: 0, errors: [] }
      };

      for (const change of changes) {
        try {
          switch (change.entity) {
            case 'patient':
              const patientResult = await this.syncPatient(change, tenantId);
              if (patientResult.created) results.patients.created++;
              else results.patients.updated++;
              break;
            case 'encounter':
              const encounterResult = await this.syncEncounter(change, tenantId);
              if (encounterResult.created) results.encounters.created++;
              else results.encounters.updated++;
              break;
            case 'billing':
              await this.syncBilling(change, tenantId);
              results.billing.updated++;
              break;
            case 'inventory':
              await this.syncInventory(change, tenantId);
              results.inventory.updated++;
              break;
          }
        } catch (error) {
          const entityType = change.entity;
          if (results[entityType]) {
            results[entityType].errors.push({
              localId: change.localId,
              error: error.message
            });
          }
        }
      }

      const now = new Date();
      await Tenant.update(
        { lastSyncAt: now },
        { where: { id: tenantId } }
      );

      res.json({
        success: true,
        results,
        syncAt: now,
        serverTime: now
      });
    } catch (error) {
      console.error('Sync push error:', error);
      res.status(500).json({ error: 'Sync failed', details: error.message });
    }
  }

  async pull(req, res) {
    try {
      const { lastSyncAt, entityTypes, deviceId } = req.query;
      const tenantId = req.user.tenantId;

      const since = lastSyncAt ? new Date(lastSyncAt) : new Date(0);
      const entities = {};

      const types = entityTypes ? entityTypes.split(',') : ['patient', 'encounter', 'billing', 'inventory'];

      if (types.includes('patient')) {
        entities.patients = await Patient.findAll({
          where: { tenantId, updatedAt: { [Op.gt]: since } },
          attributes: { exclude: ['deletedAt'] }
        });
      }

      if (types.includes('encounter')) {
        entities.encounters = await Encounter.findAll({
          where: { tenantId, updatedAt: { [Op.gt]: since } },
          include: [
            { model: Patient, as: 'patient', attributes: ['id', 'firstName', 'lastName', 'patientNumber'] }
          ]
        });
      }

      if (types.includes('user')) {
        entities.users = await User.findAll({
          where: { tenantId, updatedAt: { [Op.gt]: since }, isActive: true },
          attributes: { exclude: ['passwordHash'] }
        });
      }

      if (types.includes('inventory')) {
        entities.inventory = await Inventory.findAll({
          where: { tenantId, updatedAt: { [Op.gt]: since } }
        });
      }

      res.json({
        entities,
        syncAt: new Date(),
        serverTime: new Date()
      });
    } catch (error) {
      console.error('Sync pull error:', error);
      res.status(500).json({ error: 'Sync failed', details: error.message });
    }
  }

  async status(req, res) {
    try {
      const tenant = await Tenant.findByPk(req.user.tenantId);

      res.json({
        tenantId: tenant.id,
        status: tenant.status,
        lastSyncAt: tenant.lastSyncAt,
        storage: tenant.storage,
        storageLimit: tenant.storageLimit,
        storagePercent: Math.round((tenant.storage / tenant.storageLimit) * 100),
        package: tenant.package
      });
    } catch (error) {
      console.error('Sync status error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }

  async getConflicts(req, res) {
    try {
      res.json({ conflicts: [], count: 0 });
    } catch (error) {
      console.error('Get conflicts error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }

  async resolveConflict(req, res) {
    try {
      const { conflictId, resolution, data } = req.body;

      res.json({
        success: true,
        message: 'Conflict resolved',
        conflictId
      });
    } catch (error) {
      console.error('Resolve conflict error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }

  async syncPatient(change, tenantId) {
    const { localId, data, action } = change;

    if (action === 'delete') {
      await Patient.update(
        { isActive: false },
        { where: { id: localId, tenantId } }
      );
      return { updated: true };
    }

    const existing = await Patient.findOne({ where: { id: localId, tenantId } });

    if (existing) {
      await existing.update(data);
      return { updated: true };
    } else {
      await Patient.create({ ...data, tenantId, id: localId });
      return { created: true };
    }
  }

  async syncEncounter(change, tenantId) {
    const { localId, data, action } = change;

    if (action === 'delete') {
      await Encounter.destroy({ where: { id: localId, tenantId } });
      return { updated: true };
    }

    const existing = await Encounter.findOne({ where: { id: localId, tenantId } });

    if (existing) {
      if (existing.isLocked && !data.unlock) {
        return { updated: false, conflict: true };
      }
      await existing.update(data);
      return { updated: true };
    } else {
      await Encounter.create({ ...data, tenantId, id: localId });
      return { created: true };
    }
  }

  async syncBilling(change, tenantId) {
    const { localId, data } = change;
    await Billing.update(data, { where: { id: localId, tenantId } });
  }

  async syncInventory(change, tenantId) {
    const { localId, data } = change;
    await Inventory.update(data, { where: { id: localId, tenantId } });
  }
}

module.exports = new SyncController();
