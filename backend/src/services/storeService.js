const { tables } = require('../config/bigtable');
const { parseRowData } = require('../utils/helpers');

class StoreService {
  /**
   * Get all stores
   */
  async getAllStores() {
    const storesTable = tables.stores;
    
    const [rows] = await storesTable.getRows();

    return rows.map((row) => {
      const data = parseRowData(row);
      
      return {
        id: row.id,
        name: data.name,
        address: data.address,
        latitude: parseFloat(data.latitude),
        longitude: parseFloat(data.longitude),
        phone: data.phone,
        imageUrl: data.imageUrl,
        isOpen: data.isOpen === 'true',
        openTime: data.openTime,
        closeTime: data.closeTime,
      };
    });
  }

  /**
   * Get store by ID
   */
  async getStoreById(storeId) {
    const storesTable = tables.stores;
    const row = storesTable.row(storeId);

    const [data] = await row.get();
    
    if (!data) {
      throw new Error('Store not found');
    }

    const storeData = parseRowData(data);

    return {
      id: storeId,
      name: storeData.name,
      address: storeData.address,
      latitude: parseFloat(storeData.latitude),
      longitude: parseFloat(storeData.longitude),
      phone: storeData.phone,
      imageUrl: storeData.imageUrl,
      isOpen: storeData.isOpen === 'true',
      openTime: storeData.openTime,
      closeTime: storeData.closeTime,
    };
  }

  /**
   * Find nearby stores based on user location
   */
  async getNearbyStores(userLat, userLon, radiusKm = 10) {
    const allStores = await this.getAllStores();
    
    // Calculate distance for each store
    const storesWithDistance = allStores.map((store) => ({
      ...store,
      distance: this.calculateDistance(
        userLat,
        userLon,
        store.latitude,
        store.longitude
      ),
    }));

    // Filter by radius and sort by distance
    return storesWithDistance
      .filter((store) => store.distance <= radiusKm)
      .sort((a, b) => a.distance - b.distance);
  }

  /**
   * Calculate distance between two coordinates using Haversine formula
   */
  calculateDistance(lat1, lon1, lat2, lon2) {
    const R = 6371; // Earth's radius in kilometers
    const dLat = this.toRadians(lat2 - lat1);
    const dLon = this.toRadians(lon2 - lon1);
    
    const a =
      Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(this.toRadians(lat1)) *
        Math.cos(this.toRadians(lat2)) *
        Math.sin(dLon / 2) *
        Math.sin(dLon / 2);
    
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    const distance = R * c;
    
    return Math.round(distance * 100) / 100; // Round to 2 decimal places
  }

  toRadians(degrees) {
    return degrees * (Math.PI / 180);
  }
}

module.exports = new StoreService();

