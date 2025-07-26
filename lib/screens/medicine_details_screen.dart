import 'package:flutter/material.dart';
import '../models/medicine.dart';
import 'medicine_edit_screen.dart';

class MedicineDetailsScreen extends StatelessWidget {
  final Medicine medicine;

  const MedicineDetailsScreen({Key? key, required this.medicine}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(medicine.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final updatedMedicine = await Navigator.push<Medicine>(
                context,
                MaterialPageRoute(
                  builder: (_) => MedicineEditScreen(medicine: medicine),
                ),
              );
              if (updatedMedicine != null) {
                Navigator.pop(context, updatedMedicine);
              }
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            _buildDetailRow('ID', medicine.medicineId),
            _buildDetailRow('Name', medicine.name),
            _buildDetailRow('Selling Price', '\$${medicine.sellingPrice.toStringAsFixed(2)}'),
            _buildDetailRow('Cost Price', '\$${medicine.costPrice.toStringAsFixed(2)}'),
            _buildDetailRow('Barcode', medicine.barcode),
            _buildDetailRow('Manufacturer', medicine.manufacturer),
            _buildDetailRow('Quantity', medicine.quantity.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(width: 12),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
