abstract class NetworkInfo {
  Future<bool> get isConnected;
}

// Add connectivity_plus to pubspec.yaml (^6.x) — needed to actually check
// connectivity before hitting the API instead of relying on Dio timeouts.
// class NetworkInfoImpl implements NetworkInfo {
//   final Connectivity connectivity;
//   NetworkInfoImpl(this.connectivity);
//   @override
//   Future<bool> get isConnected async {
//     final result = await connectivity.checkConnectivity();
//     return !result.contains(ConnectivityResult.none);
//   }
// }
