import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Helper utility to safely decode and render vehicle base64 images without crashing
class ImageHelper {
  static Uint8List? decodeBase64(String? source) {
    if (source == null || source.trim().isEmpty) return null;
    try {
      String clean = source.trim();
      if (clean.startsWith('data:')) {
        final commaIndex = clean.indexOf(',');
        if (commaIndex != -1) {
          clean = clean.substring(commaIndex + 1);
        }
      }
      return base64Decode(clean);
    } catch (_) {
      return null;
    }
  }

  static Widget buildVehicleImage({
    required List<String>? images,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    IconData fallbackIcon = Icons.directions_car,
  }) {
    String? firstImage = (images != null && images.isNotEmpty) ? images.first : null;
    Uint8List? bytes = decodeBase64(firstImage);

    Widget content;
    if (bytes != null) {
      content = Image.memory(
        bytes,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(
          width: width,
          height: height,
          icon: fallbackIcon,
        ),
      );
    } else {
      content = _buildPlaceholder(
        width: width,
        height: height,
        icon: fallbackIcon,
      );
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: content,
      );
    }
    return content;
  }

  static Widget _buildPlaceholder({
    double? width,
    double? height,
    required IconData icon,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.turmericLight,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        size: (height != null && height < 100) ? 32 : 56,
        color: AppColors.maltLight,
      ),
    );
  }
}
