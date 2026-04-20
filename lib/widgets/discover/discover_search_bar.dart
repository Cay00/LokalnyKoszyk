import 'package:flutter/material.dart';

class DiscoverSearchBar extends StatelessWidget {
  const DiscoverSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEAE6DE)),
      ),
      child: const Row(
        children: <Widget>[
          Opacity(
            opacity: 0.4,
            child: Text('🔍', style: TextStyle(fontSize: 14)),
          ),
          SizedBox(width: 8),
          Text(
            'Szukaj produktow...',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF8B8B8B),
            ),
          ),
        ],
      ),
    );
  }
}
