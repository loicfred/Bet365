import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news.dart';

class NewsService {
  static const key = String.fromEnvironment('GUARDIAN_API_KEY');

  Future<List<News>> latest({String query = ''}) async {
    final url = Uri.parse('https://content.guardianapis.com/search?section=sport&order-by=newest&show-fields=thumbnail&page-size=5&q=$query&api-key=$key');
    final res = await http.get(url);
    if (res.statusCode != 200) return [];
    final results = jsonDecode(res.body)['response']['results'] as List;
    return results.map((m) => News.fromMap(m)).toList();
  }
}

