/// A class representing a data stream associated with a specific topic.
///
/// The [StreamWithTopic] class encapsulates a [Stream] of type `double`
/// and its corresponding [topic]. It also includes a utility method to
/// standardize topic names by replacing specific numeric patterns with placeholders.
/// 
/// **Author**: Timo Gehrke
class StreamWithTopic {
  String topic;
  Stream<double> stream;

  StreamWithTopic(this.topic,this.stream);

  /// Replaces specific numeric patterns in the [topic] with standardized placeholders.
  ///
  /// - Replaces occurrences of `board` followed by digits with `boardX`.
  /// - Replaces occurrences of `pbr` followed by digits with `pbrX`.
  /// - Replaces occurrences of digits followed by `_am` with `X_am`.
  ///
  /// Parameters:
  /// - [topic]: The original topic string.
  ///
  /// Returns:
  /// A new string with numeric patterns replaced by placeholders.
  String replaceNumbers (String topic) {
    return topic.replaceAll(RegExp(r'board\d+'), 'boardX')
             .replaceAll(RegExp(r'pbr\d+'), 'pbrX')
             .replaceAll(RegExp(r'\d+_am'), 'X_am');
  }
}