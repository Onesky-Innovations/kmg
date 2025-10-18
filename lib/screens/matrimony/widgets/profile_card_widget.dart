import 'package:flutter/material.dart';

class ProfileCardWidget extends StatelessWidget {
  final String profileId;
  final String name;
  final String age;
  final String place;
  final String photoUrl;
  final bool hasPhoto;
  final bool isFavorite;
  final bool horizontalMode;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const ProfileCardWidget({
    super.key,
    required this.profileId,
    required this.name,
    required this.age,
    required this.place,
    required this.photoUrl,
    this.hasPhoto = false,
    this.isFavorite = false,
    this.horizontalMode = false,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (horizontalMode) {
      return GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 100,
          child: Column(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: hasPhoto ? NetworkImage(photoUrl) : null,
                    child: !hasPhoto
                        ? const Icon(Icons.person_4, size: 30)
                        : null,
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: onFavoriteToggle,
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                "$age | $place",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    // Grid / vertical mode
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Container(
                    color: Colors.grey[200],
                    height: 120,
                    width: double.infinity,
                    child: hasPhoto
                        ? Image.network(photoUrl, fit: BoxFit.cover)
                        : const Icon(
                            Icons.person_4,
                            size: 60,
                            color: Colors.grey,
                          ),
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: onFavoriteToggle,
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              "$age | $place",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
