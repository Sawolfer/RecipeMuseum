import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import '../interactors/api_service.dart';
import '../components/recipe_card.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  List<Recipe> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String? _selectedCuisine;
  String? _selectedDiet;
  int? _maxReadyTime;
  bool _vegetarian = false;
  bool _vegan = false;

  // Фильтры
  final List<String> _cuisines = [
    'All', 'Italian', 'Mexican', 'Chinese', 'Japanese', 
    'Indian', 'French', 'Greek', 'Spanish', 'Thai'
  ];
  
  final List<String> _diets = [
    'All', 'Gluten Free', 'Ketogenic', 'Vegetarian', 
    'Lacto-Vegetarian', 'Ovo-Vegetarian', 'Vegan', 'Pescetarian'
  ];
  
  final List<int> _cookingTimes = [15, 30, 45, 60, 90, 120];

  Future<void> _performSearch() async {
    if (_searchController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Введите поисковый запрос')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    try {
      // Формируем строку запроса с фильтрами
      String query = _searchController.text.trim();
      
      // Добавляем фильтры к запросу
      String filters = '';
      if (_selectedCuisine != null && _selectedCuisine != 'All') {
        filters += '&cuisine=${_selectedCuisine!.toLowerCase()}';
      }
      if (_selectedDiet != null && _selectedDiet != 'All') {
        filters += '&diet=${_selectedDiet!.toLowerCase().replaceAll(' ', '')}';
      }
      if (_maxReadyTime != null) {
        filters += '&maxReadyTime=$_maxReadyTime';
      }
      if (_vegetarian) {
        filters += '&vegetarian=true';
      }
      if (_vegan) {
        filters += '&vegan=true';
      }
      
      // Выполняем поиск
      final results = await _apiService.searchRecipes(query);
      
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
      
      // Скрываем клавиатуру
      FocusScope.of(context).unfocus();
    } catch (e) {
      print('Ошибка поиска: $e');
      setState(() => _isLoading = false);
    }
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchResults.clear();
      _hasSearched = false;
      _selectedCuisine = null;
      _selectedDiet = null;
      _maxReadyTime = null;
      _vegetarian = false;
      _vegan = false;
    });
    FocusScope.of(context).unfocus();
  }

  Widget _buildFilterSection() {
    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Фильтры:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            
            // Кухня
            Text('Кухня:', style: TextStyle(fontSize: 14)),
            Wrap(
              spacing: 8,
              children: _cuisines.map((cuisine) {
                return FilterChip(
                  label: Text(cuisine),
                  selected: _selectedCuisine == cuisine,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCuisine = selected ? cuisine : null;
                    });
                  },
                );
              }).toList(),
            ),
            
            SizedBox(height: 12),
            
            // Диета
            Text('Диета:', style: TextStyle(fontSize: 14)),
            Wrap(
              spacing: 8,
              children: _diets.map((diet) {
                return FilterChip(
                  label: Text(diet),
                  selected: _selectedDiet == diet,
                  onSelected: (selected) {
                    setState(() {
                      _selectedDiet = selected ? diet : null;
                    });
                  },
                );
              }).toList(),
            ),
            
            SizedBox(height: 12),
            
            // Время приготовления
            Text('Макс. время приготовления (мин):', style: TextStyle(fontSize: 14)),
            Wrap(
              spacing: 8,
              children: _cookingTimes.map((time) {
                return FilterChip(
                  label: Text('до $time'),
                  selected: _maxReadyTime == time,
                  onSelected: (selected) {
                    setState(() {
                      _maxReadyTime = selected ? time : null;
                    });
                  },
                );
              }).toList(),
            ),
            
            SizedBox(height: 12),
            
            // Вегетарианское/Веганское
            Row(
              children: [
                Checkbox(
                  value: _vegetarian,
                  onChanged: (value) => setState(() => _vegetarian = value ?? false),
                ),
                Text('Вегетарианское'),
                SizedBox(width: 20),
                Checkbox(
                  value: _vegan,
                  onChanged: (value) => setState(() => _vegan = value ?? false),
                ),
                Text('Веганское'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Найти рецепт...',
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: Icon(Icons.clear),
              onPressed: _clearSearch,
            ),
          ),
          onSubmitted: (_) => _performSearch(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: _performSearch,
          ),
        ],
      ),
      body: Column(
        children: [
          // Фильтры
          Expanded(
            flex: _hasSearched ? 0 : 1,
            child: SingleChildScrollView(
              child: _buildFilterSection(),
            ),
          ),
          
          // Результаты поиска
          Expanded(
            flex: _hasSearched ? 3 : 0,
            child: _hasSearched
                    ? _searchResults.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 80,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Рецепты не найдены',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Попробуйте изменить запрос или фильтры',
                                  style: TextStyle(color: Colors.grey[500]),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              return RecipeCard(recipe: _searchResults[index]);
                            },
                          )
                    : Container(),
          ),
        ],
      ),
      floatingActionButton: _hasSearched && _searchResults.isNotEmpty
          ? FloatingActionButton.extended(
              icon: Icon(Icons.filter_alt),
              label: Text('Фильтры'),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => SingleChildScrollView(
                    child: _buildFilterSection(),
                  ),
                );
              },
            )
          : null,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
