import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/recipe_card.dart';
import '../interactors/api_service.dart';
import '../interactors/favorites_provider.dart';
import '../models/recipe_model.dart';

class FavoritesScreen extends StatefulWidget {
  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final ApiService _apiService = ApiService();
  final List<Recipe> _recipes = [];
  bool _isLoading = true;
  List<int> _lastIds = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refreshIfNeeded();
  }

  Future<void> _refreshIfNeeded() async {
    final favorites = context.read<FavoritesProvider>();
    if (!favorites.isLoaded) {
      await favorites.load();
    }
    final ids = favorites.ids..sort();
    if (_sameIds(ids, _lastIds)) {
      return;
    }
    _lastIds = List<int>.from(ids);
    await _loadRecipes(ids);
  }

  Future<void> _refresh() async {
    final favorites = context.read<FavoritesProvider>();
    if (!favorites.isLoaded) {
      await favorites.load();
    }
    final ids = favorites.ids..sort();
    _lastIds = List<int>.from(ids);
    await _loadRecipes(ids);
  }

  Future<void> _loadRecipes(List<int> ids) async {
    if (!mounted) {
      return;
    }
    if (ids.isEmpty) {
      setState(() {
        _recipes.clear();
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);
    final results = await Future.wait(ids.map((id) => _apiService.getRecipeDetails(id)));
    if (!mounted) {
      return;
    }
    _recipes
      ..clear()
      ..addAll(results.whereType<Recipe>());
    setState(() => _isLoading = false);
  }

  bool _sameIds(List<int> a, List<int> b) {
    if (a.length != b.length) {
      return false;
    }
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Избранное')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _recipes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border, size: 72, color: Colors.grey[400]),
                      SizedBox(height: 12),
                      Text(
                        'В избранном пока пусто',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Добавьте рецепты, чтобы они появились здесь',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.builder(
                    itemCount: _recipes.length,
                    itemBuilder: (context, index) {
                      return RecipeCard(recipe: _recipes[index]);
                    },
                  ),
                ),
    );
  }
}
