import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ftp_photo_server/ui/screens/home_screen.dart';
import 'package:ftp_photo_server/core/app_state.dart';
import 'package:ftp_photo_server/core/device_info.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FTP Photo Server',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Builder(
        builder: (context) {
          // Initialize the local IP when the widget builds
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            try {
              final ip = await DeviceInfo.getLocalIP();
              final appState = Provider.of<AppState>(context, listen: false);
              appState.setLocalIP(ip);
            } catch (e) {
              // Handle error silently
            }
          });
          
          return HomeScreen();
        },
      ),
    );
  }
}
