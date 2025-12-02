import 'dart:developer';
import 'package:game_app/controllers/language_controller.dart';
import 'package:game_app/controllers/strategy_selection_controller.dart';
import 'package:game_app/data/repositories/objective_repository.dart';
import 'package:game_app/utils/snackbar_helper.dart';
import 'package:get/get.dart';

import '../../generated/models/responses/objectives/objectives_response.dart';

class KeyObjectiveController extends GetxController {
  final RxBool loading = false.obs;
  final RxList<Objective> objectives = RxList<Objective>();
  final ObjectiveRepository repo = Get.find<ObjectiveRepository>();
  final Rxn<Objective> selectedObjective = Rxn<Objective>();

  @override
  void onInit() {
    super.onInit();
    _validateDependencies();
  }

  void _validateDependencies() {
    try {
      Get.find<StrategySelectionController>();
      Get.find<LanguageController>();
    } catch (e) {
      log('Required controllers not found: $e');
      SnackbarHelper.error('Application error: Required dependencies missing.');
    }
  }

  void clearAllData() {
    objectives.clear();
    selectedObjective.value = null;
    loading.value = false;
    print('🧹 KeyObjectiveController - all data cleared');
  }

  void clearSelection() {
    selectedObjective.value = null;
    log('🧹 Objective selection cleared');
  }

  Future<void> getObjectives(
      Map<String, dynamic> role,
      Map<String, dynamic> industry,
      ) async {
    try {
      loading.value = true;
      final strategy = Get.find<StrategySelectionController>().selectedStrategy.value;
      if (strategy == null) throw Exception('No strategy selected');

      final industryOrOrganization = industry['titleKey']?.toString() ?? '';

      final response = await repo.generateObjectives(
        strategyId: strategy.strategyId!,
        strategy: strategy.title!,
        role: role['title']?.toString() ?? '',
        industry: industryOrOrganization,
        language: Get.find<LanguageController>().selectedLanguage.value.toLowerCase(),
      );

      objectives.assignAll(response);
      log('✅ Loaded ${objectives.length} objectives');
    } catch (e, s) {
      log('❌ Error fetching objectives: $e', stackTrace: s);
      SnackbarHelper.error('Failed to load objectives. Using fallback data.');
      objectives.assignAll([
        Objective(title: 'expand_product_line', description: 'introduce_new_products'),
        Objective(title: 'improve_customer_experience', description: 'enhance_satisfaction'),
        Objective(title: 'increase_market_share', description: 'gain_significant_presence'),
      ]);
    } finally {
      loading.value = false;
    }
  }

  void selectObjective(Objective objective) {
    if (selectedObjective.value == objective) {
      selectedObjective.value = null;
      log('🔴 Objective deselected: ${objective.title}');
    } else {
      selectedObjective.value = objective;
      log('🟢 Objective selected: ${objective.title}');
    }
  }

  bool isSelected(Objective objective) => selectedObjective.value == objective;

  bool get isButtonEnabled => selectedObjective.value != null;

  String get selectedTitleKey => selectedObjective.value?.title ?? '';
}
