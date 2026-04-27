import 'package:connectivity_plus/connectivity_plus.dart';

/// Checks network connectivity.
class ConnectivityService {
  static final _connectivity = Connectivity();

  static Future<bool> get isOnline async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  static Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map(
      (results) => results.any((r) => r != ConnectivityResult.none),
    );
  }
}
