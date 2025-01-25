import 'package:flutter/material.dart';

class ClosableAlert extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onClose;

  const ClosableAlert({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red.shade50,
      child: ListTile(
        leading: Icon(Icons.warning, color: Colors.red),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: IconButton(
          icon: Icon(Icons.close, color: Colors.red),
          onPressed: onClose,
        ),
      ),
    );
  }
}
