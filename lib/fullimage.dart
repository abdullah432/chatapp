import 'package:flutter/material.dart';

class FullImage extends StatelessWidget {
  String? imageUrl;
  FullImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      child: Image.network(imageUrl!),
    );
  }
}
