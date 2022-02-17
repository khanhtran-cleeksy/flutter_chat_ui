import 'package:flutter/material.dart';
import 'inherited_chat_theme.dart';
import 'inherited_l10n.dart';

/// A class that represents send button widget
class SendButton extends StatelessWidget {
  /// Creates send button widget
  const SendButton({
    Key? key,
    required this.onPressed,
    this.isActive = false,
  }) : super(key: key);

  /// Callback for send button tap event
  final void Function() onPressed;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      margin: const EdgeInsets.only(left: 16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xffF3F5F9) : const Color(0xff2C56EA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: InheritedChatTheme.of(context).theme.sendButtonIcon != null
            ? InheritedChatTheme.of(context).theme.sendButtonIcon!
            : Image.asset(
                'assets/chat_icon_send.png',
                color: isActive ? Colors.grey : Colors.white,
                package: 'flutter_chat_ui',
              ),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        tooltip: InheritedL10n.of(context).l10n.sendButtonAccessibilityLabel,
      ),
    );
  }
}
