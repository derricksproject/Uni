import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_allianz/config/params.dart';
import 'package:flutter_allianz/data/services/file_service.dart';

/// A utility class for finding and selecting files using [FileService].
///
/// Provides methods for finding files in a directory, retrieving images with specified extensions
/// and opening a file picker for user selection.
/// 
/// **Author**: Timo Gehrke
class FileFinder {
  final FileService fileService;
  FileFinder(this.fileService);
  
  /// Retrieves files from a directory at [directoryPath] that match [extensions]
  /// 
  /// Parameters:
  /// - [directoryPath]: The path of the directory to search.
  /// - [extensions]: A list of file extensions to filter files. (e.g., `['.jpg', '.png']`).
  /// Return:
  /// - A list of [File] objects that match the specified extensions.
  Future<List<File>> getFiles(String directoryPath, List<String> extensions) async {
    List<File> files;

    if (directoryPath.isEmpty) {
      debugPrint('Image directory is not defined.');
      files = [];
    }

    try {
      files = await fileService.findFiles(directoryPath, extensions);
    } catch (e) {
      files = [];
    } 
    return files;
  }
  
  /// Retrieves image files from the directory at [directoryPath].
  /// 
  /// This method specifically uses the image extensions defined in [Params.imageExtensions]
  /// 
  /// Return:
  /// - A list of image [File] objects, or an emtpy list if none are found.
  Future<List<File>> getImages(String directoryPath) async {
    return await getFiles(directoryPath, Params.imageExtensions);
  }

  /// Opens a file picker dialog to allow the user to select a file.
  /// 
  /// If [extensions] is provided, the file picker will filter files based on the allowed extensions.
  /// If no etensions are provided, the file picker will allow any file type.
  /// 
  /// Parameters:
  /// - [extensions]: An optional list of allowed extensions (e.g., `['txt', 'json']`).
  /// 
  /// Returns:
  /// - The selected [File], or `null` if no file was selected or an error occurred.
  Future<File?> openFilePicker({List<String>? extensions}) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Select a file',
        allowMultiple: false,
        type: extensions != null && extensions.isNotEmpty
          ? FileType.custom
          : FileType.any,
        allowedExtensions: extensions,
      );

      if (result != null && result.files.isNotEmpty) {
        return File(result.files.single.path!);
      }
      else {
        return null;
      }
    } catch (e) {
      debugPrint('Error while opening the file: $e');
      return null;
    }
  }
}