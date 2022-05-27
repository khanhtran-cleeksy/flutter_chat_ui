import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:intl/intl.dart';
import '../models/send_button_visibility_mode.dart';
import 'attachment_button.dart';
import 'inherited_chat_theme.dart';
import 'inherited_l10n.dart';
import 'send_button.dart';

class NewLineIntent extends Intent {
  const NewLineIntent();
}

class SendMessageIntent extends Intent {
  const SendMessageIntent();
}

/// A class that represents bottom bar widget with a text field, attachment and
/// send buttons inside. By default hides send button when text field is empty.
class Input extends StatefulWidget {
  /// Creates [Input] widget
  const Input({
    Key? key,
    this.isAttachmentUploading,
    this.prefixInput = const [],
    this.disableInput = false,
    this.isEmojiVisible = false,
    required this.onSendPressed,
    this.autofocus = false,
    this.showFooter = false,
    this.onTextChanged,
    this.onTextFieldTap,
    required this.sendButtonVisibilityMode,
    required this.inputContent,
    required this.hasFocusCallBack,
    required this.onExpanded,
  }) : super(key: key);

  final bool? disableInput;

  final bool isEmojiVisible;
  final bool autofocus;
  final bool showFooter;

  final List<Widget> prefixInput;

  /// Whether attachment is uploading. Will replace attachment button with a
  /// [CircularProgressIndicator]. Since we don't have libraries for
  /// managing media in dependencies we have no way of knowing if
  /// something is uploading so you need to set this manually.
  final bool? isAttachmentUploading;

  /// Will be called on [SendButton] tap. Has [types.PartialText] which can
  /// be transformed to [types.TextMessage] and added to the messages list.
  final void Function(types.PartialText) onSendPressed;

  /// Will be called whenever the text inside [TextField] changes
  final void Function(String)? onTextChanged;

  /// Will be called on [TextField] tap
  final void Function()? onTextFieldTap;

  final void Function(bool) hasFocusCallBack;

  /// Controls the visibility behavior of the [SendButton] based on the
  /// [TextField] state inside the [Input] widget.
  /// Defaults to [SendButtonVisibilityMode.editing].
  final SendButtonVisibilityMode sendButtonVisibilityMode;

  final String inputContent;

  final Function() onExpanded;

  @override
  _InputState createState() => _InputState();
}

/// [Input] widget state
class _InputState extends State<Input> {
  final _inputFocusNode = FocusNode();
  bool _sendButtonVisible = false;
  final _textController = TextEditingController();
  ValueNotifier<int> lengthTextNotifier = ValueNotifier(0);
  ValueNotifier<bool> isEmojiVisibleNotifier = ValueNotifier(true);
  bool hasFocusNotifier = false;
  bool hasInput = false;
  static const LIMIT_CHARACTER = 2000;
  static const START_SHOW_LIMIT = 100;

  @override
  void initState() {
    super.initState();
    hasInput = widget.inputContent.isNotEmpty;

    if (widget.inputContent
        .trim()
        .isNotEmpty) {
      _textController.clear();
      _textController.text = widget.inputContent;
    }

    if (widget.sendButtonVisibilityMode == SendButtonVisibilityMode.editing) {
      _sendButtonVisible = _textController.text.trim() != '';
      _textController.addListener(_handleTextControllerChange);
    } else {
      _sendButtonVisible = true;
    }

    _inputFocusNode.addListener(() {
      final hasFocusInput = _inputFocusNode.hasFocus;
      setState(() {
        hasFocusNotifier = hasFocusInput;
      });
      widget.hasFocusCallBack(hasFocusInput);
    });
  }

