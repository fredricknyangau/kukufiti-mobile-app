import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void showPremiumUpgradeDialog(BuildContext context, String feature) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Unlock $feature', style: const TextStyle(fontWeight: FontWeight.bold)),
      content: Text('Access into $feature requires a Professional Plan subscription to enable Advanced Farm Intelligence metrics securely.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Maybe Later')),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            context.push('/pricing');
          },
          child: const Text('Upgrade Now'),
        ),
      ],
    ),
  );
}
