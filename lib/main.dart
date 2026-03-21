import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ftp_photo_server/core/app_state.dart';
import 'package:ftp_photo_server/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MyApp(),
    ),
  );
}
