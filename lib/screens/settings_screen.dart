import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../models/theme_model.dart';
import '../models/player_model.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Music Folder Selection
        Card(
          child: ListTile(
            leading: const Icon(Icons.folder),
            title: const Text('Music Folder'),
            subtitle: Consumer<PlayerModel>(
              builder: (context, playerModel, child) {
                return Text(
                  playerModel.selectedDirectory ?? 'No folder selected',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                );
              },
            ),
            onTap: () async {
              final directory = await FilePicker.platform.getDirectoryPath();
              if (directory != null) {
                final playerModel = context.read<PlayerModel>();
                await playerModel.setDirectory(directory);
              }
            },
          ),
        ),

        const SizedBox(height: 16),

        // Theme Settings
        Card(
          child: Consumer<ThemeModel>(
            builder: (context, themeModel, child) {
              return SwitchListTile(
                secondary: const Icon(Icons.dark_mode),
                title: const Text('Dark Mode'),
                value: themeModel.isDarkMode,
                onChanged: (_) => themeModel.toggleTheme(),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // Playback Settings
        Card(
          child: Consumer<PlayerModel>(
            builder: (context, playerModel, child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.shuffle),
                    title: const Text('Shuffle Mode'),
                    value: playerModel.isShuffleEnabled,
                    onChanged: (_) => playerModel.toggleShuffle(),
                  ),
                  const Divider(),
                  SwitchListTile(
                    secondary: const Icon(Icons.repeat),
                    title: const Text('Repeat Mode'),
                    value: playerModel.isRepeatEnabled,
                    onChanged: (_) => playerModel.toggleRepeat(),
                  ),
                  const Divider(),
                  SwitchListTile(
                    secondary: const Icon(Icons.notifications),
                    title: const Text('Show Notifications'),
                    value: playerModel.showNotifications,
                    onChanged: (_) => playerModel.toggleNotifications(),
                  ),
                ],
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // Volume Control
        Card(
          child: Consumer<PlayerModel>(
            builder: (context, playerModel, child) {
              return ListTile(
                leading: const Icon(Icons.volume_up),
                title: const Text('Volume'),
                subtitle: Slider(
                  value: 1.0, // TODO: Implement volume control in PlayerModel
                  onChanged: (value) {
                    playerModel.setVolume(value);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
