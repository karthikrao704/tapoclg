class FailedImageCache {
  static final Set<String> _failedUrls = {};

  /// Checks if the [url] has previously failed to load.
  static bool isFailed(String? url) {
    if (url == null || url.isEmpty) return true;
    return _failedUrls.contains(url);
  }

  /// Marks a [url] as failed so we don't attempt to load it again.
  static void markFailed(String? url) {
    if (url != null && url.isNotEmpty) {
      _failedUrls.add(url);
    }
  }

  /// Clears the cache of failed URLs.
  static void clear() {
    _failedUrls.clear();
  }
}
