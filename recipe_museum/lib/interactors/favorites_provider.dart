import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe_model.dart';

class FavoritesProvider extends ChangeNotifier {
  static const String _prefsKey = 'favorite_recipe_ids';

  final Set<int> _favoriteIds = <int>{};
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;
  List<int> get ids => _favoriteIds.toList(growable: false);

  bool isFavorite(int id) => _favoriteIds.contains(id);

  Future<void> load() async {
    if (_isLoaded) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefsKey) ?? <String>[];
    _favoriteIds
      ..clear()
      ..addAll(raw.map((e) => int.tryParse(e)).whereType<int>());
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> toggleFavorite(Recipe recipe) async {
    final id = recipe.id;
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
      recipe.isFavorite = false;
    } else {
      _favoriteIds.add(id);
      recipe.isFavorite = true;
    }
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _prefsKey,
      _favoriteIds.map((e) => e.toString()).toList(growable: false),
    );
  }
}
