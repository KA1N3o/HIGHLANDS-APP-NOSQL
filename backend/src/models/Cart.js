class CartItem {
  constructor(data) {
    this.productId = data.productId;
    this.productName = data.productName;
    this.price = data.price;
    this.quantity = data.quantity;
    this.size = data.size || 'Medium';
    this.options = data.options || {}; // { 'Đường': 'Vừa', 'Đá': 'Ít' }
    this.imageUrl = data.imageUrl || null;
    this.note = data.note || '';
  }

  get subtotal() {
    return this.price * this.quantity;
  }

  toJSON() {
    return {
      productId: this.productId,
      productName: this.productName,
      price: this.price,
      quantity: this.quantity,
      size: this.size,
      options: this.options,
      imageUrl: this.imageUrl,
      note: this.note,
      subtotal: this.subtotal,
    };
  }
}

class Cart {
  constructor(data) {
    this.userId = data.userId;
    this.items = (data.items || []).map(item => new CartItem(item));
    this.updatedAt = data.updatedAt || new Date().toISOString();
  }

  get totalItems() {
    return this.items.reduce((sum, item) => sum + item.quantity, 0);
  }

  get totalPrice() {
    return this.items.reduce((sum, item) => sum + item.subtotal, 0);
  }

  addItem(item) {
    const existingIndex = this.items.findIndex(i => 
      i.productId === item.productId && 
      i.size === item.size &&
      JSON.stringify(i.options) === JSON.stringify(item.options)
    );

    if (existingIndex >= 0) {
      this.items[existingIndex].quantity += item.quantity;
    } else {
      this.items.push(new CartItem(item));
    }

    this.updatedAt = new Date().toISOString();
  }

  updateItem(index, quantity) {
    if (index >= 0 && index < this.items.length) {
      if (quantity <= 0) {
        this.items.splice(index, 1);
      } else {
        this.items[index].quantity = quantity;
      }
      this.updatedAt = new Date().toISOString();
    }
  }

  removeItem(index) {
    if (index >= 0 && index < this.items.length) {
      this.items.splice(index, 1);
      this.updatedAt = new Date().toISOString();
    }
  }

  clear() {
    this.items = [];
    this.updatedAt = new Date().toISOString();
  }

  toJSON() {
    return {
      userId: this.userId,
      items: this.items.map(item => item.toJSON()),
      totalItems: this.totalItems,
      totalPrice: this.totalPrice,
      updatedAt: this.updatedAt,
    };
  }

  static fromBigtableRow(row, rowData) {
    const items = [];
    
    // Parse items from Bigtable (stored as item_0, item_1, etc.)
    Object.keys(rowData).forEach(key => {
      if (key.startsWith('item_')) {
        items.push(JSON.parse(rowData[key]));
      }
    });

    return new Cart({
      userId: row.id,
      items,
      updatedAt: rowData.updatedAt,
    });
  }
}

module.exports = { Cart, CartItem };