  @override
  void didUpdateWidget(covariant Input oldWidget) {
    setState(() {
      hasInput = widget.inputContent.isNotEmpty;
    });
    if (widget.sendButtonVisibilityMode == SendButtonVisibilityMode.editing) {
      _sendButtonVisible = _textController.text.trim() != '';
      _textController.addListener(_handleTextControllerChange);
    } else {
      _sendButtonVisible = true;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _inputFocusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _handleSendPressed() {
    lengthTextNotifier.value = 0;
    final trimmedText = _textController.text.trim();

    if (_sendButtonVisible || trimmedText != '') {
      final _partialText = types.PartialText(text: trimmedText);
      widget.onSendPressed(_partialText);
      _textController.clear();
    }
  }

  void _handleTextControllerChange() {
    setState(() {
      _sendButtonVisible = _textController.text
          .trim()
          .isNotEmpty;
    });
  }

  Widget _leftWidget(bool hasFocusInput) {
    if (widget.isAttachmentUploading == true) {
      return Container(
        height: 24,
        margin: const EdgeInsets.only(right: 16),
        width: 24,
        child: CircularProgressIndicator(
          backgroundColor: Colors.transparent,
          strokeWidth: 1.5,
          valueColor: AlwaysStoppedAnimation<Color>(
            InheritedChatTheme
                .of(context)
                .theme
                .inputTextColor,
          ),
        ),
      );
    } else {
      return AttachmentButton(
        prefixInput: widget.prefixInput,
        onExpanded: widget.onExpanded,
        showAddButton: !widget.showFooter,
        showActionIcons: !widget.showFooter && !hasFocusNotifier &&
            !hasInput,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final _query = MediaQuery.of(context);
    if (_textController.text.isNotEmpty) {
      lengthTextNotifier.value = _textController.text.length;
    }
    return GestureDetector(
      onTap: () => _inputFocusNode.requestFocus(),
      child: Shortcuts(
        shortcuts: {
          LogicalKeySet(LogicalKeyboardKey.enter): const SendMessageIntent(),
          LogicalKeySet(LogicalKeyboardKey.enter, LogicalKeyboardKey.alt):
          const NewLineIntent(),
          LogicalKeySet(LogicalKeyboardKey.enter, LogicalKeyboardKey.shift):
          const NewLineIntent(),
        },
        child: Actions(
          actions: {
            SendMessageIntent: CallbackAction<SendMessageIntent>(
              onInvoke: (SendMessageIntent intent) => _handleSendPressed(),
            ),
            NewLineIntent: CallbackAction<NewLineIntent>(
              onInvoke: (NewLineIntent intent) {
                final _newValue = '${_textController.text}\r\n';
                _textController.value = TextEditingValue(
                  text: _newValue,
                  selection: TextSelection.fromPosition(
                    TextPosition(offset: _newValue.length),
                  ),
                );
              },
            ),
          },
          child: Padding(
            padding: InheritedChatTheme
                .of(context)
                .theme
                .inputPadding,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    20 + _query.padding.left,
                    5,
                    20 + _query.padding.right,
                    5 + _query.viewInsets.bottom + _query.padding.bottom,
                  ),
                  child: ValueListenableBuilder(
                    valueListenable: lengthTextNotifier,
                    builder: (context, int length, __) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (widget.prefixInput.isNotEmpty)
                            _leftWidget(length != 0),
                          Expanded(
                            child: Material(
                              color: Colors.white,
                              borderRadius: InheritedChatTheme
                                  .of(context)
                                  .theme
                                  .inputBorderRadius,
                              child: TextField(
                                autofocus: widget.autofocus,
                                readOnly: widget.disableInput!,
                                controller: _textController,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  suffixIcon: Visibility(
                                    visible: widget.isEmojiVisible,
                                    child: ValueListenableBuilder(
                                      valueListenable: isEmojiVisibleNotifier,
                                      builder: (BuildContext context,
                                          bool isEmojiVisible, __) {
                                        return IconButton(
                                          icon: Icon(
                                            Icons.emoji_emotions,
                                            color: isEmojiVisible
                                                ? Colors.grey
                                                : const Color(0xff2C56EA)
                                                .withOpacity(0.75),
                                          ),
                                          onPressed: () {
                                            isEmojiVisibleNotifier.value =
                                            !isEmojiVisibleNotifier.value;
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.all(12.0),
                                  hintStyle: InheritedChatTheme
                                      .of(context)
                                      .theme
                                      .inputTextStyle
                                      .copyWith(
                                    color: InheritedChatTheme
                                        .of(context)
                                        .theme
                                        .inputTextColor
                                        .withOpacity(0.5),
                                  ),
                                  hintText: InheritedL10n
                                      .of(context)
                                      .l10n
                                      .inputPlaceholder,
                                ),
                                focusNode: _inputFocusNode,
                                keyboardType: TextInputType.multiline,
                                maxLines: 5,
                                minLines: 1,
                                onChanged: (content) {
                                  if (content.isNotEmpty) {
                                    lengthTextNotifier.value = content.length;
                                  } else {
                                    lengthTextNotifier.value = 0;
                                  }
                                  if (widget.onTextChanged != null) {
                                    widget.onTextChanged!(content);
                                  }
                                },
                                onTap: widget.onTextFieldTap,
                                style: InheritedChatTheme
                                    .of(context)
                                    .theme
                                    .inputTextStyle
                                    .copyWith(
                                  color: InheritedChatTheme
                                      .of(context)
                                      .theme
                                      .inputTextColor,
                                ),
                                textCapitalization:
                                TextCapitalization.sentences,
                              ),
                            ),
                          ),
                          ValueListenableBuilder(
                            valueListenable: lengthTextNotifier,
                            builder: (_, int lengthText, __) {
                              return Column(
                                children: [
                                  Visibility(
                                    visible: lengthText >= START_SHOW_LIMIT,
                                    child: Container(
                                      height: 24,
                                      padding: const EdgeInsets.only(left: 14),
                                      alignment: Alignment.centerRight,
                                      child: FittedBox(
                                        child: Text(
                                          '${NumberFormat.decimalPattern()
                                              .format(
                                              lengthText)} / ${NumberFormat
                                              .decimalPattern().format(
                                              LIMIT_CHARACTER)}',
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: lengthText <= LIMIT_CHARACTER
                                                ? const Color(0xffA1A9BB)
                                                : const Color(0xffCE2B10),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Visibility(
                                    visible: _sendButtonVisible,
                                    child: SendButton(
                                      isActive: lengthText > LIMIT_CHARACTER,
                                      onPressed: lengthText <= LIMIT_CHARACTER
                                          ? _handleSendPressed
                                          : () {},
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
                ValueListenableBuilder(
                  valueListenable: isEmojiVisibleNotifier,
                  builder: (BuildContext context, bool isEmojiVisible, __) {
                    return Offstage(
                      offstage: isEmojiVisible,
                      child: SizedBox(
                        height: 250,
                        child: EmojiPicker(
                          onEmojiSelected: (category, emoji) {
                            _textController.text =
                                _textController.text + emoji.emoji;
                            _textController.selection =
                                TextSelection.fromPosition(TextPosition(
                                    offset: _textController.text.length));
                          },
                          onBackspacePressed: () {
                            _inputFocusNode.unfocus();
                            FocusManager.instance.primaryFocus?.unfocus();
                            isEmojiVisibleNotifier.value = true;
                          },
                          config: const Config(
                            columns: 7,
                            verticalSpacing: 0,
                            horizontalSpacing: 0,
                            initCategory: Category.SMILEYS,
                            bgColor: Color(0xFFFFFFFF),
                            indicatorColor: Color(0xff2C56EA),
                            iconColor: Colors.grey,
                            iconColorSelected: Color(0xff2C56EA),
                            progressIndicatorColor: Color(0xff2C56EA),
                            showRecentsTab: true,
                            recentsLimit: 28,
                            // noRecentsText: "No Recents",
                            // noRecentsStyle: TextStyle(
                            //   fontSize: 20,
                            //   color: Colors.black26,
                            // ),
                            tabIndicatorAnimDuration: kTabScrollDuration,
                            categoryIcons: CategoryIcons(),
                            buttonMode: ButtonMode.MATERIAL,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
