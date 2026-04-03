import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: 300,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              RemixIcons.ghost_line,
              size: 50,
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.1),
            ),
            const SizedBox(height: 10),
            Text(
              "hp_nenhuma_viagem".tr,
              style: TextStyle(
                fontFamily: 'Montserrat',
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
