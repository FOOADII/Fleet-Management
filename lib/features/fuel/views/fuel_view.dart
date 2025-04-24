import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/fuel_controller.dart';
import '../models/fuel_record.dart';
import '../../../core/theme/colors.dart';

class FuelView extends GetView<FuelController> {
  const FuelView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fuel Management'),
        elevation: 0,
      ),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAddFuelRecordForm(),
                    const SizedBox(height: 24),
                    _buildFuelRecordsList(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildAddFuelRecordForm() {
    final vehicleIdController = TextEditingController();
    final odometerController = TextEditingController();
    final fuelGaugeController = TextEditingController();
    final fuelAmountController = TextEditingController();
    final notesController = TextEditingController();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add Fuel Record',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: vehicleIdController,
                decoration: const InputDecoration(
                  labelText: 'Vehicle ID',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: odometerController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Odometer Reading',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: fuelGaugeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Fuel Gauge (%)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: fuelAmountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Fuel Amount (Liters)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    controller.addFuelRecord(
                      vehicleId: vehicleIdController.text,
                      odometerReading:
                          double.tryParse(odometerController.text) ?? 0,
                      fuelGauge: double.tryParse(fuelGaugeController.text) ?? 0,
                      fuelAmount:
                          double.tryParse(fuelAmountController.text) ?? 0,
                      notes: notesController.text,
                    );

                    // Clear form
                    vehicleIdController.clear();
                    odometerController.clear();
                    fuelGaugeController.clear();
                    fuelAmountController.clear();
                    notesController.clear();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Add Record'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFuelRecordsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fuel Records',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Obx(
          () => ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.fuelRecords.length,
            itemBuilder: (context, index) {
              final record = controller.fuelRecords[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text('Vehicle ID: ${record.vehicleId}'),
                  subtitle: Text(
                    'Odometer: ${record.odometerReading} • Fuel Gauge: ${record.fuelGauge}%\n'
                    'Amount: ${record.fuelAmount}L • Status: ${record.status}\n'
                    '${record.notes != null && record.notes!.isNotEmpty ? "Notes: ${record.notes}" : ""}',
                  ),
                  trailing: Text(
                    record.timestamp.toString().substring(0, 10),
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
