import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/utils/constants.dart';
import '../../res/theme/app_colors.dart';

class AppNetworkImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  String? get fullUrl {
    if (url == null || url!.trim().isEmpty) return null;
    final clean = url!.trim();
    if (clean.startsWith('http://') || clean.startsWith('https://')) {
      return clean;
    }
    return '${AppConstants.baseUrl}${clean.startsWith('/') ? '' : '/'}$clean';
  }

  @override
  Widget build(BuildContext context) {
    final imageUri = fullUrl;

    Widget image;
    if (imageUri == null) {
      image = errorWidget ??
          Container(
            width: width,
            height: height,
            color: AppColors.inputBg,
            child: const Icon(Icons.image_not_supported_outlined, color: AppColors.textLight),
          );
    } else {
      image = CachedNetworkImage(
        imageUrl: imageUri,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, _) =>
            placeholder ??
            Container(
              width: width,
              height: height,
              color: AppColors.inputBg,
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                ),
              ),
            ),
        errorWidget: (context, _, error) =>
            errorWidget ??
            Container(
              width: width,
              height: height,
              color: AppColors.inputBg,
              child: const Icon(Icons.broken_image_outlined, color: AppColors.textLight),
            ),
      );
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }
}
