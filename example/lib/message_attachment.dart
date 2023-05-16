import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// A class that represents additional space between messages.
@immutable
class AttachmentFile extends Equatable {
  const AttachmentFile({
    required this.uuid,
    required this.name,
    this.mimeType,
    required this.size,
    required this.uri,
  });

  /// Equatable props
  @override
  List<Object> get props => [uuid, name, size, uri];

  final String uuid;

  /// Media type
  final String? mimeType;

  /// The name of the file
  final String name;

  /// Size of the file in bytes
  final int size;

  /// The file source (either a remote URL or a local resource)
  final String uri;
}
