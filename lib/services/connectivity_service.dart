import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  Future<bool> hasConnection() async {
    var result = await _connectivity.checkConnectivity();
    if (result == ConnectivityResult.none) {
      return false;
    } else {
      return true;
    }
  }

  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;
}
