const { tables } = require('../config/bigtable');
const { parseRowData, createMutations } = require('../utils/helpers');
const Delivery = require('../models/Delivery');

class DeliveryService {
  /**
   * Create new delivery
   */
  async createDelivery(deliveryData) {
    const delivery = new Delivery(deliveryData);
    await this.saveDelivery(delivery);
    return delivery;
  }

  /**
   * Get delivery by order ID
   */
  async getDeliveryByOrderId(orderId) {
    const deliveriesTable = tables.deliveries;
    
    // Scan to find delivery with matching orderId
    const [rows] = await deliveriesTable.getRows({
      filter: [
        {
          column: {
            cellLimit: 1,
            familyName: 'info',
            columnQualifier: 'orderId',
            value: orderId,
          },
        },
      ],
    });

    if (!rows || rows.length === 0) {
      throw new Error('Delivery not found');
    }

    const row = rows[0];
    const deliveryData = parseRowData(row);
    return Delivery.fromBigtableRow(row, deliveryData);
  }

  /**
   * Get delivery by ID
   */
  async getDeliveryById(deliveryId) {
    const deliveriesTable = tables.deliveries;
    const row = deliveriesTable.row(deliveryId);

    const [data] = await row.get();
    
    if (!data) {
      throw new Error('Delivery not found');
    }

    const deliveryData = parseRowData(data);
    return Delivery.fromBigtableRow(row, deliveryData);
  }

  /**
   * Update delivery status
   */
  async updateDeliveryStatus(deliveryId, status, additionalData = {}) {
    const delivery = await this.getDeliveryById(deliveryId);
    delivery.updateStatus(status, additionalData);
    await this.saveDelivery(delivery);
    return delivery;
  }

  /**
   * Assign shipper to delivery
   */
  async assignShipper(deliveryId, shipperId, shipperName, shipperPhone) {
    const delivery = await this.getDeliveryById(deliveryId);
    delivery.assignShipper(shipperId, shipperName, shipperPhone);
    await this.saveDelivery(delivery);
    return delivery;
  }

  /**
   * Get deliveries for shipper
   */
  async getShipperDeliveries(shipperId, status = null) {
    const deliveriesTable = tables.deliveries;
    
    const filters = [
      {
        column: {
          cellLimit: 1,
          familyName: 'info',
          columnQualifier: 'shipperId',
          value: shipperId,
        },
      },
    ];

    if (status) {
      filters.push({
        column: {
          cellLimit: 1,
          familyName: 'info',
          columnQualifier: 'status',
          value: status,
        },
      });
    }

    const [rows] = await deliveriesTable.getRows({ filter: filters });

    return rows.map(row => {
      const deliveryData = parseRowData(row);
      return Delivery.fromBigtableRow(row, deliveryData);
    });
  }

  /**
   * Update delivery location
   */
  async updateLocation(deliveryId, location) {
    const delivery = await this.getDeliveryById(deliveryId);
    delivery.currentLocation = {
      ...location,
      timestamp: new Date().toISOString(),
    };
    delivery.updatedAt = new Date().toISOString();
    await this.saveDelivery(delivery);
    return delivery;
  }

  /**
   * Save delivery to Bigtable
   */
  async saveDelivery(delivery) {
    const deliveriesTable = tables.deliveries;
    const row = deliveriesTable.row(delivery.id);

    const mutations = [
      {
        method: 'insert',
        data: {
          info: {
            orderId: delivery.orderId,
            shipperId: delivery.shipperId || '',
            shipperName: delivery.shipperName || '',
            shipperPhone: delivery.shipperPhone || '',
            status: delivery.status,
            pickupAddress: JSON.stringify(delivery.pickupAddress),
            deliveryAddress: JSON.stringify(delivery.deliveryAddress),
            currentLocation: delivery.currentLocation ? JSON.stringify(delivery.currentLocation) : '',
            estimatedDeliveryTime: delivery.estimatedDeliveryTime || '',
            actualDeliveryTime: delivery.actualDeliveryTime || '',
            notes: delivery.notes,
            failureReason: delivery.failureReason || '',
            createdAt: delivery.createdAt,
            updatedAt: delivery.updatedAt,
          },
        },
      },
    ];

    await row.save(mutations);
  }
}

module.exports = new DeliveryService();






