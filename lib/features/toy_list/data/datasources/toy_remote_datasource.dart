import 'dart:convert';
import '../models/toy_model.dart';

class ToyRemoteDataSource {
  static const _mockJsonResponse = '''
  [
    {
      "id": "toy-01",
      "name": "Teddy Bear XL",
      "description": "A soft and huggable giant teddy bear, perfect for kids.",
      "price": 25.99,
      "imageUrl": "https://picsum.photos/200"
    },
    {
      "id": "toy-02",
      "name": "Lego City Police Station",
      "description": "Construct your own city police department with this 500-piece set.",
      "price": 49.99,
      "imageUrl": "https://picsum.photos/200"
    },
    {
      "id": "toy-03",
      "name": "RC Racing Car",
      "description": "High speed 2.4GHz remote control car with rechargeable batteries.",
      "price": 34.50,
      "imageUrl": "https://picsum.photos/200"
    }
  ]
  ''';

  Future<List<ToyModel>> fetchToys() async {
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate network latency
    final List<dynamic> decoded = jsonDecode(_mockJsonResponse);
    return decoded.map((json) => ToyModel.fromJson(json as Map<String, dynamic>)).toList();
  }
}
