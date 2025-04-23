import 'dart:convert';
import 'dart:io';

/// Class for saving, loading, and managing files.
/// 
/// **Author**: Timo Gehrke
class FileService {

  /// Saves a given map [input] as a JSON file to the specified [filePath].
  ///
  /// Converts the [input] map into a JSON string and writes it to the file at
  /// [filePath]. If the file does not exist, it will be created.
  /// 
  /// Throws an [IOException] if the file cannot be written.
  Future<void> saveAsJson(Map<String, dynamic> input, String filePath) async {
    String jsonString = jsonEncode(input);
    final file = File(filePath);
    await file.writeAsString(jsonString);
  }

  /// Loads the content of a JSON file located at [filePath] and returns it as a string.
  ///
  /// If the file exists, its content will be returned as a string. If the file
  /// does not exist or an error occurs during reading, 'null' is returned.
  Future<String?> loadJson(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      try {
        String jsonString = await file.readAsString();
        return jsonString;
      } catch (e) {
        return null;
      }
    } else {
      return null;
    }
  }

  /// Searches the directory at [directoryPath] for files with one of the specified [extensions]
  /// 
  /// Returns:
  /// - A list of [File] objects matching the allowed extensions.
  /// - An empty list if the directory does not exist or no matching files are found.
  Future<List<File>> findFiles(String directoryPath, List<String> extensions) async {
    final directory = Directory(directoryPath);
    if (await directory.exists()) {
      return directory
          .listSync()
          .whereType<File>()
          .where((file) {
            final path = file.path.toLowerCase();
            return extensions.any((ext) => path.endsWith(ext));
          })
          .toList();
    } else {
      return [];
    }
  }
}
