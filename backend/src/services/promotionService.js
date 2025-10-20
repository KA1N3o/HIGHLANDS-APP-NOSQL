const { tables } = require('../config/bigtable');
const { parseRowData } = require('../utils/helpers');
const Promotion = require('../models/Promotion');

class PromotionService {
  /**
   * Create new promotion
   */
  async createPromotion(promotionData) {
    const promotion = new Promotion(promotionData);
    
    // Check if code already exists
    const existing = await this.getPromotionByCode(promotion.code).catch(() => null);
    if (existing) {
      throw new Error('Promotion code already exists');
    }

    await this.savePromotion(promotion);
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
    const promotionsTable = tables.promotions;
    
    const [rows] = await promotionsTable.getRows({
      filter: [
        {
          column: {
            cellLimit: 1,
            familyName: 'info',
            columnQualifier: 'code',
            value: code,
          },
        },
      ],
    });

    if (!rows || rows.length === 0) {
      throw new Error('Promotion not found');
    }

    const row = rows[0];
    const promotionData = parseRowData(row);
    return Promotion.fromBigtableRow(row, promotionData);
  }

  /**
   * Validate and apply promotion
   */
  async applyPromotion(code, orderValue) {
    const promotion = await this.getPromotionByCode(code);

    if (!promotion.isValid()) {
      throw new Error('Promotion is not valid or has expired');
    }

    const discount = promotion.calculateDiscount(orderValue);
    
    if (discount === 0) {
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

    const promotions = rows.map(row => {
      const promotionData = parseRowData(row);
      return Promotion.fromBigtableRow(row, promotionData);
    });

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

    const mutations = [
      {
        method: 'insert',
        data: {
          info: {
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
          },
        },
      },
    ];

    await row.save(mutations);
  }
}

module.exports = new PromotionService();




