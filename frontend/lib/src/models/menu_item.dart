/// Represents a menu item from the backend (ElementMenu).
/// Maps to the backend types: PLAT, BOISSON, DESSERT.
class MenuItem {
  final int id;
  final String nom;
  final double prix;
  final String typeElement; // PLAT, BOISSON, DESSERT
  final String? description;
  final String? imageUrl;

  // Type-specific fields
  final int? tempsPreparationMinutes; // PLAT
  final int? calories; // DESSERT
  final bool? estServiChaud; // DESSERT
  final double? volumeLitre; // BOISSON
  final bool? contientAlcool; // BOISSON

  const MenuItem({
    required this.id,
    required this.nom,
    required this.prix,
    required this.typeElement,
    this.description,
    this.imageUrl,
    this.tempsPreparationMinutes,
    this.calories,
    this.estServiChaud,
    this.volumeLitre,
    this.contientAlcool,
  });

  /// Creates a MenuItem from JSON (Map) returned by the API.
  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] ?? 0,
      nom: json['nom'] ?? 'Sans nom',
      prix: (json['prix'] ?? 0).toDouble(),
      typeElement: json['typeElement'] ?? json['type_element'] ?? 'PLAT',
      description: json['description'],
      imageUrl: json['imageUrl'],
      tempsPreparationMinutes: json['tempsPreparationMinutes'],
      calories: json['calories'],
      estServiChaud: json['estServiChaud'],
      volumeLitre: json['volumeLitre'] != null
          ? (json['volumeLitre']).toDouble()
          : null,
      contientAlcool: json['contientAlcool'],
    );
  }

  /// Converts this MenuItem to a JSON Map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prix': prix,
      'type_element': typeElement,
      'description': description,
      'imageUrl': imageUrl,
      'tempsPreparationMinutes': tempsPreparationMinutes,
      'calories': calories,
      'estServiChaud': estServiChaud,
      'volumeLitre': volumeLitre,
      'contientAlcool': contientAlcool,
    };
  }

  /// Returns the category label with emoji for display.
  String get categoryLabel {
    switch (typeElement) {
      case 'PLAT':
        return '🍽️  Plat Principal';
      case 'BOISSON':
        return '🥤  Boisson';
      case 'DESSERT':
        return '🍰  Dessert';
      default:
        return '🍽️  Menu';
    }
  }

  /// Returns the user-friendly category name.
  String get categoryName {
    switch (typeElement) {
      case 'PLAT':
        return 'Food';
      case 'BOISSON':
        return 'Drinks';
      case 'DESSERT':
        return 'Desserts';
      default:
        return 'Other';
    }
  }

  /// Returns a placeholder image URL based on type.
  String get displayImageUrl {
    if (imageUrl != null && imageUrl!.isNotEmpty) return imageUrl!;
    switch (typeElement) {
      case 'PLAT':
        return 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400';
      case 'BOISSON':
        return 'https://images.unsplash.com/photo-1621506289937-a8e4df240d0b?w=400';
      case 'DESSERT':
        return 'https://images.unsplash.com/photo-1551024601-bec78aea704b?w=400';
      default:
        return 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400';
    }
  }
}
