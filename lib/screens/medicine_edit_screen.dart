import 'package:flutter/material.dart';
import '../models/medicine.dart';

class MedicineEditScreen extends StatefulWidget {
  final Medicine? medicine;

  const MedicineEditScreen({Key? key, this.medicine}) : super(key: key);

  @override
  State<MedicineEditScreen> createState() => _MedicineEditScreenState();
}

class _MedicineEditScreenState extends State<MedicineEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _idController;
  late TextEditingController _nameController;
  late TextEditingController _sellingPriceController;
  late TextEditingController _costPriceController;
  late TextEditingController _barcodeController;
  late TextEditingController _manufacturerController;
  late TextEditingController _quantityController;

  @override
  void initState() {
    super.initState();
    final med = widget.medicine;
    _idController = TextEditingController(text: med?.medicineId ?? '');
    _nameController = TextEditingController(text: med?.name ?? '');
    _sellingPriceController = TextEditingController(text: med != null ? med.sellingPrice.toString() : '');
    _costPriceController = TextEditingController(text: med != null ? med.costPrice.toString() : '');
    _barcodeController = TextEditingController(text: med?.barcode ?? '');
    _manufacturerController = TextEditingController(text: med?.manufacturer ?? '');
    _quantityController = TextEditingController(text: med != null ? med.quantity.toString() : '');
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _sellingPriceController.dispose();
    _costPriceController.dispose();
    _barcodeController.dispose();
    _manufacturerController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _save() {
  if (_formKey.currentState!.validate()) {
    final newMedicine = Medicine(
      mongoId: widget.medicine?.mongoId ?? '', // keep existing mongoId if editing
      medicineId: _idController.text.trim(),
      name: _nameController.text.trim(),
      sellingPrice: double.parse(_sellingPriceController.text.trim()),
      costPrice: double.parse(_costPriceController.text.trim()),
      barcode: _barcodeController.text.trim(),
      manufacturer: _manufacturerController.text.trim(),
      quantity: int.parse(_quantityController.text.trim()),
    );
    Navigator.pop(context, newMedicine);
  }
}

  @override
Widget build(BuildContext context) {
  final isEditing = widget.medicine != null;
  return Scaffold(
    appBar: AppBar(title: Text(isEditing ? 'Edit Medicine' : 'Add Medicine')),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildField(_idController, 'Medicine ID', readOnly: isEditing),
            const SizedBox(height: 16),
            _buildField(_nameController, 'Name'),
            const SizedBox(height: 16),
            _buildField(_sellingPriceController, 'Selling Price',
                inputType: TextInputType.numberWithOptions(decimal: true),
                validator: _validateDouble),
            const SizedBox(height: 16),
            _buildField(_costPriceController, 'Cost Price',
                inputType: TextInputType.numberWithOptions(decimal: true),
                validator: _validateDouble),
            const SizedBox(height: 16),
            _buildField(_barcodeController, 'Barcode'),
            const SizedBox(height: 16),
            _buildField(_manufacturerController, 'Manufacturer'),
            const SizedBox(height: 16),
            _buildField(_quantityController, 'Quantity',
                inputType: TextInputType.number,
                validator: _validateInt),
            const SizedBox(height: 30),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _save,
                child: Text(isEditing ? 'Save Changes' : 'Add Medicine',
                    style: const TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildField(TextEditingController controller, String label,
    {bool readOnly = false,
    TextInputType inputType = TextInputType.text,
    String? Function(String?)? validator}) {
  return TextFormField(
    controller: controller,
    readOnly: readOnly,
    keyboardType: inputType,
    decoration: InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    validator: validator ?? (value) {
      if (value == null || value.isEmpty) return 'Please enter $label';
      return null;
    },
  );
}

String? _validateDouble(String? value) {
  if (value == null || value.isEmpty) return 'Enter a number';
  if (double.tryParse(value) == null) return 'Invalid number';
  return null;
}

String? _validateInt(String? value) {
  if (value == null || value.isEmpty) return 'Enter a number';
  if (int.tryParse(value) == null) return 'Invalid number';
  return null;
}
}