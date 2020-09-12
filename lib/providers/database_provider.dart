import 'package:flutter/material.dart';

import '../database/db_helper.dart';
import '../database/countries_table.dart';
import '../database/categories_table.dart';
import '../models/category_model.dart';
import '../models/country_model.dart';

class DatabaseProvider extends ChangeNotifier {
  Future<void> saveCountry({name, code, flag, phone}) async {
    return DBHelper.insert(CountriesTable.table_name, {
      CountriesTable.name: name,
      CountriesTable.code: code,
      CountriesTable.flag: flag,
      CountriesTable.phone: phone,
    });
  }

  Future<void> saveCategory({id, name, icon}) async {
    return DBHelper.insert(CategoriesTable.table_name, {
      CategoriesTable.id: id,
      CategoriesTable.name: name,
      CategoriesTable.icon: icon,
    });
  }

  Future<void> deleteAll() async {
    await DBHelper.delete(CountriesTable.table_name);
    await DBHelper.delete(CategoriesTable.table_name);
    return;
  }

  Future<List> getCategories() async {
    final dataList = await DBHelper.getData(
        CategoriesTable.table_name, CategoriesTable.name);
    if (dataList.isEmpty) {
      return [];
    }
    return dataList
        .map((item) => CategoryModel(
              id: item[CategoriesTable.id],
              name: item[CategoriesTable.name],
            ))
        .toList();
  }

  Future<List> getCountries() async {
    final dataList =
        await DBHelper.getData(CountriesTable.table_name, CountriesTable.name);
    if (dataList.isEmpty) {
      return [];
    }
    return dataList
        .map((item) => CountryModel(
              id: item[CountriesTable.id],
              name: item[CountriesTable.name],
              code: item[CountriesTable.code],
            ))
        .toList();
  }

  Future<String> getCountryName(String code) async {
    final dataList =
        await DBHelper.getCountry(code);
    if (dataList.isEmpty) {
      return '';
    }
    return dataList.first[CountriesTable.name];
  }
}
