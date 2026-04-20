import 'package:flutter/material.dart';

class CategoryTile extends StatelessWidget {
  const CategoryTile({
    super.key,
    required this.icon,
    required this.name,
    required this.count,
    required this.active,
    required this.onTap,
  });

  final String icon;
  final String name;
  final int count;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        constraints: const BoxConstraints(minWidth: 68),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF1E3A2F) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: active ? const Color(0xFF1E3A2F) : const Color(0xFFE8E4DC),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: active ? const Color(0x401C3A2A) : const Color(0x12000000),
              blurRadius: active ? 12 : 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: <Widget>[
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(
              name,
              style: TextStyle(
                fontSize: 12,
                color:
                    active ? const Color(0xFFF7F1E6) : const Color(0xFF6F6F6F),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$count prod.',
              style: TextStyle(
                fontSize: 10,
                color:
                    active ? const Color(0xFFC6D8BC) : const Color(0xFF8B8B8B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
