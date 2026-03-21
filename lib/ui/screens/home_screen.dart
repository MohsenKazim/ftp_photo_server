import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ftp_photo_server/core/app_state.dart';
import 'package:ftp_photo_server/core/constants.dart';
import 'package:ftp_photo_server/ftp/ftp_server.dart';
import 'package:ftp_photo_server/storage/permissions_helper.dart';
import 'package:ftp_photo_server/storage/temp_manager.dart';
import 'package:ftp_photo_server/ui/widgets/server_card.dart';
import 'package:ftp_photo_server/ui/screens/log_screen.dart';
import 'package:ftp_photo_server/ui/screens/gallery_screen.dart';

/// Home screen - Main screen showing server status
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late FtpServer _ftpServer;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    _ftpServer = FtpServer(
      appState: appState,
      onLog: (log) => appState.addLog(log),
    );
  }

  @override
  void dispose() {
    _ftpServer.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('FTP Photo Server'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ServerCard(
              isServerRunning: appState.isServerRunning,
              localIP: appState.localIP,
              imagesReceived: appState.imagesReceived,
              onToggleServer: _toggleServer,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LogScreen()),
              ),
              child: Text('View Logs'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.black,
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GalleryScreen()),
              ),
              child: Text('View Gallery'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.black,
              ),
            ),
            SizedBox(height: 20),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FTP Connection Info',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text('Host: ${appState.localIP}'),
                    Text('Port: ${AppConstants.ftpPort}'),
                    Text('Username: ${AppConstants.ftpUsername}'),
                    Row(
                      children: [
                        Text('Password: ${_isPasswordVisible ? AppConstants.ftpPassword : '••••••••'}'),
                        IconButton(
                          icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                          iconSize: 18,
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleServer() async {
    final appState = Provider.of<AppState>(context, listen: false);

    if (!appState.isServerRunning) {
      // Check permissions first
      final hasPermission = await PermissionsHelper.areAllPermissionsGranted();
      if (!hasPermission) {
        await PermissionsHelper.requestAllPermissions();
        final allGranted = await PermissionsHelper.areAllPermissionsGranted();

        if (!allGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Permissions required to run FTP server')),
          );
          return;
        }
      }

      }

      try {
        // Clean up old temp files before starting
        await TempManager.cleanOldTempFiles();
        await _ftpServer.start();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to start server: $e')),
          );
        }
      }
    } else {
      try {
        await _ftpServer.stop();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to stop server: $e')),
          );
        }
      }
    }
  }
}
