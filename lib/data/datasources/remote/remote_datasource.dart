/// Abstract interface for remote data source
/// This allows swapping backends (Appwrite, Supabase, etc.)
abstract class RemoteDataSource {
  /// Initialize the remote connection
  Future<void> initialize();

  /// Check if the remote service is available
  Future<bool> isAvailable();
}

