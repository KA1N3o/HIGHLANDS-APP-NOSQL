import 'package:intl/intl.dart';

/// Extension để format số tiền với dấu phẩy ngăn cách hàng nghìn
extension CurrencyFormatter on num {
  /// Format số tiền thành chuỗi có dấu phẩy (ví dụ: 63700 -> "63,700đ")
  String toCurrency() {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(toInt())}đ';
  }
  
  /// Format số tiền không có đơn vị (ví dụ: 63700 -> "63,700")
  String toFormattedString() {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return formatter.format(toInt());
  }
}

