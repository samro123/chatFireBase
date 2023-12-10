import 'dart:io';
import 'package:chatfirebase/main.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
class EmojiShow extends StatelessWidget {
  final textControler;
  const EmojiShow({Key? key, required this.textControler}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: mq.height * .35,
      child: EmojiPicker(
        textEditingController: textControler, // pass here the same [TextEditingController] that is connected to your input field, usually a [TextFormField]
        config: Config(
          columns: 8,
          initCategory: Category.FOODS,
          emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0), // Issue: https://github.com/flutter/flutter/issues/28894

        ),
      ),
    );
  }
}
