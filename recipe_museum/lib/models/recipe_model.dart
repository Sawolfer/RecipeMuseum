
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
    return Recipe(
      id: json['id'],
      title: json['title'],
      imageUrl: json['image'],
      readyInMinutes: json['readyInMinutes'] ?? 30,
      servings: json['servings'] ?? 4,
      summary: json['summary'],
      ingredients: List<String>.from(json['extendedIngredients']?.map((i) => i['original'] ?? '') ?? []),
      instructions: List<String>.from(json['analyzedInstructions']?[0]['steps']?.map((s) => s['step'] ?? '') ?? []),
      sourceUrl: json['sourceUrl'],
    );
  }
}