import 'package:flutter/material.dart';

/// A class that represents attachment button widget
class AttachmentButton extends StatefulWidget {
  /// Creates attachment button widget
  const AttachmentButton({
    Key? key,
    this.hasFocusInput = false,
    this.prefixInput = const <Widget>[],
    required this.onTapAttachment,
    required this.onTapAddAttachment,
  }) : super(key: key);

  /// Callback for attachment button tap event
  final bool hasFocusInput;
  final List<Widget> prefixInput;
  final Function() onTapAttachment;
  final Function() onTapAddAttachment;

  @override
  State<AttachmentButton> createState() => _AttachmentButtonState();
}

class _AttachmentButtonState extends State<AttachmentButton> {
  ValueNotifier<bool> isTapAttachment = ValueNotifier(false);

  void updateIconButton() {
    if (widget.hasFocusInput && isTapAttachment.value) {
      isTapAttachment.value = !isTapAttachment.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    updateIconButton();
    return IntrinsicWidth(
      child: SizedBox(
        height: 24,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ValueListenableBuilder(
              valueListenable: isTapAttachment,
              builder: (_, bool hasTapAttachment, __) {
                return IconButton(
                  padding: EdgeInsets.zero,
                  icon: hasTapAttachment
                      ? const Icon(
                          Icons.expand_more,
                          color: Color(0xff282E3E),
                        )
                      : Image.asset(
                          'assets/icon_add.png',
                          color: const Color(0xff282E3E),
                          package: 'flutter_chat_ui',
                        ),
                  onPressed: () {
                    widget.onTapAddAttachment() ?? () {};
                    isTapAttachment.value = !isTapAttachment.value;
                    widget.onTapAttachment();
                  },
                );
              },
            ),
            if (!widget.hasFocusInput) ...widget.prefixInput,
          ],
        ),
      ),
    );
  }
}
