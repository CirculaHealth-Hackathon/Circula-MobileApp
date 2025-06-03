import 'package:circulahealth/api/dio.dart';
import 'package:circulahealth/models/joke.dart';
import 'package:dio/dio.dart';

class JokeService {
  final Dio _dio = setupDio();

  Future<Joke> getRandomJoke() async {
    try {
      final response =
          await _dio.get('https://official-joke-api.appspot.com/jokes/random');
      return Joke.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load joke: $e');
    }
  }
}
