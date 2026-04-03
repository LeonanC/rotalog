import 'package:flutter/material.dart';
import 'package:rotalog/modules/home/home_controller.dart';

class FilterButton extends StatelessWidget {
  final PeriodoFiltro filtro;
  final bool isSelected;
  final VoidCallback onTap;
  const FilterButton({
    super.key,
    required this.filtro,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Text(
          filtro.label,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 11,
            color: isSelected ? const Color(0xFF2563EB) : Colors.white70,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
