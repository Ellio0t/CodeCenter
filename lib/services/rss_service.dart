import 'package:http/http.dart' as http;
import 'package:dart_rss/dart_rss.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;

class RssService {
  final String url = 'https://www.winitcode.com/rss.xml';

  Future<RssFeed?> fetchFeed() async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return RssFeed.parse(response.body);
      }
    } catch (e) {
      print('Error fetching RSS feed: $e');
    }
    return null;
  }

  String? extractImageUrl(String content) {
    try {
      dom.Document document = html_parser.parse(content);
      dom.Element? imgTag = document.querySelector('img');
      if (imgTag != null) {
        return imgTag.attributes['src'];
      }
    } catch (e) {
      print('Error parsing HTML content for image: $e');
    }
    return null;
  }
}
