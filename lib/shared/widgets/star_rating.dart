import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final int rating;
  final ValueChanged<int>? onRatingChanged;
  final double size;
  final Color activeColor;
  final Color inactiveColor;

  const StarRating({
    super.key,
    required this.rating,
    this.onRatingChanged,
    this.size = 40,
    this.activeColor = const Color(0xFFFFB800),
    this.inactiveColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        return GestureDetector(
          onTap: onRatingChanged != null
              ? () => onRatingChanged!(starIndex)
              : null,
          child: Icon(
            starIndex <= rating ? Icons.star : Icons.star_border,
            size: size,
            color: starIndex <= rating ? activeColor : inactiveColor,
          ),
        );
      }),
    );
  }
}
