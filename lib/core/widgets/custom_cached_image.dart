import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomCachedImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final double iconSize;
  final Widget? placeHolder;
  final Widget? errorWidget;

  const CustomCachedImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.iconSize = 32,
    this.placeHolder,
    this.errorWidget.
  });

  @override
  Widget build(BuildContext context) {
    if(imageUrl.trim().isEmpty) {
      return Center(
        child: Icon(
          CupertinoIcons.cube_box,
          size: iconSize,
          color: Colors.grey,
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,

    );
  }
}
