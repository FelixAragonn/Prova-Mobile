import 'package:dio/dio.dart';

import '../config/api_config.dart';

class ClienteApi {
  final Dio dio;

  ClienteApi({Dio? dio}) : dio = dio ?? Dio() {
    this.dio.options = BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.timeout,
      receiveTimeout: ApiConfig.timeout,
      sendTimeout: ApiConfig.timeout,
      responseType: ResponseType.json,
      contentType: Headers.jsonContentType,
    );
  }
}
