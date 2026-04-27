import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// HTTP client with exponential backoff retry.
/// Single Responsibility: only handles HTTP with retry logic.
class ApiClient {
  final http.Client _client;
  final int maxRetries;
  final Duration baseDelay;

  ApiClient({
    http.Client? client,
    this.maxRetries = 3,
    this.baseDelay = const Duration(milliseconds: 500),
  }) : _client = client ?? http.Client();

  /// GET with exponential backoff. Retries on 429, 500, 502, 503, 504.
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    http.Response? lastResponse;
    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        lastResponse = await _client
            .get(url, headers: headers)
            .timeout(const Duration(seconds: 15));

        if (_shouldRetry(lastResponse.statusCode) && attempt < maxRetries) {
          await _delay(attempt);
          continue;
        }
        return lastResponse;
      } on TimeoutException {
        if (attempt == maxRetries) rethrow;
        await _delay(attempt);
      } catch (e) {
        if (attempt == maxRetries) rethrow;
        await _delay(attempt);
      }
    }
    return lastResponse!;
  }

  bool _shouldRetry(int statusCode) {
    return statusCode == 429 ||
        statusCode == 500 ||
        statusCode == 502 ||
        statusCode == 503 ||
        statusCode == 504;
  }

  Future<void> _delay(int attempt) async {
    final delay = baseDelay * pow(2, attempt);
    debugPrint(
        'Retrying in ${delay.inMilliseconds}ms (attempt ${attempt + 1})');
    await Future.delayed(delay);
  }

  void close() => _client.close();
}
