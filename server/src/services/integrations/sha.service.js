const axios = require('axios');
const config = require('../../config');

class ShaService {
  constructor() {
    this.baseUrl = config.sha?.baseUrl || process.env.SHA_BASE_URL;
    this.clientId = config.sha?.clientId || process.env.SHA_CLIENT_ID;
    this.clientSecret = config.sha?.clientSecret || process.env.SHA_CLIENT_SECRET;
    this.apiKey = config.sha?.apiKey || process.env.SHA_API_KEY;
    this.facilityCode = config.sha?.facilityCode || process.env.SHA_FACILITY_CODE;
    this.webhookSecret = config.sha?.webhookSecret || process.env.SHA_WEBHOOK_SECRET;
  }

  getAuthHeaders() {
    return {
      'Authorization': `Bearer ${this.apiKey}`,
      'Content-Type': 'application/json',
      'X-Facility-Code': this.facilityCode
    };
  }

  async authenticate() {
    if (this.apiKey) return { access_token: this.apiKey };

    try {
      const response = await axios.post(`${this.baseUrl}/oauth/token`, {
        grant_type: 'client_credentials',
        client_id: this.clientId,
        client_secret: this.clientSecret
      });
      this.apiKey = response.data.access_token;
      return response.data;
    } catch (error) {
      console.error('SHA authentication error:', error.response?.data || error.message);
      throw new Error('Failed to authenticate with SHA');
    }
  }

  buildPatientResource(patient) {
    return {
      resourceType: 'Patient',
      id: patient.id,
      identifier: [
        {
          system: 'https://openhealth.com/patient',
          value: patient.patientNumber
        },
        {
          system: 'http://goto.socialhealth.go.ke/patient',
          value: patient.cardNumber || patient.shaCardNumber
        }
      ],
      active: true,
      name: [{
        use: 'official',
        family: patient.lastName || patient.last_name,
        given: [patient.firstName || patient.first_name, ...(patient.middleName || patient.middle_name ? [patient.middleName || patient.middle_name] : [])]
      }],
      birthDate: patient.dateOfBirth || patient.date_of_birth,
      gender: this.mapGender(patient.gender),
      telecom: [
        { system: 'phone', value: patient.phone, use: 'mobile' },
        { system: 'email', value: patient.email }
      ].filter(t => t.value),
      address: patient.address ? [{
        use: 'home',
        line: [patient.address.postalAddress || patient.address.postal_address],
        city: patient.address.town || 'Nairobi',
        country: 'KE'
      }] : []
    };
  }

  buildCoverageResource(insurance) {
    return {
      resourceType: 'Coverage',
      id: insurance.id,
      status: 'active',
      beneficiary: {
        reference: `Patient/${insurance.patientId}`
      },
      payor: [{
        reference: 'Organization/SHA',
        display: 'Social Health Authority'
      }],
      class: [
        {
          type: {
            coding: [{
              system: 'http://terminology.hl7.org/CodeSystem/coverage-class',
              code: 'plan',
              display: 'Plan'
            }]
          },
          value: insurance.schemeType || insurance.scheme_type || 'SHA',
          name: insurance.schemeName || insurance.scheme_name || 'Social Health Authority'
        },
        {
          type: {
            coding: [{
              system: 'http://terminology.hl7.org/CodeSystem/coverage-class',
              code: 'subplan',
              display: 'Subplan'
            }]
          },
          value: insurance.benefitPackage || insurance.benefit_package || 'BENEFIT_PACKAGE_1',
          name: insurance.benefitPackageName || insurance.benefit_package_name || 'Principal Member'
        }
      ],
      identifier: [
        {
          system: 'http://goto.socialhealth.go.ke/coverage',
          value: insurance.memberNumber || insurance.member_number
        }
      ],
      subscriberId: insurance.memberNumber || insurance.member_number,
      relationship: {
        coding: [{
          system: 'http://terminology.hl7.org/CodeSystem/subscriber-relationship',
          code: insurance.relationship || 'self'
        }]
      }
    };
  }

