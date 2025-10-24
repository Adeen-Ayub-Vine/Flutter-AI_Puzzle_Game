import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:math';

class ImageService {
  final _categories = [
    "fantasy landscape",
    "cute animal",
    "abstract art",
    "galaxy space",
    "dreamy forest",
    "colorful city",
  ];

  Future<Uint8List> getRandomImage() async {
    // pick random prompt
    final prompt = (_categories..shuffle(Random())).first;

    // Pollinations API (no API key required)
    final url = Uri.parse("https://image.pollinations.ai/prompt/$prompt");

    final res = await http.get(url);

    if (res.statusCode == 200) {
      return res.bodyBytes; // directly image data
    } else {
      throw Exception("Failed to fetch image: ${res.statusCode}");
    }
  }
}
