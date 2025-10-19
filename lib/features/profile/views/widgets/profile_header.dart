import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String photoUrl;
  final String userName;
  final String userEmail;
  final bool isTablet;
  final VoidCallback onEditPhoto;

  const ProfileHeader({
    Key? key,
    required this.photoUrl,
    required this.userName,
    required this.userEmail,
    required this.isTablet,
    required this.onEditPhoto,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        isTablet ? 32.0 : 24.0,
        20.0,
        isTablet ? 32.0 : 24.0,
        40.0,
      ),
      child: Column(
        children: [
          // Avatar con botón de editar
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: isTablet ? 70 : 60,
                  backgroundColor: Colors.white,
                  backgroundImage: photoUrl.isNotEmpty
                      ? NetworkImage(photoUrl)
                      : null,
                  child: photoUrl.isEmpty
                      ? Icon(
                          Icons.person_rounded,
                          size: isTablet ? 80 : 70,
                          color: const Color(0xFF1565C0),
                        )
                      : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Material(
                  color: const Color(0xFFFFC107),
                  shape: const CircleBorder(),
                  elevation: 4,
                  child: InkWell(
                    onTap: onEditPhoto,
                    customBorder: const CircleBorder(),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Nombre
          Text(
            userName.isNotEmpty ? userName : 'Usuario',
            style: TextStyle(
              color: Colors.white,
              fontSize: isTablet ? 28 : 24,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Email
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.email_rounded, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    userEmail.isNotEmpty ? userEmail : 'correo@ejemplo.com',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.95),
                      fontSize: isTablet ? 15 : 14,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
