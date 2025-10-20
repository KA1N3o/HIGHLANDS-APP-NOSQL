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
      const data = parseRowData(row.data || row);
      
      // Handle case where openTime/closeTime might be in 'hours' column family
      const openTime = data.openTime || data.hours?.openTime || '08:00';
      const closeTime = data.closeTime || data.hours?.closeTime || '22:00';
      
      // Determine if store is currently open based on hours
      const isOpen = this.isStoreOpen(openTime, closeTime);
      
      return {
        id: row.id,
        name: data.name || 'Unknown Store',
        address: data.address || 'Unknown Address',
        latitude: parseFloat(data.latitude) || 0.0,
        longitude: parseFloat(data.longitude) || 0.0,
        phone: data.phone || '',
        imageUrl: data.imageUrl || '',
        isOpen: isOpen,
        openTime: openTime,
        closeTime: closeTime,
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

    const storeData = parseRowData(data.data || data);
    
    // Handle case where openTime/closeTime might be in 'hours' column family
    const openTime = storeData.openTime || storeData.hours?.openTime || '08:00';
    const closeTime = storeData.closeTime || storeData.hours?.closeTime || '22:00';

    // Determine if store is currently open based on hours
    const isOpen = this.isStoreOpen(openTime, closeTime);

    return {
      id: storeId,
      name: storeData.name || 'Unknown Store',
      address: storeData.address || 'Unknown Address',
      latitude: parseFloat(storeData.latitude) || 0.0,
      longitude: parseFloat(storeData.longitude) || 0.0,
      phone: storeData.phone || '',
      imageUrl: storeData.imageUrl || '',
      isOpen: isOpen,
      openTime: openTime,
      closeTime: closeTime,
    };
  }

  /**
   * Check if store is currently open based on operating hours
   */
  isStoreOpen(openTime, closeTime) {
    try {
      const now = new Date();
      const currentTime = now.toTimeString().substring(0, 5); // Format: "HH:MM"
      
      // Handle case where close time is next day (e.g., 22:00 - 02:00)
      if (closeTime < openTime) {
        // Store is open overnight
        return currentTime >= openTime || currentTime < closeTime;
      } else {
        // Normal case
        return currentTime >= openTime && currentTime < closeTime;
      }
    } catch (error) {
      console.error('Error checking store open status:', error);
      // Default to false if there's an error
      return false;
    }
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

  /**
   * Update store
   */
  async updateStore(storeId, updates) {
    const storesTable = tables.stores;
    const row = storesTable.row(storeId);
    
    // Get current store data by reading the specific row
    const [rows] = await row.get();
    
    if (!rows || rows.length === 0) {
      throw new Error('Store not found');
    }
    
    const currentData = parseRowData(rows[0].data || rows[0]);
    
    // Merge updates with current data
    const updatedData = {
      ...currentData,
      ...updates,
    };
    
    // Create mutations for updated fields
    const mutations = [];
    Object.keys(updates).forEach(key => {
      mutations.push({
        method: 'insert',
        data: {
          columnFamily: 'info',
          column: key,
          value: String(updatedData[key]),
        },
      });
    });
    
    await row.save(mutations);
    
    // Handle case where openTime/closeTime might be in 'hours' column family
    const openTime = updatedData.openTime || updatedData.hours?.openTime || '08:00';
    const closeTime = updatedData.closeTime || updatedData.hours?.closeTime || '22:00';
    
    // Determine if store is currently open based on hours
    const isOpen = this.isStoreOpen(openTime, closeTime);
    
    return {
      id: storeId,
      name: updatedData.name,
      address: updatedData.address,
      latitude: parseFloat(updatedData.latitude),
      longitude: parseFloat(updatedData.longitude),
      phone: updatedData.phone,
      imageUrl: updatedData.imageUrl,
      isOpen: isOpen,
      openTime: openTime,
      closeTime: closeTime,
    };
  }
}

module.exports = new StoreService();