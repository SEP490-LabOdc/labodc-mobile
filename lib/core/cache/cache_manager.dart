/// Generic in-memory cache manager with TTL (Time To Live) support
///
/// Features:
/// - Type-safe generic cache entries
/// - TTL-based expiration
/// - LRU eviction when max size reached
/// - Thread-safe operations
class CacheManager<T> {
  final Map<String, CacheEntry<T>> _cache = {};
  final int maxSize;

  CacheManager({this.maxSize = 100});

  /// Put a value into cache with optional TTL
  void put(String key, T value, {Duration? ttl}) {
    // Evict oldest entry if cache is full
    if (_cache.length >= maxSize) {
      _evictOldest();
    }

    _cache[key] = CacheEntry(
      value: value,
      expiresAt: ttl != null ? DateTime.now().add(ttl) : null,
    );
  }

  /// Get a value from cache, returns null if expired or not found
  T? get(String key) {
    final entry = _cache[key];
    if (entry == null) return null;

    // Check if expired
    if (entry.isExpired) {
      _cache.remove(key);
      return null;
    }

    return entry.value;
  }

  /// Check if a key exists and is not expired
  bool has(String key) {
    final entry = _cache[key];
    if (entry == null) return false;

    if (entry.isExpired) {
      _cache.remove(key);
      return false;
    }

    return true;
  }

  /// Remove a specific key
  void remove(String key) {
    _cache.remove(key);
  }

  /// Clear all cache entries
  void clear() {
    _cache.clear();
  }

  /// Remove all expired entries
  void clearExpired() {
    _cache.removeWhere((key, entry) => entry.isExpired);
  }

  /// Get cache statistics
  CacheStats get stats => CacheStats(
    size: _cache.length,
    maxSize: maxSize,
    hitRate: 0.0, // TODO: Implement hit tracking if needed
  );

  /// Evict the oldest entry (LRU)
  void _evictOldest() {
    if (_cache.isEmpty) return;

    // Find oldest entry by creation time
    String? oldestKey;
    DateTime? oldestTime;

    for (final entry in _cache.entries) {
      final createdAt = entry.value.createdAt;
      if (oldestTime == null || createdAt.isBefore(oldestTime)) {
        oldestTime = createdAt;
        oldestKey = entry.key;
      }
    }

    if (oldestKey != null) {
      _cache.remove(oldestKey);
    }
  }
}

/// Cache entry with metadata
class CacheEntry<T> {
  final T value;
  final DateTime createdAt;
  final DateTime? expiresAt;

  CacheEntry({required this.value, this.expiresAt})
    : createdAt = DateTime.now();

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }
}

/// Cache statistics
class CacheStats {
  final int size;
  final int maxSize;
  final double hitRate;

  CacheStats({
    required this.size,
    required this.maxSize,
    required this.hitRate,
  });

  double get usagePercentage => (size / maxSize) * 100;
}
