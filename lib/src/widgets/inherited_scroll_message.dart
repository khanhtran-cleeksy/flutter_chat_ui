import 'package:flutter/widgets.dart';

class InheritedScrollMessage extends InheritedWidget {
  const InheritedScrollMessage({
    Key? key,
    required this.onScrollLatestMessage,
    required Widget child,
  }) : super(key: key, child: child);

  /// Function to scroll latest message
  final Function(bool) onScrollLatestMessage;

  static InheritedScrollMessage of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<InheritedScrollMessage>()!;
  }

  @override
  bool updateShouldNotify(InheritedScrollMessage oldWidget) =>
      onScrollLatestMessage.hashCode !=
      oldWidget.onScrollLatestMessage.hashCode;
}
