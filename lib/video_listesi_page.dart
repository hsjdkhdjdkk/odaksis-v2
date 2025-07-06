import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'player_page.dart';

class VideoListesiPage extends StatefulWidget {
  const VideoListesiPage({super.key});

  @override
  State<VideoListesiPage> createState() => _VideoListesiPageState();
}

class _VideoListesiPageState extends State<VideoListesiPage> {
  final String apiKey = 'AIzaSyC02pLQ2E98uS-3v6BxKiEN_qMjm4lB2vc';
  final String playlistId = 'PLqLwBmByktJUJ8X-eYSHSxUH8uGkSqUsB';
  List<Map<String, String>> videos = [];
  String? nextPageToken;

  @override
  void initState() {
    super.initState();
    fetchVideos();
  }

  Future<void> fetchVideos() async {
    final url = Uri.parse(
      'https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&maxResults=20&playlistId=$playlistId&key=$apiKey&pageToken=${nextPageToken ?? ""}',
    );

    final response = await http.get(url);
    final data = json.decode(response.body);

    List<Map<String, String>> newVideos = [];
    for (var item in data['items']) {
      final videoId = item['snippet']['resourceId']['videoId'];
      final title = item['snippet']['title'];
      newVideos.add({'videoId': videoId, 'title': title});
    }

    setState(() {
      videos.addAll(newVideos);
      nextPageToken = data['nextPageToken'];
    });

    if (nextPageToken != null) {
      await fetchVideos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🎥 Video Listesi')),
      body: ListView.builder(
        itemCount: videos.length,
        itemBuilder: (context, index) {
          final video = videos[index];
          return ListTile(
            title: Text(video['title'] ?? ''),
            trailing: const Icon(Icons.play_arrow),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PlayerPage(videoId: video['videoId'] ?? ''),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
