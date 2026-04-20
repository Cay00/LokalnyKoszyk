import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
  });

  final String title;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E3A2F),
            ),
          ),
        ),
        if (actionLabel != null)
          Text(
            actionLabel!,
            style: const TextStyle(
              color: Color(0xFF4A7C59),
              fontSize: 12,
            ),
          ),
      ],
    );
  }
}
