import 'package:flutter/material.dart';
import '../interactors/api_service.dart';
import '../components/recipe_card.dart';
import '../models/recipe_model.dart';
import '../utils/constants.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  List<Recipe> _recipes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRandomRecipes();
  }

  Future<void> _loadRandomRecipes() async {
    setState(() => _isLoading = true);
    final recipes = await _apiService.getRandomRecipes();
    setState(() {
      _recipes = recipes;
      _isLoading = false;
    });
  }

  Future<void> _searchByCategory(String query) async {
    setState(() => _isLoading = true);
    final recipes = await _apiService.searchRecipes(query);
    setState(() {
      _recipes = recipes;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CookBook 📖'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => Navigator.pushNamed(context, '/search'),
          ),
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () => Navigator.pushNamed(context, '/favorites'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Категории
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: Constants.categories.length,
              itemBuilder: (context, index) {
                final category = Constants.categories[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FilterChip(
                    label: Text(category['title']!),
                    onSelected: (_) => _searchByCategory(category['query']!),
                  ),
                );
              },
            ),
          ),
          
          // Рецепты
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _recipes.isEmpty
                    ? Center(child: Text('Рецепты не найдены 😔'))
                    : ListView.builder(
                        itemCount: _recipes.length,
                        itemBuilder: (context, index) {
                          return RecipeCard(recipe: _recipes[index]);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.refresh),
        onPressed: _loadRandomRecipes,
      ),
    );
  }
}