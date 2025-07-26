import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/medicine_provider.dart';
import '../models/medicine.dart';
import 'medicine_details_screen.dart';
import 'medicine_edit_screen.dart';

class MedicinesScreen extends StatefulWidget {
  const MedicinesScreen({super.key});

  @override
  State<MedicinesScreen> createState() => _MedicinesScreenState();
}

class _MedicinesScreenState extends State<MedicinesScreen> {
  String _searchQuery = '';
  String _selectedManufacturer = 'All';

  @override
  void initState() {
    super.initState();
    // Fetch medicines when screen loads
    Future.microtask(() => Provider.of<MedicineProvider>(context, listen: false).fetchMedicines());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicines', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(context),
          Expanded(child: _buildMedicinesList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final newMedicine = await Navigator.push<Medicine>(
            context,
            MaterialPageRoute(builder: (_) => const MedicineEditScreen()),
          );
          if (newMedicine != null) {
            bool success = await Provider.of<MedicineProvider>(context, listen: false)
                .addMedicine(newMedicine);
            if (!success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to add medicine')),
              );
            }
          }
        },
      ),
    );
  }

  Widget _buildSearchAndFilter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Column(
        children: [
          TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Search medicines...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 16),
          Consumer<MedicineProvider>(
            builder: (context, provider, _) {
              final manufacturers = ['All'] + provider.manufacturers;
              return DropdownButtonFormField<String>(
                value: _selectedManufacturer,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: manufacturers
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedManufacturer = value!),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMedicinesList() {
    return Consumer<MedicineProvider>(
      builder: (context, provider, _) {
        var meds = provider.medicines;

        if (_selectedManufacturer != 'All') {
          meds = provider.getMedicinesByManufacturer(_selectedManufacturer);
        }

        if (_searchQuery.isNotEmpty) {
          final query = _searchQuery.toLowerCase();
          meds = meds.where((m) {
            return m.name.toLowerCase().contains(query) ||
                m.manufacturer.toLowerCase().contains(query) ||
                m.medicineId.toLowerCase().contains(query) ||
                m.barcode.contains(_searchQuery);
          }).toList();
        }

        if (meds.isEmpty) {
          return const Center(
            child: Text('No medicines found',
                style: TextStyle(fontSize: 18, color: Colors.grey)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: meds.length,
          itemBuilder: (context, index) {
            final medicine = meds[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                title: Text(medicine.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Manufacturer: ${medicine.manufacturer}\nQuantity: ${medicine.quantity}'),
                trailing: Text('\$${medicine.sellingPrice.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                isThreeLine: true,
                onTap: () async {
                  final updated = await Navigator.push<Medicine>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MedicineDetailsScreen(medicine: medicine),
                    ),
                  );
                  if (updated != null) {
                    final success = await Provider.of<MedicineProvider>(context, listen: false)
                        .updateMedicine(updated);
                    if (!success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to update medicine')),
                      );
                    }
                  }
                },
              ),
            );
          },
        );
      },
    );
  }
}
