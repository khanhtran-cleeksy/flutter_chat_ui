import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

import 'message_attachment.dart';

class AttachmentList extends StatefulWidget {
  const AttachmentList(
      {Key? key,
      required this.initialData,
      required this.onUpdate,
      this.onAttachmentTap,
      this.onAddMore})
      : super(key: key);

  final List<AttachmentFile> initialData;
  final Function(List<AttachmentFile>) onUpdate;
  final Function(AttachmentFile)? onAttachmentTap;
  final Function()? onAddMore;

  @override
  _AttachmentListState createState() => _AttachmentListState();
}

class _AttachmentListState extends State<AttachmentList> {
  List<AttachmentFile> _attachments = [];

  @override
  void initState() {
    setState(() {
      _attachments = widget.initialData;
    });
    super.initState();
  }

  @override
  void didUpdateWidget(covariant AttachmentList oldWidget) {
    setState(() {
      _attachments = widget.initialData;
    });
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          constraints: const BoxConstraints(maxHeight: 150),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: Scrollbar(
              child: GridView.extent(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                maxCrossAxisExtent: 130,
                children: [
                  ...List.generate(_attachments.length, (index) {
                    final item = _attachments[index];
                    return _buildAttachmentItem(item);
                  }).toList(),
                  if (widget.onAddMore != null) _buildAddItemButton(),
                ],
              ),
            ),
          ),
        ),
        const Divider(thickness: 0.5, height: 0),
      ],
    );
  }

  Widget _buildAddItemButton() {
    return GestureDetector(
      onTap: widget.onAddMore,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.7),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.add,
          size: 30,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildFilePreview(AttachmentFile attachment) {
    if ([
      'image/apng',
      'image/avif',
      'image/gif',
      'image/jpeg',
      'image/png',
      'image/webp'
    ].contains(attachment.mimeType)) {
      return SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Image.file(
          File(attachment.uri),
          fit: BoxFit.cover,
        ),
      );
    } else {
      return Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(8.0),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.insert_drive_file_outlined,
              size: 25,
              color: Colors.grey,
            ),
            const SizedBox(height: 2),
            Expanded(
              child: Text(
                attachment.name,
                maxLines: 2,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              attachment.size.formatSize,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildAttachmentItem(AttachmentFile attachment) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: GestureDetector(
              onTap: () {
                if (widget.onAttachmentTap != null) {
                  widget.onAttachmentTap!(attachment);
                }
              },
              child: _buildFilePreview(attachment),
            ),
          ),
          Positioned(
            top: 5,
            right: 5,
            child: Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: const Color(0xffF3F4F7)),
              ),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _attachments.removeWhere((_) => _.uuid == attachment.uuid);
                  });
                  widget.onUpdate(_attachments);
                },
                child: const Icon(Icons.close, size: 20),
              ),
            ),
          )
        ],
      ),
    );
  }
}

extension IntegerExtend on int? {
  String get formatSize {
    if (this! <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(this!) / log(1024)).floor();
    return ((this! / pow(1024, i)).toStringAsFixed(2)) + suffixes[i];
  }
}
