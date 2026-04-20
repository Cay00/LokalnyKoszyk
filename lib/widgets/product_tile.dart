import 'package:flutter/material.dart';

class ProductData {
  const ProductData({
    required this.id,
    required this.name,
    required this.producer,
    required this.price,
    required this.unit,
    required this.distance,
    required this.season,
    required this.rating,
    required this.reviews,
    required this.emoji,
    required this.tag,
    required this.bgColor,
    required this.tagColor,
  });

  final String id;
  final String name;
  final String producer;
  final String price;
  final String unit;
  final String distance;
  final String season;
  final String rating;
  final String reviews;
  final String emoji;
  final String tag;
  final Color bgColor;
  final Color tagColor;
}

class ProductTile extends StatelessWidget {
  const ProductTile({
    super.key,
    required this.product,
    required this.isLiked,
    required this.onToggleLike,
    required this.onAddToCart,
  });

  final ProductData product;
  final bool isLiked;
  final VoidCallback onToggleLike;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAE6DE)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 160,
            width: double.infinity,
            color: product.bgColor,
            child: Stack(
              children: <Widget>[
                Center(
                  child: Text(
                    product.emoji,
                    style: const TextStyle(fontSize: 64),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: InkWell(
                    onTap: onToggleLike,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        isLiked ? '❤️' : '🤍',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding:
                        const EdgeInsets.only(left: 8, right: 8, top: 64, bottom: 16),
                    decoration: BoxDecoration(
                      color: product.tagColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      product.tag,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E3A2F),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            product.producer,
                            style: const TextStyle(
                              color: Color(0xFF8B8B8B),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          '${product.price} zł',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2F5D50),
                          ),
                        ),
                        Text(
                          product.unit,
                          style: const TextStyle(
                            color: Color(0xFF8B8B8B),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    _MetaChip(text: '📍 ${product.distance}'),
                    const SizedBox(width: 8),
                    _MetaChip(text: '📅 ${product.season}'),
                    const Spacer(),
                    const Text('⭐', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(
                      product.rating,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2A2A2A),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${product.reviews})',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8B8B8B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onAddToCart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A2F),
                      foregroundColor: const Color(0xFFF7F1E6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('+'),
                        SizedBox(width: 8),
                        Text(
                          'Dodaj do koszyka',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F0E8),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFF6F6F6F),
        ),
      ),
    );
  }
}
