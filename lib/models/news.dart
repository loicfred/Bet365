class News {
  String title, image, url;
  News({required this.title, required this.image, required this.url});

  factory News.fromMap(Map<String, dynamic> m) => News(
    title: m['webTitle'] ?? '',
    image: m['fields']?['thumbnail'] ?? '',
    url: m['webUrl'] ?? '',
  );
}


