import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/player_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerModel>(
      builder: (context, playerModel, child) {
        if (playerModel.selectedDirectory == null) {
          return const Center(
            child: Text('Please select a music folder in Settings'),
          );
        }

        if (playerModel.songs.isEmpty) {
          return const Center(
            child: Text('No music files found in the selected folder'),
          );
        }

        return Stack(
          children: [
            // Song List
            ListView.builder(
              padding: const EdgeInsets.only(bottom: 100),
              itemCount: playerModel.songs.length,
              itemBuilder: (context, index) {
                final song = playerModel.songs[index];
                final isPlaying =
                    playerModel.isPlaying && playerModel.currentIndex == index;

                return ListTile(
                  leading: SizedBox(
                    width: 50,
                    height: 50,
                    child:
                        song.albumArt != null
                            ? Image.memory(song.albumArt!, fit: BoxFit.cover)
                            : const Icon(Icons.music_note),
                  ),
                  title: Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    song.artist ?? 'Unknown Artist',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing:
                      isPlaying
                          ? const Icon(Icons.equalizer, color: Colors.blue)
                          : null,
                  onTap: () async {
                    if (playerModel.currentIndex != index) {
                      await playerModel.seekToIndex(index);
                    }
                    if (playerModel.isPlaying) {
                      await playerModel.pause();
                    } else {
                      await playerModel.play();
                    }
                  },
                );
              },
            ),

            // Player Controls
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Progress Bar
                    StreamBuilder<Duration>(
                      stream: playerModel.positionStream,
                      builder: (context, snapshot) {
                        final position = snapshot.data ?? Duration.zero;
                        final duration =
                            playerModel.totalDuration ?? Duration.zero;
                        return Slider(
                          value: position.inSeconds.toDouble(),
                          max: duration.inSeconds.toDouble(),
                          onChanged: (value) {
                            playerModel.seek(Duration(seconds: value.toInt()));
                          },
                        );
                      },
                    ),

                    // Controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.skip_previous),
                          onPressed: playerModel.skipToPrevious,
                        ),
                        IconButton(
                          icon: Icon(
                            playerModel.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                          ),
                          onPressed: () {
                            if (playerModel.isPlaying) {
                              playerModel.pause();
                            } else {
                              playerModel.play();
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.skip_next),
                          onPressed: playerModel.skipToNext,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
