import 'package:get/get.dart';
import '../../../core/services/mock_expenses_service.dart';
import '../../../core/services/mock_expenses_service.dart' as models;

class ExpensesController extends GetxController {
  final MockExpensesService _expensesService = MockExpensesService();
  final RxList<models.Expense> expenses = <models.Expense>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadExpenses();
  }

  Future<void> loadExpenses() async {
    try {
      isLoading.value = true;
      final loadedExpenses = await _expensesService.getExpenses();
      expenses.value = loadedExpenses;
    } catch (e) {
      print('Error loading expenses: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createExpense(
    String vehicleId,
    String title,
    String description,
    double amount,
    String category, {
    String? receiptUrl,
  }) async {
    try {
      isLoading.value = true;
      final expense = await _expensesService.createExpense(
        vehicleId,
        title,
        description,
        amount,
        category,
        receiptUrl: receiptUrl,
      );
      expenses.add(expense);
    } catch (e) {
      print('Error creating expense: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateExpense(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      isLoading.value = true;
      await _expensesService.updateExpense(id, data);
      await loadExpenses();
    } catch (e) {
      print('Error updating expense: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      isLoading.value = true;
      await _expensesService.deleteExpense(id);
      expenses.removeWhere((expense) => expense.id == id);
    } catch (e) {
      print('Error deleting expense: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
