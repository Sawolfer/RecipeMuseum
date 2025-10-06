
// константы категорий еды 

class Constants {
  // ключ был взят с сайта https://spoonacular.com/
  static const String apiKey = '4653f0f65f6e44a087b7b3306864a1c2'; 
  static const String baseUrl = 'https://api.spoonacular.com/recipes';
  
  static const List<Map<String, String>> categories = [
    {'title': '🍕 Итальянская', 'query': 'italian'},
    {'title': '🌮 Мексиканская', 'query': 'mexican'},
    {'title': '🍣 Японская', 'query': 'japanese'},
    {'title': '🥗 Салаты', 'query': 'salad'},
    {'title': '🍔 Фастфуд', 'query': 'burger'},
    {'title': '🍰 Десерты', 'query': 'dessert'},
  ];
}