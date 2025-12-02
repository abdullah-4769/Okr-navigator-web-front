import 'package:get/get.dart';
import 'package:flutter/material.dart';

class KeyResultsController extends GetxController {
  // Selected items count
  RxInt selectedCount = 0.obs;

  // Selected item indexes
  RxList<int> selectedIndexes = <int>[].obs;

  // Required count (hardcoded for now)
  RxInt requiredCount = 3.obs;

  // List of Key Results (translation keys instead of raw text)
  final List<Map<String, dynamic>> keyResults = [
    {
      'titleKey': 'achieve_5m_revenue',
      'descriptionKey': 'generate_revenue_stream',
      'icon': Icons.attach_money,
      'tag1Key': 'revenue',
      'tag2Key': 'twelve_months',
    },
    {
      'titleKey': 'acquire_10000_customers',
      'descriptionKey': 'build_customer_base',
      'icon': Icons.people,
      'tag1Key': 'customer_growth',
      'tag2Key': 'fifteen_months',
    },
    {
      'titleKey': 'achieve_15_market_share',
      'descriptionKey': 'establish_market_presence',
      'icon': Icons.pie_chart,
      'tag1Key': 'market_share',
      'tag2Key': 'eighteen_months',
    },
    {
      'titleKey': 'achieve_45_satisfaction',
      'descriptionKey': 'maintain_quality_standards',
      'icon': Icons.star,
      'tag1Key': 'satisfaction',
      'tag2Key': 'ongoing',
    },
    {
      'titleKey': 'launch_products_faster',
      'descriptionKey': 'optimize_development_cycles',
      'icon': Icons.speed,
      'tag1Key': 'medium_impact',
      'tag2Key': 'nine_months',
    },
  ];

  /// Toggle selection
  void toggleSelection(int index) {
    if (selectedIndexes.contains(index)) {
      selectedIndexes.remove(index);
    } else {
      if (selectedIndexes.length < requiredCount.value) {
        selectedIndexes.add(index);
      }
    }
    selectedCount.value = selectedIndexes.length;
  }

  /// Check if an item is selected
  bool isSelected(int index) => selectedIndexes.contains(index);

  /// Return list of selected items (maps)
  List<Map<String, dynamic>> getSelectedKeyResults() =>
      selectedIndexes.map((index) => keyResults[index]).toList();

  /// Return only selected titles (keys, not translated yet)
  List<String> getSelectedTitles() => selectedIndexes
      .map((index) => keyResults[index]['titleKey'] as String)
      .toList();
}
