import 'package:flutter/material.dart';

/// Network banner image. Failures fall back to a placeholder and never break
/// the surrounding card or sheet.
class PromotionImage extends StatelessWidget {
  const PromotionImage({required this.url, super.key});

  final String url;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2,
      child: Image.network(
        url,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) => progress == null
            ? child
            : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        errorBuilder: (_, _, _) => const ColoredBox(
          color: Colors.black12,
          child: Center(child: Icon(Icons.image_not_supported_outlined)),
        ),
      ),
    );
  }
}
