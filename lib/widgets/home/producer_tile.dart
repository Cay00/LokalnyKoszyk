import 'package:flutter/material.dart';

class ProducerTile extends StatelessWidget {
  const ProducerTile({
    super.key,
    required this.name,
    required this.type,
    required this.distance,
    required this.verified,
  });

  final String name;
  final String type;
  final String distance;
  final bool verified;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAE6DE)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFDCE9D8),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: const Text('🌾', style: TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1E3A2F),
                      ),
                    ),
                    if (verified) ...<Widget>[
                      const SizedBox(width: 8),
                      const Text('✅', style: TextStyle(fontSize: 14)),
                    ],
                  ],
                ),
                Text(
                  '$type · $distance',
                  style: const TextStyle(
                    color: Color(0xFF8B8B8B),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Text(
            '›',
            style: TextStyle(
              color: Color(0xFF4A7C59),
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