  buildPractitionerResource(practitioner) {
    return {
      resourceType: 'Practitioner',
      id: practitioner.id,
      identifier: [{
        system: 'http://example.org/practitioners',
        value: practitioner.licenseNumber || practitioner.licence_number
      }],
      active: true,
      name: [{
        use: 'official',
        family: practitioner.lastName || practitioner.last_name,
        given: [practitioner.firstName || practitioner.first_name],
        prefix: [practitioner.title]
      }],
      qualification: [{
        code: {
          text: practitioner.specialization || practitioner.department || 'General Practice'
        }
      }]
    };
  }

  buildEncounterResource(encounter, patient) {
    return {
      resourceType: 'Encounter',
      id: encounter.id,
      status: this.mapEncounterStatus(encounter.status),
      class: {
        system: 'http://terminology.hl7.org/CodeSystem/v3-ActCode',
        code: encounter.encounterType === 'inpatient' ? 'IMP' : 'AMB',
        display: encounter.encounterType === 'inpatient' ? 'inpatient encounter' : 'ambulatory encounter'
      },
      type: [{
        coding: [{
          system: 'http://snomed.info/sct',
          code: encounter.visitTypeCode || '308335008',
          display: encounter.visitTypeName || 'General examination'
        }]
      }],
      subject: {
        reference: `Patient/${patient.id}`
      },
      participant: [{
        type: [{
          coding: [{
            system: 'http://terminology.hl7.org/CodeSystem/v3-ParticipationType',
            code: 'PPRF',
            display: 'primary performer'
          }]
        }],
        individual: {
          reference: `Practitioner/${encounter.attendingPhysicianId || encounter.attending_physician_id}`
        }
      }],
      period: {
        start: encounter.startTime || encounter.start_time,
        end: encounter.endTime || encounter.end_time
      },
      reasonCode: encounter.reasonCode ? [{
        coding: [{
          system: 'http://snomed.info/sct',
          code: encounter.reasonCode,
          display: encounter.reasonName || encounter.reason
        }]
      }] : [],
      hospitalization: encounter.visitType === 'inpatient' ? {
        admitSource: {
          coding: [{
            code: encounter.admitSource || '1'
          }]
        }
      } : undefined
    };
  }

  buildClaimResource(claimData) {
    const {
      claimId,
      encounter,
      patient,
      insurance,
      practitioner,
      diagnoses,
      procedures,
      medications,
      services,
      totalAmount
    } = claimData;

    return {
      resourceType: 'Claim',
      id: claimId,
      status: 'active',
      type: {
        coding: [{
          system: 'http://terminology.hl7.org/CodeSystem/claim-type',
          code: encounter.encounterType === 'inpatient' ? 'institutional' : 'professional',
          display: encounter.encounterType === 'inpatient' ? 'Institutional' : 'Professional'
        }]
      },
      use: 'claim',
      patient: {
        reference: `Patient/${patient.id}`
      },
      billablePeriod: {
        start: encounter.startTime || encounter.start_time,
        end: encounter.endTime || encounter.end_time || new Date().toISOString()
      },
      created: new Date().toISOString(),
      provider: {
        reference: `Practitioner/${practitioner.id}`,
        display: `${practitioner.firstName} ${practitioner.lastName}`
      },
      priority: {
        coding: [{
          system: 'http://terminology.hl7.org/CodeSystem/processpriority',
          code: 'normal'
        }]
      },
      insurance: [{
        sequence: 1,
        focal: true,
        coverage: {
          reference: `Coverage/${insurance.id || patient.insurance?.id}`
        }
      }],
      diagnosis: diagnoses.map((diag, index) => ({
        sequence: index + 1,
        diagnosisCodeableConcept: {
          coding: [{
            system: 'http://snomed.info/sct',
            code: diag.code,
            display: diag.description
          }]
        },
        type: [{
          coding: [{
            code: diag.type === 'primary' ? 'principal' : 'drg'
          }]
        }]
      })),
      procedure: procedures?.map((proc, index) => ({
        sequence: index + 1,
        procedureCodeableConcept: {
          coding: [{
            system: 'http://snomed.info/sct',
            code: proc.code,
            display: proc.description
          }]
        },
        date: proc.performedDate || proc.performed_date,
        outcome: 'complete'
      })) || [],
      item: this.buildClaimItems(services, medications, diagnoses),
      total: {
        value: totalAmount,
        currency: 'KES'
      }
    };
  }

