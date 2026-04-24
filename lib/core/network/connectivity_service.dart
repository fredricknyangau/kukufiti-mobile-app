import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/sync_service.dart';

enum ConnectivityStatus { isConnected, isDisconnected, isChecking }

class ConnectivityNotifier extends Notifier<ConnectivityStatus> {
  @override
  ConnectivityStatus build() {
    _init();
    return ConnectivityStatus.isChecking;
  }

  void _init() async {
    final connectivity = Connectivity();
    
    // Initial check
    final result = await connectivity.checkConnectivity();
    _updateStatus(result);

    // Listen for changes
    connectivity.onConnectivityChanged.listen((results) {
      _updateStatus(results);
    });
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final newStatus = results.contains(ConnectivityResult.none) 
        ? ConnectivityStatus.isDisconnected 
        : ConnectivityStatus.isConnected;

    if (state == ConnectivityStatus.isDisconnected && newStatus == ConnectivityStatus.isConnected) {
      // Connection restored, trigger sync
      SyncService.processQueue();
    }
    
    state = newStatus;
  }
}

final connectivityProvider = NotifierProvider<ConnectivityNotifier, ConnectivityStatus>(() {
  return ConnectivityNotifier();
});
