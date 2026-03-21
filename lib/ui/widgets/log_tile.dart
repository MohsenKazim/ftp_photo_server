import 'package:flutter/material.dart';

/// Log tile widget for displaying log entries
class LogTile extends StatelessWidget {
  final String log;

  const LogTile({Key? key, required this.log}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.info_outline, color: Colors.blue),
      title: Text(
        log,
        style: TextStyle(fontSize: 14),
      ),
      dense: true,
    );
  }
}
