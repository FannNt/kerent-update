class SearchRecommendation {
  final String title;
  final String category;
  final String image;
  final String price;
  final bool isPopular;

  SearchRecommendation({
    required this.title,
    required this.category,
    required this.image,
    required this.price,
    this.isPopular = false,
  });
}