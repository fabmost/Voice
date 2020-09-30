import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_user_agent/flutter_user_agent.dart';
import 'package:http/http.dart' as http;

import '../api.dart';
import '../database/db_helper.dart';
import '../database/countries_table.dart';
import '../database/categories_table.dart';
import '../models/category_model.dart';
import '../models/country_model.dart';

class DatabaseProvider extends ChangeNotifier {
  final _storage = FlutterSecureStorage();
  List<CategoryModel> _categories = [];

  List<CategoryModel> get getCategories => [..._categories];

  Future<void> saveCountry({name, code, flag, phone}) async {
    return DBHelper.insert(CountriesTable.table_name, {
      CountriesTable.name: name,
      CountriesTable.code: code,
      CountriesTable.flag: flag,
      CountriesTable.phone: phone,
    });
  }

  void saveCategories(List mList) {
    mList.forEach((e) {
      Map dataMap = e as Map;

      saveCategory(
        id: dataMap['id'],
        name: dataMap['name'],
        icon: dataMap['icon'],
      );
    });
    _categories.sort((a, b) => a.name.compareTo(b.name));
    notifyListeners();
  }

  void saveCategory({id, name, icon}) async {
    _categories.add(
      CategoryModel(
        id: id,
        name: name,
      ),
    );
    return;
  }

  Future<void> deleteAll() async {
    await DBHelper.delete(CountriesTable.table_name);
    await DBHelper.delete(CategoriesTable.table_name);
    return;
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
    final dataList = await DBHelper.getCountry(code);
    if (dataList.isEmpty) {
      return '';
    }
    return dataList.first[CountriesTable.name];
  }

  Future<String> getCatalogs() async {
    var url = '${API.baseURL}/catalogs';
    final _token = await _storage.read(key: API.sessionToken) ?? null;

    await FlutterUserAgent.init();
    String webViewUserAgent = FlutterUserAgent.webViewUserAgent;
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        HttpHeaders.userAgentHeader: webViewUserAgent,
        HttpHeaders.authorizationHeader: 'Bearer $_token'
      },
    );

    final dataMap = jsonDecode(response.body) as Map<String, dynamic>;
    if (dataMap == null) {
      return null;
    }

    if (dataMap['status'] == 'success') {
      await deleteAll();
      dataMap['categories'].forEach((e) async {
        Map dataMap = e as Map;

        saveCategory(
          id: dataMap['id'],
          name: dataMap['name'],
          icon: dataMap['icon'],
        );
      });
      _categories.sort((a, b) => a.name.compareTo(b.name));
      dataMap['configs']['countries'].forEach((e) async {
        Map dataMap = e as Map;

        await saveCountry(
          name: dataMap['name'],
          code: dataMap['country_code'],
          flag: dataMap['flag'],
          phone: dataMap['code_phone'],
        );
      });
      await _storage.write(
          key: API.sessionToken, value: dataMap['session']['token']);
      return null;
    } else {
      return null;
    }
  }
}
