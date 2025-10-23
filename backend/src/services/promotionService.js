const { tables } = require('../config/bigtable');
const { parseRowData } = require('../utils/helpers');
const Promotion = require('../models/Promotion');

class PromotionService {
  /**
   * Create new promotion
   */
  async createPromotion(promotionData) {
    const promotion = new Promotion(promotionData);
    
    console.log('\n=== createPromotion ===');
    console.log('New promotion code:', promotion.code);
    
    // Check if code already exists (only check active promotions)
    let existing = null;
    try {
      existing = await this.getPromotionByCode(promotion.code);
      console.log('Found existing promotion:', existing ? existing.id : 'null');
      console.log('Existing isActive:', existing ? existing.isActive : 'N/A');
    } catch (error) {
      // If getPromotionByCode throws 'Promotion not found', it's OK - no existing promotion
      if (error.message === 'Promotion not found') {
        console.log('✅ OK: No existing promotion found');
      } else {
        // Unexpected error from Bigtable
        console.log('❌ Unexpected error from getPromotionByCode:', error.message);
        throw error;
      }
    }
    
    // Now check if existing promotion is active
    if (existing && existing.isActive) {
      console.log('❌ Rejecting: Active promotion with same code exists');
      throw new Error('Promotion code already exists');
    }
    
    if (existing && !existing.isActive) {
      console.log('✅ OK: Existing promotion is inactive, can reuse code');
    }

    console.log('Saving new promotion...');
    await this.savePromotion(promotion);
    console.log('✅ Promotion created successfully');
    return promotion;
  }

  /**
   * Get promotion by ID
   */
  async getPromotionById(promotionId) {
    const promotionsTable = tables.promotions;
    const row = promotionsTable.row(promotionId);

    const [data] = await row.get();
    
    if (!data) {
      throw new Error('Promotion not found');
    }

    const promotionData = parseRowData(data);
    return Promotion.fromBigtableRow(row, promotionData);
  }

  /**
   * Get promotion by code
   */
  async getPromotionByCode(code) {
    console.log('\n=== getPromotionByCode ===');
    console.log('Looking for code:', code);
    
    // Get all promotions and filter in code (Bigtable filter seems unreliable)
    const allPromotions = await this.getAllPromotions();
    console.log('Total promotions in DB:', allPromotions.length);
    
    // Filter by code (case-insensitive)
    const found = allPromotions.find(p => p.code.toUpperCase() === code.toUpperCase());
    
    if (!found) {
      console.log('❌ Promotion not found');
      throw new Error('Promotion not found');
    }
    
    console.log('✅ Found promotion:', found.id, '- Active:', found.isActive);
    return found;
  }

  /**
   * Validate and apply promotion
   */
  async applyPromotion(code, orderValue) {
    const promotion = await this.getPromotionByCode(code);

    if (!promotion.isValid()) {
      throw new Error('Promotion is not valid or has expired');
    }

    // Check minimum order value first
    if (orderValue < promotion.minOrderValue) {
      throw new Error('Order does not meet minimum value requirement');
    }
    
    const discount = promotion.calculateDiscount(orderValue);
    
    // For free_shipping, discount can be 0 - that's OK as long as minOrderValue is met
    if (discount === 0 && promotion.type !== 'free_shipping') {
      throw new Error('Order does not meet minimum value requirement');
    }

    return {
      promotion: promotion.toJSON(),
      discount,
    };
  }

  /**
   * Increment promotion usage
   */
  async incrementUsage(promotionId) {
    const promotion = await this.getPromotionById(promotionId);
    promotion.incrementUsage();
    await this.savePromotion(promotion);
    return promotion;
  }

  /**
   * Get all promotions
   */
  async getAllPromotions(activeOnly = false) {
    const promotionsTable = tables.promotions;
    
    const filters = [];
    
    if (activeOnly) {
      filters.push({
        column: {
          cellLimit: 1,
          familyName: 'info',
          columnQualifier: 'isActive',
          value: 'true',
        },
      });
    }

    const options = filters.length > 0 ? { filter: filters } : {};
    const [rows] = await promotionsTable.getRows(options);

    console.log(`Got ${rows.length} promotion rows from HBase`);

    const promotions = rows.map(row => {
      try {
        console.log(`\n=== Processing row: ${row.id} ===`);
        console.log('Row data structure keys:', Object.keys(row.data || row));
        
        const promotionData = parseRowData(row.data || row);
        console.log('Parsed promotion data:', JSON.stringify(promotionData, null, 2));
        console.log(`Parsed promotion code: ${promotionData.code || 'unknown'}`);
        
        const promotion = Promotion.fromBigtableRow(row, promotionData);
        console.log(`Created promotion: ${promotion.code} (${promotion.type})`);
        return promotion;
      } catch (error) {
        console.error(`Error parsing promotion row:`, error.message);
        console.error(error.stack);
        return null;
      }
    }).filter(p => p !== null);

    // Filter by date validity if activeOnly
    if (activeOnly) {
      return promotions.filter(p => p.isValid());
    }

    return promotions;
  }

  /**
   * Update promotion
   */
  async updatePromotion(promotionId, updates) {
    const promotion = await this.getPromotionById(promotionId);

    // Update allowed fields
    const allowedFields = [
      'name', 'description', 'value', 'minOrderValue', 'maxDiscount',
      'usageLimit', 'startDate', 'endDate', 'isActive'
    ];

    allowedFields.forEach(field => {
      if (updates[field] !== undefined) {
        promotion[field] = updates[field];
      }
    });

    promotion.updatedAt = new Date().toISOString();
    await this.savePromotion(promotion);
    return promotion;
  }

  /**
   * Delete promotion
   */
  async deletePromotion(promotionId) {
    const promotionsTable = tables.promotions;
    const row = promotionsTable.row(promotionId);
    await row.delete();
  }

  /**
   * Save promotion to Bigtable
   */
  async savePromotion(promotion) {
    const promotionsTable = tables.promotions;
    const row = promotionsTable.row(promotion.id);
    const { createMutations } = require('../utils/helpers');

    const mutations = createMutations('info', {
      code: promotion.code,
      name: promotion.name,
      description: promotion.description,
      type: promotion.type,
      value: promotion.value.toString(),
      minOrderValue: promotion.minOrderValue.toString(),
      maxDiscount: promotion.maxDiscount ? promotion.maxDiscount.toString() : '',
      usageLimit: promotion.usageLimit ? promotion.usageLimit.toString() : '',
      usageCount: promotion.usageCount.toString(),
      startDate: promotion.startDate,
      endDate: promotion.endDate,
      isActive: promotion.isActive.toString(),
      createdAt: promotion.createdAt,
      updatedAt: promotion.updatedAt,
    });

    console.log(`Saving promotion ${promotion.id} with code ${promotion.code}`);
    await row.save(mutations);
    console.log(`✓ Promotion ${promotion.code} saved successfully`);
  }
}

module.exports = new PromotionService();








