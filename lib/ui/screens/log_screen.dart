import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ftp_photo_server/core/app_state.dart';
import 'package:ftp_photo_server/ui/widgets/log_tile.dart';

/// Log screen - Shows connection logs
class LogScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Connection Logs'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: () => appState.clearLogs(),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: appState.logs.length,
        itemBuilder: (context, index) {
          return LogTile(log: appState.logs[index]);
        },
      ),
    );
  }
}
