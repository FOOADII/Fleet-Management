import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/maintenance_service.dart';

class MaintenanceRequestForm extends StatefulWidget {
  const MaintenanceRequestForm({super.key});

  @override
  State<MaintenanceRequestForm> createState() => _MaintenanceRequestFormState();
}

class _MaintenanceRequestFormState extends State<MaintenanceRequestForm> {
  final _formKey = GlobalKey<FormState>();
  final _maintenanceService = MaintenanceService();
  bool _isLoading = false;

  final _vehicleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _priority = 'medium';
  DateTime? _scheduledDate;

  @override
  void dispose() {
    _vehicleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _maintenanceService.createMaintenanceRequest(
        _vehicleController.text,
        'Maintenance Request', // title
        _descriptionController.text,
        scheduledDate: _scheduledDate,
        assignedTo: 'current_user_id', // Replace with actual user ID
        estimatedCost: 0.0, // Add actual cost if needed
      );
      Get.back();
      Get.snackbar(
        'Success',
        'Maintenance request created successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create maintenance request: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _scheduledDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _scheduledDate) {
      setState(() => _scheduledDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Maintenance Request')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _vehicleController,
                decoration: const InputDecoration(
                  labelText: 'Vehicle ID',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a vehicle ID';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _priority,
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'low', child: Text('Low')),
                  DropdownMenuItem(value: 'medium', child: Text('Medium')),
                  DropdownMenuItem(value: 'high', child: Text('High')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _priority = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Scheduled Date',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _scheduledDate != null
                        ? '${_scheduledDate!.day}/${_scheduledDate!.month}/${_scheduledDate!.year}'
                        : 'Select Date',
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Submit Request'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
