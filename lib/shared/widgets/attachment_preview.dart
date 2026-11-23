import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/utils/constants.dart';
import '../../res/theme/app_colors.dart';
import 'app_network_image.dart';

const _imageExtensions = {'.jpg', '.jpeg', '.png', '.webp', '.gif'};

bool _isImage(String path) {
  final lower = path.toLowerCase();
  return _imageExtensions.any(lower.endsWith);
}

String _fullUrl(String filePath) {
  if (filePath.startsWith('http://') || filePath.startsWith('https://')) return filePath;
  return '${AppConstants.baseUrl}${filePath.startsWith('/') ? '' : '/'}$filePath';
}

// Shows a reference file attached to an order unit: an inline thumbnail for
// images (tap to view full-screen), or a tappable filename chip that opens
// the file externally for anything else (PDF, design files, ...).
class AttachmentPreview extends StatelessWidget {
  final String filePath;

  const AttachmentPreview({super.key, required this.filePath});

  @override
  Widget build(BuildContext context) {
    final url = _fullUrl(filePath);
    final filename = filePath.split('/').last;

    if (_isImage(filePath)) {
      return GestureDetector(
        onTap: () => _showFullImage(context, url),
        child: AppNetworkImage(
          url: url,
          width: 56,
          height: 56,
          borderRadius: BorderRadius.circular(8),
        ),
      );
    }

    return InkWell(
      onTap: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.insert_drive_file_outlined, size: 16, color: AppColors.primary),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              filename,
              style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showFullImage(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: InteractiveViewer(
          child: AppNetworkImage(url: url, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
