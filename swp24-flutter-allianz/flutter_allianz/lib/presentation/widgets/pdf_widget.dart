import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_allianz/config/params.dart';
import 'package:pdfrx/pdfrx.dart';  

/// A StatefulWidget that provides a PDF viewer.
/// The widget can either load a PDF from a provided file path or allow the user to select a PDF file to view.
/// 
/// **Author**: Gagan Lal
class PDFViewerWidget extends StatefulWidget {
  /// The file path of the PDF to be displayed.
  /// This parameter can be null, in which case the user can load a PDF file via a file picker.
  final String? pdfPath;

  const PDFViewerWidget({super.key, this.pdfPath});

  @override
  State<PDFViewerWidget> createState() => _PDFViewerWidgetState();
}

class _PDFViewerWidgetState extends State<PDFViewerWidget> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Viewer'),
        centerTitle: true,
        leading: widget.pdfPath != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: () async {
              final result = await FilePicker.platform.pickFiles(
                initialDirectory: Params.imageDirectory,
                type: FileType.custom,
                allowedExtensions: ['pdf'],
              );
              if (result != null && result.files.single.path != null) {
                Navigator.push(
                  // ignore: use_build_context_synchronously
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PDFViewerWidget(pdfPath: result.files.single.path),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: widget.pdfPath == null
          ? const Center(child: Text('Please load a file.'))
          : Column(
              children: [
                Expanded(
                  child: PdfViewer.file(
                    widget.pdfPath!, 
                  ),
                ),
              ],
            ),
    );
  }
}
