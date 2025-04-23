import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_allianz/application/file_finder.dart';
import 'package:flutter_allianz/data/services/file_service.dart';

/// A widget that provides a button to search for and select a file.
///
/// This widget is used to display a button that, when pressed, opens a file picker 
/// for the user to select a file. It is capable of filtering the files displayed in 
/// the file picker based on the specified file extensions.
///
/// **Author**: Timo Gehrke
class SearchFilesButton extends StatefulWidget{
  final Function(String?) onFileSelected;
  final List<String> extensions; 
  final IconData icon;

  const SearchFilesButton({
    super.key, 
    required this.onFileSelected, 
    required this.extensions, 
    this.icon = Icons.search});

  @override
  State<StatefulWidget> createState() => _SearchFileButtonState();
}

/// The state for the [SearchFilesButton] widget, responsible for opening the file picker 
/// and handling the file selection process.
class _SearchFileButtonState extends State<SearchFilesButton> {
  File? _selectedFile;

  /// Opens the file picker and allows the user to select a file.
  ///
  /// This method calls a file picker service, filters files based on the provided 
  /// extensions, and notifies the parent widget of the selected file (if any).
  Future<void> _openFilePicker() async {
    try {
      final List<String> extensionsWithoutDot = widget.extensions.map((ext) {
        return ext.startsWith('.') ? ext.substring(1) : ext;
      }).toList();

      final FileFinder fileFinder = FileFinder(FileService());
      _selectedFile = await fileFinder.openFilePicker(extensions: extensionsWithoutDot);

      if(_selectedFile != null) {
        setState(() {
          });
          widget.onFileSelected(_selectedFile!.path);
      } else {
        widget.onFileSelected(null);
      }
    } catch (e) {
      debugPrint('Failed to load file picker: $e');
    } 
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _openFilePicker, 
      icon: const Icon(Icons.search),
      tooltip: 'Search File',
    );
  }
}