  buildClaimItems(services, medications, diagnoses) {
    const items = [];
    let itemSequence = 1;

    if (services && services.length > 0) {
      services.forEach(service => {
        items.push({
          sequence: itemSequence++,
          category: {
            coding: [{
              system: 'http://terminology.hl7.org/CodeSystem/claim-category',
              code: service.category || 'procedure',
              display: service.categoryName || service.category || 'Service'
            }]
          },
          service: {
            coding: [{
              system: 'http://snomed.info/sct',
              code: service.code,
              display: service.description
            }]
          },
          quantity: {
            value: service.quantity || 1
          },
          unitPrice: {
            value: service.unitPrice || service.unit_price,
            currency: 'KES'
          },
          net: {
            value: service.total || service.unitPrice * service.quantity,
            currency: 'KES'
          },
          diagnosisSequence: [1]
        });
      });
    }

    if (medications && medications.length > 0) {
      medications.forEach(med => {
        items.push({
          sequence: itemSequence++,
          category: {
            coding: [{
              system: 'http://terminology.hl7.org/CodeSystem/claim-category',
              code: 'medication',
              display: 'Medication'
            }]
          },
          service: {
            coding: [{
              system: 'http://snomed.info/sct',
              code: med.code || med.drugCode || '385268001',
              display: med.drugName || med.name
            }]
          },
          quantity: {
            value: med.quantity || 1
          },
          unitPrice: {
            value: med.unitPrice || med.unit_price,
            currency: 'KES'
          },
          net: {
            value: med.total || (med.unitPrice || 0) * (med.quantity || 1),
            currency: 'KES'
          },
          bodySite: med.bodySite ? [{
            coding: [{
              code: med.bodySite
            }]
          }] : null
        });
      });
    }

    return items;
  }

  buildBundle(claimData) {
    const bundle = {
      resourceType: 'Bundle',
      id: `claim-bundle-${Date.now()}`,
      type: 'collection',
      timestamp: new Date().toISOString(),
      entry: []
    };

    if (claimData.patient) {
      bundle.entry.push({
        resource: this.buildPatientResource(claimData.patient)
      });
    }

    if (claimData.insurance) {
      bundle.entry.push({
        resource: this.buildCoverageResource(claimData.insurance)
      });
    }

    if (claimData.practitioner) {
      bundle.entry.push({
        resource: this.buildPractitionerResource(claimData.practitioner)
      });
    }

    if (claimData.encounter) {
      bundle.entry.push({
        resource: this.buildEncounterResource(claimData.encounter, claimData.patient)
      });
    }

    bundle.entry.push({
      resource: this.buildClaimResource(claimData)
    });

    return bundle;
  }

  async submitClaim(claimData) {
    await this.authenticate();
    const bundle = this.buildBundle(claimData);

    try {
      const response = await axios.post(
        `${this.baseUrl}/fhir/R4`,
        bundle,
        { headers: this.getAuthHeaders() }
      );

      return {
        success: true,
        claimId: claimData.claimId,
        bundleId: response.data?.id,
        message: 'Claim submitted successfully',
        response: response.data
      };
    } catch (error) {
      console.error('SHA claim submission error:', error.response?.data || error.message);
      throw {
        success: false,
        errorCode: error.response?.data?.issue?.[0]?.code || 'CLAIM_SUBMISSION_FAILED',
        errorMessage: error.response?.data?.issue?.[0]?.diagnostics || 'Failed to submit claim',
        details: error.response?.data
      };
    }
  }

