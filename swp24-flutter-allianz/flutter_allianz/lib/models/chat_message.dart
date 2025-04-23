import 'dart:convert';
import 'dart:io';

import 'package:flutter_allianz/config/params.dart';
/// A class representing a chat message, which can include optional file attachments.
///
/// **Author**: Timo Gehrke 
class ChatMessage {
  /// The timestamp of the message.
  final String time;

  /// The user who sent the message.
  final String user;

  /// The content of the message.
  final String message;

  /// The file attached to the message, if any.
  final File? file;

  /// The name of the attached file, derived from the file path.
  final String? fileName;

  /// Constructor to create a [ChatMessage] instance.
  ///
  /// **Parameters:**
  /// - `user`: The user who sent the message.
  /// - `message`: The text content of the message.
  /// - `time`: The timestamp when the message was sent.
  /// - `file`: An optional file attached to the message.
  ChatMessage(this.user, this.message, this.time, {this.file})
      : fileName = file?.path.split('/').last;

  /// Converts the [ChatMessage] to a JSON representation.
  ///
  /// **Returns:** A map with `time`, `user`, `message`, `fileName`, and `fileContent`.
  Map<String, dynamic> toJson() {
    String? fileContent;
    if (file != null) {
      fileContent = base64Encode(file!.readAsBytesSync());
    }
    return {
      'time': time,
      'user': user,
      'message': message,
      'fileName': fileName,
      'fileContent': fileContent,
    };
  }

  /// Creates a [ChatMessage] instance from a JSON map.
  ///
  /// Parameters:
  /// - [json]: A map containing serialized data for a [ChatMessage].
  /// - [basePath]: The base directory for saving non-image files.
  /// - [imageDirectory]: The directory for saving image files.
  /// - [imageExtensions]: A list of file extensions considered as images.
  ///
  /// Returns:
  /// A [ChatMessage] instance reconstructed from the JSON data.
  static ChatMessage fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      json['user'],
      json['message'],
      json['time'],
      file: json['fileContent'] != null
          ? _createFile(json['fileName'], json['fileContent'])
          : null,
    );
  }

  /// Returns a string representation of the [ChatMessage].
  ///
  /// **Returns:** A string formatted as `"time user: message"`.
  @override
  String toString() {
    return "$time $user: $message";
  }

  /// Generates a map with `time`, `user`, `message`, and `filePath` (if a file is attached).
  ///
  /// **Returns:** A map containing the message details.
  Map<String, dynamic> mesgForFile() {
    String? filePath;
    if (file != null) {
      filePath = file?.path;
    }

    Map<String, dynamic> mapMesg = {
      'time': time,
      'user': user,
      'message': message,
      'filePath': filePath,
    };
    return mapMesg;
  }
  
  /// Creates a [ChatMessage] instance from a map containing a file path instead of file content.
  ///
  /// **Parameters:**
  /// - `json`: A map containing `time`, `user`, `message`, and `filePath`.
  ///
  /// **Returns:** A [ChatMessage] instance.
  static ChatMessage mesgFromFile(Map<String, dynamic> json) {
    return ChatMessage(
      json['user'],
      json['message'],
      json['time'],
      file: json['filePath'] != null ? File(json['filePath']) : null,
    );
  }

  /// Creates a file from the given [fileName] and [fileContent].
  ///
  /// Parameters:
  /// - [fileName]: The name of the file to create.
  /// - [fileContent]: The Base64-encoded content of the file.
  ///
  /// Returns:
  /// A [File] object representing the created file.
  static File _createFile(String? fileName, String fileContent) {
    String filePath = '${Params.filePath!}/${fileName!}';
    // Check if file is image
    if (Params.imageExtensions.any((value) => fileName.endsWith(value))) {
      filePath = '${Params.imageDirectory!}/$fileName';
    }

    final file = File(filePath);
    file.writeAsBytesSync(base64Decode(fileContent));
    return file;
  }
}
