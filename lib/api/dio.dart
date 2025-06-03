import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

Dio setupDio() {
  final dio = Dio();

  dio.options.headers = {
    'x-api-key': "djalcmlasmcqoweijdlkasdmqweoifczxmclapqiwjemdmasdmiqwenoa"
  };

  (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
    final client = HttpClient();
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return client;
  };

  return dio;
}
