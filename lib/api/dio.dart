import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

Dio setupDio() {
  final dio = Dio();

  dio.options.headers = {
    'x-api-key': "djalcmlasmcqoweijdlkasdmqweoifczxmclapqiwjemdmasdmiqwenoa"
  };

  return dio;
}