  async checkClaimStatus(claimReference) {
    await this.authenticate();

    try {
      const response = await axios.get(
        `${this.baseUrl}/fhir/R4/Claim/${claimReference}`,
        { headers: this.getAuthHeaders() }
      );

      return {
        success: true,
        claim: {
          id: response.data.id,
          status: response.data.status,
          outcome: response.data.outcome,
          disposition: response.data.disposition,
          totalAmount: response.data.total?.value,
          paidAmount: response.data.totalBenefit
        }
      };
    } catch (error) {
      console.error('SHA claim status error:', error.response?.data || error.message);
      throw new Error('Failed to check claim status');
    }
  }

  async verifyMember(memberNumber, cardNumber) {
    await this.authenticate();

    try {
      const response = await axios.get(
        `${this.baseUrl}/api/v1/members/verify`,
        {
          headers: this.getAuthHeaders(),
          params: {
            member_number: memberNumber,
            card_number: cardNumber
          }
        }
      );

      return {
        success: true,
        valid: response.data.valid,
        member: response.data.member,
        coverage: response.data.coverage,
        benefits: response.data.benefits
      };
    } catch (error) {
      console.error('SHA member verification error:', error.response?.data || error.message);
      throw new Error('Failed to verify member');
    }
  }

  async submitPreAuthorization(encounter, patient, services, practitioner) {
    await this.authenticate();

    const preAuthRequest = {
      resourceType: 'Claim',
      id: `preauth-${Date.now()}`,
      status: 'active',
      type: {
        coding: [{
          system: 'http://terminology.hl7.org/CodeSystem/claim-type',
          code: 'preauthorization'
        }]
      },
      use: 'preauth',
      patient: { reference: `Patient/${patient.id}` },
      created: new Date().toISOString(),
      provider: { reference: `Practitioner/${practitioner.id}` },
      priority: { coding: [{ code: 'urgent' }] },
      item: services.map((svc, idx) => ({
        sequence: idx + 1,
        service: {
          coding: [{
            system: 'http://snomed.info/sct',
            code: svc.code,
            display: svc.description
          }]
        },
        unitPrice: { value: svc.estimatedCost, currency: 'KES' },
        net: { value: svc.estimatedCost * svc.quantity, currency: 'KES' }
      })),
      total: {
        value: services.reduce((sum, s) => sum + (s.estimatedCost * s.quantity), 0),
        currency: 'KES'
      }
    };

    try {
      const response = await axios.post(
        `${this.baseUrl}/fhir/R4`,
        preAuthRequest,
        { headers: this.getAuthHeaders() }
      );

      return {
        success: true,
        preAuthId: response.data.id,
        status: 'pending',
        estimatedAmount: preAuthRequest.total.value
      };
    } catch (error) {
      console.error('SHA pre-auth error:', error.response?.data || error.message);
      throw new Error('Failed to submit pre-authorization');
    }
  }

  async getBenefits(schemeId) {
    await this.authenticate();

    try {
      const response = await axios.get(
        `${this.baseUrl}/api/v1/benefits`,
        {
          headers: this.getAuthHeaders(),
          params: { scheme_id: schemeId }
        }
      );

      return {
        success: true,
        benefits: response.data.benefits
      };
    } catch (error) {
      console.error('SHA benefits error:', error.response?.data || error.message);
      throw new Error('Failed to fetch benefits');
    }
  }

  mapGender(gender) {
    const mapping = {
      'male': 'male',
      'female': 'female',
      'other': 'other',
      'unknown': 'unknown',
      'M': 'male',
      'F': 'female'
    };
    return mapping[gender?.toLowerCase()] || 'unknown';
  }

  mapEncounterStatus(status) {
    const mapping = {
      'planned': 'planned',
      'arrived': 'arrived',
      'triaged': 'in-progress',
      'in-progress': 'in-progress',
      'onleave': 'onleave',
      'finished': 'finished',
      'cancelled': 'cancelled'
    };
    return mapping[status] || 'unknown';
  }
}

module.exports = new ShaService();
