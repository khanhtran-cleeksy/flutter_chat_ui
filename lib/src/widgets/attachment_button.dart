import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

/// A class that represents attachment button widget
class AttachmentButton extends StatefulWidget {
  /// Creates attachment button widget
  const AttachmentButton({
    Key? key,
    this.showAddButton = false,
    this.showActionIcons = false,
    this.prefixInput = const <Widget>[],
    required this.onExpanded,
  }) : super(key: key);

  /// Callback for attachment button tap event
  final bool showAddButton;
  final bool showActionIcons;
  final List<Widget> prefixInput;
  final Function() onExpanded;

  @override
  State<AttachmentButton> createState() => _AttachmentButtonState();
}

class _AttachmentButtonState extends State<AttachmentButton> {
  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: SizedBox(
        height: 24,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              icon: widget.showAddButton
                  ? Image.asset(
                      'assets/icon_add.png',
                      height: 20,
                      width: 20,
                    )
                  : const Icon(
                      CupertinoIcons.chevron_down,
                      color: Color(0xff282E3E),
                      size: 20,
                    ),
              onPressed: () {
                FocusScope.of(context).unfocus();
                widget.onExpanded();
              },
            ),
            if (widget.showActionIcons) ...widget.prefixInput,
          ],
        ),
      ),
    );
  }
}
