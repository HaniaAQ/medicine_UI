class Medicine {
  final String mongoId; // add this
  final String medicineId;
  final String name;
  final double sellingPrice;
  final double costPrice;
  final String barcode;
  final String manufacturer;
  int quantity;

  Medicine({
    required this.mongoId,
    required this.medicineId,
    required this.name,
    required this.sellingPrice,
    required this.costPrice,
    required this.barcode,
    required this.manufacturer,
    this.quantity = 0,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      mongoId: json['_id'] ?? '',
      medicineId: json['medicineId'] ?? '',
      name: json['name'] ?? '',
      sellingPrice: (json['sellingPrice'] as num).toDouble(),
      costPrice: (json['costPrice'] as num).toDouble(),
      barcode: json['barcode'] ?? '',
      manufacturer: json['manufacturer'] ?? '',
      quantity: (json['quantity'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medicineId': medicineId,
      'name': name,
      'sellingPrice': sellingPrice,
      'costPrice': costPrice,
      'barcode': barcode,
      'manufacturer': manufacturer,
      'quantity': quantity,
    };
  }
}
