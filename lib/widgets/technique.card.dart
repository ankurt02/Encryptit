import 'package:flutter/material.dart';

class CryptoTechniqueCard extends StatelessWidget {
  final String title;
  final bool isSelected;

  const CryptoTechniqueCard({
    required this.title,
    this.isSelected = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isSelected ? Colors.indigo.withOpacity(0.3) : Colors.transparent,
        border: Border.all(color: Colors.indigo),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.indigo,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
