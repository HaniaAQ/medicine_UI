import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/medicine.dart';

class MedicineProvider with ChangeNotifier {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  List<Medicine> medicines = [];
  List<String> manufacturers = [];

  Future<String?> _getToken() async {
    return await _secureStorage.read(key: 'jwt');
  }

  Future<bool> fetchMedicines() async {
    final token = await _getToken();
    final url = Uri.parse('http://localhost:5000/api/medicines/');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      medicines = data.map((json) => Medicine.fromJson(json)).toList();

      // Extract unique manufacturers
      manufacturers = medicines
          .map((med) => med.manufacturer)
          .toSet()
          .toList();

      notifyListeners();
      return true;
    } else {
      print('Failed to fetch medicines: ${response.statusCode}');
      return false;
    }
  }

  Future<bool> addMedicine(Medicine medicine) async {
    final token = await _getToken();
    final url = Uri.parse('http://localhost:5000/api/medicines/add');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(medicine.toJson()),
    );

    if (response.statusCode == 201) {
      medicines.add(medicine);
      // Update manufacturers list in case new manufacturer added
      if (!manufacturers.contains(medicine.manufacturer)) {
        manufacturers.add(medicine.manufacturer);
      }
      notifyListeners();
      return true;
    } else {
      print('Failed to add medicine: ${response.statusCode}');
      return false;
    }
  }

  Future<bool> updateMedicine(Medicine medicine) async {
    final token = await _getToken();
    final url = Uri.parse('http://localhost:5000/api/medicines/${medicine.mongoId}');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(medicine.toJson()),
    );

    if (response.statusCode == 200) {
      final index = medicines.indexWhere((m) => m.mongoId == medicine.mongoId);
      if (index != -1) {
        medicines[index] = medicine;
        notifyListeners();
      }
      return true;
    } else {
      print('Failed to update medicine: ${response.statusCode}');
      return false;
    }
  }

  List<Medicine> getMedicinesByManufacturer(String manufacturer) {
    return medicines.where((m) => m.manufacturer == manufacturer).toList();
  }
}
