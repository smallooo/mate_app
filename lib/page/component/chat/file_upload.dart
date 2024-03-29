
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';

import '../image_preview.dart';

class FileUpload {
  final PlatformFile file;
  String? url;

  FileUpload({required this.file, this.url});

  bool get uploaded => url != null;

  setUrl(String url) {
    this.url = url;
  }
}

class FileUploadPreview extends StatelessWidget {
  final List<String> images;
  const FileUploadPreview({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    final children = images
        .map((e) {
      if (e.startsWith('http://') || e.startsWith('https://')) {
        return NetworkImagePreviewer(
          url: e,
          hidePreviewButton: true,
        );
      }

      if (e.startsWith('data:')) {
        return ImageProviderPreviewer(
          borderRadius: BorderRadius.circular(5),
          imageProvider: MemoryImage(
            const Base64Decoder().convert(e.split(',')[1]),
          ),
        );
      }
      return const SizedBox();
    })
        .map((e) => Padding(
      padding: const EdgeInsets.only(bottom: 5, left: 5),
      child: e,
    ))
        .toList();
    if (children.length > 1) {
      if (children.length % 2 == 1) {
        return Column(
          children: [
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: children.sublist(0, children.length - 1),
            ),
            children.last,
          ],
        );
      }

      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: children,
      );
    }

    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: children,
    );
  }
}
