const { tables } = require('../config/bigtable');
const { parseRowData, createMutations } = require('../utils/helpers');
const { Cart } = require('../models/Cart');

class CartService {
  /**
   * Get cart by user ID
   */
  async getCart(userId) {
    const cartsTable = tables.carts;
    const row = cartsTable.row(userId);

    try {
      const [data] = await row.get();
      
      if (!data) {
        // Return empty cart if not found
        return new Cart({ userId });
      }

      const cartData = parseRowData(data);
      return Cart.fromBigtableRow(row, cartData);
    } catch (error) {
      // Return empty cart if error
      return new Cart({ userId });
    }
  }

  /**
   * Add item to cart
   */
  async addItem(userId, item) {
    const cart = await this.getCart(userId);
    cart.addItem(item);
    await this.saveCart(cart);
    return cart;
  }

  /**
   * Update item quantity in cart
   */
  async updateItem(userId, itemIndex, quantity) {
    const cart = await this.getCart(userId);
    cart.updateItem(itemIndex, quantity);
    await this.saveCart(cart);
    return cart;
  }

  /**
   * Remove item from cart
   */
  async removeItem(userId, itemIndex) {
    const cart = await this.getCart(userId);
    cart.removeItem(itemIndex);
    await this.saveCart(cart);
    return cart;
  }

  /**
   * Clear cart
   */
  async clearCart(userId) {
    const cart = new Cart({ userId });
    await this.saveCart(cart);
    return cart;
  }

  /**
   * Save cart to Bigtable
   */
  async saveCart(cart) {
    const cartsTable = tables.carts;
    const row = cartsTable.row(cart.userId);

    const mutations = [];

    // Save each item as item_0, item_1, etc.
    cart.items.forEach((item, index) => {
      mutations.push({
        method: 'insert',
        data: {
          items: {
            [`item_${index}`]: JSON.stringify(item.toJSON()),
          },
        },
      });
    });

    // Add metadata
    mutations.push({
      method: 'insert',
      data: {
        meta: {
          updatedAt: cart.updatedAt,
          totalItems: cart.totalItems.toString(),
          totalPrice: cart.totalPrice.toString(),
        },
      },
    });

    await row.save(mutations);
  }
}

module.exports = new CartService();







