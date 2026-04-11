// // lib/core/services/connectivity_service.dart
// import 'dart:async';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/services.dart';
//
// class ConnectivityService {
//   final Connectivity _connectivity = Connectivity();
//   StreamSubscription<List<ConnectivityResult>>? _subscription;
//
//   // Stream to listen to connectivity changes
//   final StreamController<ConnectivityResult> _connectionStatusController =
//   StreamController<ConnectivityResult>.broadcast();
//
//   Stream<ConnectivityResult> get connectionStatus =>
//       _connectionStatusController.stream;
//
//   ConnectivityResult _currentStatus = ConnectivityResult.none;
//   ConnectivityResult get currentStatus => _currentStatus;
//
//   ConnectivityService() {
//     initConnectivity();
//     _subscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
//   }
//
//   Future<void> initConnectivity() async {
//     late ConnectivityResult result;
//     try {
//       result = (await _connectivity.checkConnectivity()) as ConnectivityResult;
//       _currentStatus = result;
//       _connectionStatusController.add(result);
//     } on PlatformException catch (e) {
//       print('Couldn\'t check connectivity status: $e');
//       result = ConnectivityResult.none;
//     }
//   }
//
//   void _updateConnectionStatus(List<ConnectivityResult> results) {
//     // Take the first result (most relevant)
//     final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
//     _currentStatus = result;
//     _connectionStatusController.add(result);
//   }
//
//   bool get isConnected => _currentStatus != ConnectivityResult.none;
//
//   String get connectionType {
//     switch (_currentStatus) {
//       case ConnectivityResult.wifi:
//         return 'Wi-Fi';
//       case ConnectivityResult.mobile:
//         return 'Mobile Data';
//       case ConnectivityResult.ethernet:
//         return 'Ethernet';
//       case ConnectivityResult.vpn:
//         return 'VPN';
//       default:
//         return 'No Connection';
//     }
//   }
//
//   Future<bool> checkConnectivity() async {
//     try {
//       final result = await _connectivity.checkConnectivity();
//       _currentStatus = result.isNotEmpty ? result.first : ConnectivityResult.none;
//       return isConnected;
//     } catch (e) {
//       return false;
//     }
//   }
//
//   void dispose() {
//     _subscription?.cancel();
//     _connectionStatusController.close();
//   }
// }