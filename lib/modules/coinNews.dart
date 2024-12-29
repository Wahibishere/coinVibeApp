class NewsArticle {
  final String title;
  final String url;
  final String source;
  final String publishedAt;

  NewsArticle({
    required this.title,
    required this.url,
    required this.source,
    required this.publishedAt,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'],
      url: json['url'],
      source: json['source'],
      publishedAt: json['published_at'],
    );
  }
}
