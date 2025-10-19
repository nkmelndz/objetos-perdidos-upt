import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ImagePickerBanner extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onTap;
  final bool isUploading;

  const ImagePickerBanner({
    Key? key,
    required this.imageUrl,
    required this.onTap,
    this.isUploading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1565C0).withOpacity(0.1),
            const Color(0xFF0277BD).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF1565C0).withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isUploading
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  onTap();
                },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                _buildImagePreview(),
                const SizedBox(width: 20),
                _buildTextContent(),
                _buildActionIcon(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: imageUrl.isEmpty
            ? const Color(0xFF1565C0).withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: imageUrl.isEmpty
            ? Border.all(
                color: const Color(0xFF1565C0).withOpacity(0.3),
                width: 2,
              )
            : null,
      ),
      child: _buildPreviewContent(),
    );
  }

  Widget _buildPreviewContent() {
    if (isUploading) {
      return const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      );
    }
    if (imageUrl.isEmpty) {
      return Icon(
        Icons.add_photo_alternate_rounded,
        size: 36,
        color: const Color(0xFF1565C0).withOpacity(0.6),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(imageUrl, fit: BoxFit.cover),
    );
  }

  Widget _buildTextContent() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Foto del objeto',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isUploading
                ? 'Subiendo imagen...'
                : imageUrl.isEmpty
                ? 'Toca para añadir una imagen (obligatorio)'
                : 'Toca para cambiar la imagen',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1565C0).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        isUploading
            ? Icons.hourglass_top_rounded
            : (imageUrl.isEmpty
                  ? Icons.camera_alt_rounded
                  : Icons.edit_rounded),
        color: const Color(0xFF1565C0),
        size: 24,
      ),
    );
  }
}
