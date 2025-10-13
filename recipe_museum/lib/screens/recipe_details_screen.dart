import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../interactors/api_service.dart';
import '../models/recipe_model.dart';

class RecipeDetailScreen extends StatefulWidget {
  final int recipeId;

  RecipeDetailScreen({required this.recipeId});

  @override
  _RecipeDetailScreenState createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final ApiService _apiService = ApiService();
  Recipe? _recipe;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecipeDetails();
  }

  Future<void> _loadRecipeDetails() async {
    final recipe = await _apiService.getRecipeDetails(widget.recipeId);
    setState(() {
      _recipe = recipe;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _recipe?.imageUrl;
    return Scaffold(
      appBar: AppBar(title: Text('Рецепт')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _recipe == null
              ? Center(child: Text('Рецепт не найден'))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (imageUrl != null)
                        Image.network(
                          imageUrl,
                          height: 300,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildImagePlaceholder();
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            }
                            return _buildImagePlaceholder(isLoading: true);
                          },
                        )
                      else
                        _buildImagePlaceholder(),
                      
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_recipe!.title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                            SizedBox(height: 16),
                            
                            // Информация
                            Row(
                              children: [
                                _InfoItem(icon: Icons.timer, text: '${_recipe!.readyInMinutes} мин'),
                                _InfoItem(icon: Icons.people, text: '${_recipe!.servings} порций'),
                                Spacer(),
                                IconButton(
                                  icon: Icon(_recipe!.isFavorite ? Icons.favorite : Icons.favorite_border),
                                  color: Colors.red,
                                  onPressed: () => _toggleFavorite(),
                                ),
                              ],
                            ),
                            
                            SizedBox(height: 24),
                            
                            // Ингредиенты
                            Text('Ингредиенты:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            SizedBox(height: 8),
                            ..._recipe!.ingredients.map((ingredient) => 
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Text('• $ingredient'),
                              )
                            ).toList(),
                            
                            SizedBox(height: 24),
                            
                            // Инструкции
                            Text('Приготовление:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            SizedBox(height: 8),
                            ..._recipe!.instructions.asMap().entries.map((entry) => 
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 12,
                                      child: Text('${entry.key + 1}', style: TextStyle(fontSize: 12)),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(child: Text(entry.value)),
                                  ],
                                ),
                              )
                            ).toList(),
                            
                            // Кнопка открытия оригинального рецепта
                            if (_recipe!.sourceUrl != null)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: ElevatedButton.icon(
                                  icon: Icon(Icons.open_in_new),
                                  label: Text('Открыть оригинальный рецепт'),
                                  onPressed: () => _launchUrl(_recipe!.sourceUrl!),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  void _toggleFavorite() {
    setState(() {
      _recipe!.isFavorite = !_recipe!.isFavorite;
    });
    // Здесь добавить сохранение в SharedPreferences
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  Widget _buildImagePlaceholder({bool isLoading = false}) {
    return Container(
      height: 300,
      width: double.infinity,
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: isLoading
          ? SizedBox(
              height: 32,
              width: 32,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.image_not_supported, color: Colors.grey.shade500, size: 48),
                SizedBox(height: 8),
                Text(
                  'Изображение недоступно',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;

  _InfoItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20),
        SizedBox(width: 4),
        Text(text),
        SizedBox(width: 16),
      ],
    );
  }
}