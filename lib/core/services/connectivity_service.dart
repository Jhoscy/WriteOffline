import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service to manage and monitor network connectivity
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  
  final StreamController<bool> _connectivityController = StreamController<bool>.broadcast();
  
  bool _isConnected = false;

  /// Get current connectivity status
  bool get isConnected => _isConnected;

  /// Stream of connectivity changes
  Stream<bool> get onConnectivityChanged => _connectivityController.stream;

  /// Initialize the connectivity service
  Future<void> initialize() async {
    // Check initial connectivity
    final result = await _connectivity.checkConnectivity();
    _isConnected = _isResultConnected(result);
    
    // Listen to connectivity changes
    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      final wasConnected = _isConnected;
      _isConnected = _isResultConnected(result);
      
      // Only emit if the connectivity status changed
      if (wasConnected != _isConnected) {
        _connectivityController.add(_isConnected);
      }
    });
  }

  /// Check if a connectivity result indicates connection
  bool _isResultConnected(List<ConnectivityResult> result) {
    return result.isNotEmpty && 
           (result.contains(ConnectivityResult.mobile) || 
            result.contains(ConnectivityResult.wifi) || 
            result.contains(ConnectivityResult.ethernet));
  }

  /// Dispose of resources
  void dispose() {
    _subscription?.cancel();
    _connectivityController.close();
  }
}

