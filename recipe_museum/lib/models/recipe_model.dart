
class Recipe {
  
  final int id;
  
  final String title;
  
  final String? imageUrl;
  
  final int readyInMinutes;
  
  final int servings;
  
  final String? summary;
  
  final List<String> ingredients;
  
  final List<String> instructions;
  
  final String? sourceUrl;
  
  bool isFavorite;

  Recipe({
    required this.id,
    required this.title,
    this.imageUrl,
    required this.readyInMinutes,
    required this.servings,
    this.summary,
    required this.ingredients,
    required this.instructions,
    this.sourceUrl,
    this.isFavorite = false,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    final rawImage = (json['image'] ?? json['imageUrl'])?.toString().trim();
    String? image;
    if (rawImage != null && rawImage.isNotEmpty) {
      if (rawImage.startsWith('http')) {
        image = rawImage;
      } else {
        image = 'https://spoonacular.com/recipeImages/$rawImage';
      }
    }
    return Recipe(
      id: json['id'],
      title: json['title'],
      imageUrl: image,
      readyInMinutes: json['readyInMinutes'] ?? 30,
      servings: json['servings'] ?? 4,
      summary: json['summary'],
      ingredients: List<String>.from(json['extendedIngredients']?.map((i) => i['original'] ?? '') ?? []),
      instructions: List<String>.from(json['analyzedInstructions']?[0]['steps']?.map((s) => s['step'] ?? '') ?? []),
      sourceUrl: json['sourceUrl'],
    );
  }
}