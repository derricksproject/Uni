import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_allianz/presentation/widgets/image_viewer_search_row.dart';


/// This widget allows users to select an image using the [ImageViewerSearchRow],
/// and view or interact with the selected image. The image can be zoomed, panned, 
/// or reset if no image is selected. The widget manages the state of the selected 
/// image and displays a message when no image is selected.
///
/// **Author**: Timo Gehrke
class ImageViewer extends StatefulWidget {
  const ImageViewer({super.key});

  @override
  ImageViewerState createState() => ImageViewerState();
}

class ImageViewerState extends State<ImageViewer> {
  /// The file representing the selected image.
  /// Initially, no image is selected.
  File? _imageFile;

  @override
  void initState() {
    super.initState();
  }

  /// Callback function to update the selected image.
  /// 
  /// This function is triggered when an image is selected from the search row. 
  /// It updates the `_imageFile` with the new selected image.
  ///
  /// Parameters:
  /// - [image]: The selected image file.
  void _onImageSelected(File image) {
    setState(() {
      _imageFile = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SizedBox(width: 150, child: ImageViewerSearchRow(onImageSelected: _onImageSelected)),
          Expanded(
            flex: 12,
            child: Center(
              child: _imageFile != null
                  ? InteractiveViewer(
                      panEnabled: true,
                      minScale: 0.1,
                      maxScale: 4.0,
                      child: Image.file(_imageFile!),
                    )
                  : const Text(
                      'No image selected.',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
