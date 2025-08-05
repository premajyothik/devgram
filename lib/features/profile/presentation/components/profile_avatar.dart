import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String name;
  final String imageUrl;
  final double radius;
  final Color? backgroundColor;

  const ProfileAvatar({
    super.key,
    required this.name,
    required this.imageUrl,
    this.radius = 50,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final double size = radius * 2;

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? Colors.grey.shade300,
      child: imageUrl.isEmpty
          ? Text(
              name.isNotEmpty ? name[0].toUpperCase() : '',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: radius * 0.9,
              ),
            )
          : ClipOval(
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: size,
                height: size,
                fit: BoxFit.cover,
                placeholder: (context, url) => Icon(
                  Icons.person,
                  size: radius,
                  color: Theme.of(context).colorScheme.primary,
                ),
                errorWidget: (context, url, error) =>
                    Icon(Icons.error, size: radius, color: Colors.red),
              ),
            ),
    );
  }
}
