import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PreviewCard extends StatelessWidget {
  final String title;
  final List<String>? images;

  const PreviewCard({super.key, required this.title, required this.images});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = FirebaseAuth.instance.currentUser;
    final fallbackImage = "https://picsum.photos/300";
    final hasImage = images != null && images!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(
                        currentUser?.photoURL ?? fallbackImage,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                currentUser?.displayName ?? "",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                '🧑‍💼',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: hasImage
                          ? Image.file(
                              File(images!.first),
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _buildPlaceholder(isDark),
                            )
                          : _buildPlaceholder(isDark),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(bool isDark) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 28,
            color: isDark ? Colors.white54 : Colors.black45,
          ),
          const SizedBox(height: 4),
          Text(
            "No image",
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
        ],
      ),
    );
  }
}
