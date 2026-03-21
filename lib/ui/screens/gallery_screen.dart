import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ftp_photo_server/core/app_state.dart';
import 'package:ftp_photo_server/ui/widgets/received_image_card.dart';

/// Gallery screen - Shows received images
class GalleryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Received Images'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              // Refresh gallery
            },
          ),
        ],
      ),
      body: appState.receivedImages.isEmpty
          ? Center(
              child: Text(
                'No images received yet',
                style: TextStyle(fontSize: 18),
              ),
            )
          : GridView.builder(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: appState.receivedImages.length,
              itemBuilder: (context, index) {
                return ReceivedImageCard(imageInfo: appState.receivedImages[index]);
              },
            ),
    );
  }
}
