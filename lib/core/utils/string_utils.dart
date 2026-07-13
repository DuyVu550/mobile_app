/// Chuẩn hóa chuỗi tiếng Việt: bỏ dấu và chuyển về chữ thường
/// để phục vụ tìm kiếm không phân biệt hoa/thường và không phân biệt dấu.
String removeDiacritics(String input) {
  const withDiacritics =
      'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ';
  const withoutDiacritics =
      'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd';

  final buffer = StringBuffer();
  final lower = input.toLowerCase();
  for (final rune in lower.runes) {
    final char = String.fromCharCode(rune);
    final index = withDiacritics.indexOf(char);
    buffer.write(index == -1 ? char : withoutDiacritics[index]);
  }
  return buffer.toString();
}

/// Định dạng số tiền thành chuỗi có dấu chấm phân cách hàng nghìn (ví dụ: 12.500.000đ)
String formatPrice(num price) {
  return '${price.toInt().toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      )}đ';
}
