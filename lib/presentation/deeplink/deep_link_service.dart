import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DeepLinkService {
  DeepLinkService(this._router);

  final GoRouter _router;
  final AppLinks _appLinks = AppLinks();

  StreamSubscription<Uri>? _sub;

  Future<void> init() async {
    // App opened from terminated state
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      _handleUri(initialUri);
    }

    _sub = _appLinks.uriLinkStream.listen(_handleUri);
  }

  void _handleUri(Uri uri) {
    // writeit://article/123
    if (uri.host == 'article' && uri.pathSegments.isNotEmpty) {
      final articleId = uri.pathSegments.first;
      _router.go('/article/$articleId');
    }
  }

  void dispose() {
    _sub?.cancel();
  }
}
