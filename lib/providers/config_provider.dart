import 'package:flutter/material.dart';

import '../models/category_model.dart';

class ConfigurationProvider with ChangeNotifier {
  List<CategoryModel> _categories = [];

  List<CategoryModel> get getCategories => [..._categories];

  void setCategories(List categories) {
    _categories = categories.map((e) {
      Map dataMap = e as Map;
      return CategoryModel(
        id: dataMap['id'],
        name: dataMap['name'],
      );
    }).toList();
    notifyListeners();
  }
}
