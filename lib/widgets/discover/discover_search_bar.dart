import 'package:flutter/material.dart';

class AppSearchBar extends StatelessWidget {
  const AppSearchBar({
    super.key,
    required this.placeholder,
    this.trailing,
  });

  final String placeholder;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEAE6DE)),
      ),
      child: Row(
        children: <Widget>[
          const Opacity(
            opacity: 0.4,
            child: Text('🔍', style: TextStyle(fontSize: 14)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              placeholder,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF8B8B8B),
              ),
            ),
          ),
          if (trailing != null) ...<Widget>[
            const SizedBox(width: 10),
            trailing!,
          ],
        ],
      ),
    );
  }
}

class DiscoverSearchBar extends StatelessWidget {
  const DiscoverSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppSearchBar(
      placeholder: 'Szukaj produktow...',
    );
  }
}
