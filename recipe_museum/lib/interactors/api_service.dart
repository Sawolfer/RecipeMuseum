import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe_model.dart';
import '../utils/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Future<List<Recipe>> searchRecipes(String query, {int number = 20}) async {
    try {
      final response = await http.get(
        Uri.parse('${Constants.baseUrl}/complexSearch?apiKey=${Constants.apiKey}&query=$query&number=$number&addRecipeInformation=true')
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        return results.map((json) => Recipe.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Ошибка поиска: $e');
      return [];
    }
  }

  Future<Recipe?> getRecipeDetails(int id) async {
    try {
      final response = await http.get(
        Uri.parse('${Constants.baseUrl}/$id/information?apiKey=${Constants.apiKey}')
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Recipe.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Ошибка деталей: $e');
      return null;
    }
  }

  Future<List<Recipe>> getRandomRecipes({int number = 10}) async {
    try {
      final response = await http.get(
        Uri.parse('${Constants.baseUrl}/random?apiKey=${Constants.apiKey}&number=$number')
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final recipes = data['recipes'] as List;
        return recipes.map((json) => Recipe.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Ошибка случайных: $e');
      return [];
    }
  }
}