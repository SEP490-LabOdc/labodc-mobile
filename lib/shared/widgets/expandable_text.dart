import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  final int maxLines;
  final TextStyle? style;

  const ExpandableText({
    Key? key,
    required this.text,
    this.maxLines = 3,
    this.style,
  }) : super(key: key);

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isLong = widget.text.trim().replaceAll('\n', ' ').length > 150;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.text,
          maxLines: _isExpanded || !isLong ? null : widget.maxLines,
          overflow: _isExpanded || !isLong ? TextOverflow.visible : TextOverflow.ellipsis,
          style: widget.style ??
              const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
        ),
        if (isLong)
          TextButton(
            onPressed: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
            child: Text(
              _isExpanded ? 'Thu gọn' : 'Xem thêm',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
      ],
    );
  }
}
