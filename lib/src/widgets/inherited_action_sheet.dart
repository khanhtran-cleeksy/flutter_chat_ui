import 'package:flutter/widgets.dart';

class InheritedActionSheet extends InheritedWidget {
  const InheritedActionSheet({
    Key? key,
    required this.onPressedAddNew,
    required Widget child,
  }) : super(key: key, child: child);

  /// Function to scroll latest message
  final Function() onPressedAddNew;

  static InheritedActionSheet of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<InheritedActionSheet>()!;
  }

  @override
  bool updateShouldNotify(InheritedActionSheet oldWidget) =>
      onPressedAddNew.hashCode != oldWidget.onPressedAddNew.hashCode;
}
