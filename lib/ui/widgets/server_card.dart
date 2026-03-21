import 'package:flutter/material.dart';
import 'package:ftp_photo_server/core/constants.dart';

/// Server card widget showing server status
class ServerCard extends StatelessWidget {
  final bool isServerRunning;
  final String localIP;
  final int imagesReceived;
  final VoidCallback onToggleServer;

  const ServerCard({
    Key? key,
    required this.isServerRunning,
    required this.localIP,
    required this.imagesReceived,
    required this.onToggleServer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'FTP Server Status',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isServerRunning ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isServerRunning ? 'RUNNING' : 'STOPPED',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            _buildInfoRow('IP Address:', localIP),
            _buildInfoRow('Port:', '${AppConstants.ftpPort}'),
            _buildInfoRow('Username:', AppConstants.ftpUsername),
            _buildInfoRow('Password:', AppConstants.ftpPassword),
            _buildInfoRow('Images Received:', '$imagesReceived'),
            SizedBox(height: 15),
            ElevatedButton(
              onPressed: onToggleServer,
              style: ElevatedButton.styleFrom(
                backgroundColor: isServerRunning ? Colors.red : Colors.green,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 40),
              ),
              child: Text(isServerRunning ? 'STOP SERVER' : 'START SERVER'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Expanded(flex: 1, child: Text(label)),
          Expanded(flex: 2, child: Text(value, style: TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
