import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_allianz/application/file_finder.dart';
import 'package:flutter_allianz/config/params.dart';
import 'package:flutter_allianz/data/services/file_service.dart';
import 'package:flutter_allianz/presentation/widgets/search_files_button.dart';

/// A widget to display a list of images from the application support directory
/// or from an external directory, with an option to search for and select images.
///
/// This widget allows users to view images in either a grid or list format, 
/// and interact with them by selecting an image. The selected image will be 
/// passed to the [onImageSelected] callback.
///
/// **Author**: Timo Gehrke
///
/// This widget supports the following features:
/// - Search for images from specified directories.
/// - Toggle between grid and list view for displaying images.
/// - Display loading indicator while images are being fetched.
/// - Show message when no images are found.
class ImageViewerSearchRow extends StatefulWidget {
  final Function(File) onImageSelected;
  const ImageViewerSearchRow({super.key, required this.onImageSelected});

  @override
  ImageViewerSearchRowState createState() => ImageViewerSearchRowState();
}

class ImageViewerSearchRowState extends State<ImageViewerSearchRow> {
  List<File> _imageList = [];
  bool _isLoading = true;
  bool _isGridView = true;

  /// This function updates the state of the widget and invokes the 
  /// [onImageSelected] callback passed to the widget with the selected 
  /// file, if the file path is valid.
  ///
  /// The [filePath] parameter is expected to be a non-null string containing
  /// the file path of the selected image. If [filePath] is not null and not empty, 
  /// it triggers the [onImageSelected] callback with the selected file.
  ///
  /// This function will be triggered when a user selects a file, typically
  /// from a file picker or a similar widget.
  ///
  /// Parameters:
  /// - [filePath]: A string containing the file path of the selected file.
  void _onFileSelected(String? filePath) {
    setState(() {
      if (filePath != null && filePath.isNotEmpty) {
        widget.onImageSelected(File(filePath));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  /// Loads images from a specified directory asynchronously.
  ///
  /// This function sets the loading state to `true` and attempts to load 
  /// image files from the directory specified by [Params.imageDirectory].
  /// It uses the [FileFinder] service to fetch the image files and updates 
  /// the widget's state with the retrieved files. Once the files are loaded, 
  /// it sets the loading state to `false` and updates the list of images.
  Future<void> _loadImages() async {
    setState(() {
      _isLoading = true;
    });

    final directoryPath = Params.imageDirectory!;
    final fileFinder = FileFinder(FileService());
    final files = await fileFinder.getImages(directoryPath);
    setState(() {
      _imageList = files;
      _isLoading = false;
    });
  }


  /// This function is responsible for updating the widget's state and 
  /// invoking the [onImageSelected] callback passed to the widget with the 
  /// selected image file.
  ///
  /// The [image] parameter is the file representing the selected image. 
  /// When this function is triggered, it passes the selected image to 
  /// the callback and updates the UI state accordingly.
  ///
  /// Parameters:
  /// - [image]: The file representing the selected image.
  void _onImageSelected(File image) {
    setState(() {
      widget.onImageSelected(image);
    });
  }


  /// This method constructs the main UI of the screen, starting with an 
  /// `AppBar` that includes a search button for selecting files and an 
  /// icon button to toggle between grid and list view. It also builds the 
  /// body of the screen, which displays either a loading spinner, a message 
  /// indicating no images are found, or the list of images depending on the 
  /// current state (`_isLoading`, `_imageList`, `_isGridView`).
  ///
  /// - If loading is in progress, a `CircularProgressIndicator` is shown.
  /// - If no images are found, a "No images found" message is displayed.
  /// - If images are available, they are displayed either in a grid view 
  ///   or a list view depending on the value of `_isGridView`.
  /// - Each image can be tapped to trigger the [_onImageSelected] callback.
  ///
  /// The layout adapts to the selected view mode:
  /// - **Grid View:** Displays images in a 2-column grid with 8.0px spacing.
  /// - **List View:** Displays images in a scrollable list with thumbnails and file names.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Expanded(
              flex: 2,
              child: SearchFilesButton(
                onFileSelected: _onFileSelected,
                extensions: Params.imageExtensions,
                ),
            ),
            const Spacer(),
            IconButton(
              icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
              onPressed: () {
                setState(() {
                  _isGridView = !_isGridView;
                });
              },
              tooltip:
                  _isGridView ? 'Switch to List View' : 'Switch to Grid View',
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(0),
          border: Border.all(
            color: Colors.grey,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            _isLoading
                ? const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _imageList.isEmpty
                    ? const Expanded(
                        child: Center(
                          child: Text(
                            'No images found',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                      )
                    : Expanded(
                        child: _isGridView
                            ? GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 8.0,
                                  mainAxisSpacing: 8.0,
                                  childAspectRatio: 1.0,
                                ),
                                itemCount: _imageList.length,
                                itemBuilder: (context, index) {
                                  final image = _imageList[index];
                                  return GestureDetector(
                                    onTap: () => _onImageSelected(image),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Image.file(
                                        image,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                },
                              )
                            : ListView.builder(
                                itemCount: _imageList.length,
                                itemBuilder: (context, index) {
                                  final image = _imageList[index];
                                  final fileName = image.path.split('/').last;
                                  return ListTile(
                                    onTap: () => _onImageSelected(image),
                                    title: Text(fileName),
                                    leading: Image.file(
                                      image,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    ),
                                  );
                                },
                              ),
                      ),
          ],
        ),
      ),
    );
  }
}
