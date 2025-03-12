import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as path;
import 'package:metadata_god/metadata_god.dart';

class SongInfo {
  final String title;
  final String? artist;
  final String? album;
  final String filePath;
  final Uint8List? albumArt;

  SongInfo({
    required this.title,
    this.artist,
    this.album,
    required this.filePath,
    this.albumArt,
  });

  static Future<SongInfo> fromFile(File file) async {
    final metadata = await MetadataGod.readMetadata(file: file.path);
    return SongInfo(
      title: metadata.title ?? path.basename(file.path),
      artist: metadata.artist,
      album: metadata.album,
      filePath: file.path,
      albumArt: metadata.picture?.data,
    );
  }
}

class PlayerModel extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  List<SongInfo> _songs = [];
  String? _selectedDirectory;
  bool _isShuffleEnabled = false;
  bool _isRepeatEnabled = false;
  bool _showNotifications = true;

  PlayerModel() {
    _player.playerStateStream.listen((state) {
      notifyListeners();
    });
  }

  // Getters
  List<SongInfo> get songs => _songs;
  String? get selectedDirectory => _selectedDirectory;
  bool get isPlaying => _player.playing;
  bool get isShuffleEnabled => _isShuffleEnabled;
  bool get isRepeatEnabled => _isRepeatEnabled;
  bool get showNotifications => _showNotifications;
  Duration? get currentPosition => _player.position;
  Duration? get totalDuration => _player.duration;
  int get currentIndex => _player.currentIndex ?? 0;
  Stream<Duration> get positionStream => _player.positionStream;

  // Directory selection and song loading
  Future<void> setDirectory(String directory) async {
    _selectedDirectory = directory;
    await _loadSongs();
    notifyListeners();
  }

  Future<void> _loadSongs() async {
    if (_selectedDirectory == null) return;

    final directory = Directory(_selectedDirectory!);
    final List<SongInfo> loadedSongs = [];

    await for (final entity in directory.list(recursive: true)) {
      if (entity is File) {
        final ext = path.extension(entity.path).toLowerCase();
        if (['.mp3', '.m4a', '.aac', '.wav'].contains(ext)) {
          try {
            final songInfo = await SongInfo.fromFile(entity);
            loadedSongs.add(songInfo);
          } catch (e) {
            print('Error loading metadata for ${entity.path}: $e');
          }
        }
      }
    }

    _songs = loadedSongs;
    await _updatePlayerQueue();
  }

  Future<void> _updatePlayerQueue() async {
    if (_songs.isEmpty) return;

    final audioSources =
        _songs.map((song) => AudioSource.uri(Uri.file(song.filePath))).toList();

    await _player.setAudioSource(
      ConcatenatingAudioSource(children: audioSources),
      initialIndex: 0,
    );
  }

  // Playback controls
  Future<void> play() => _player.play();
  Future<void> pause() => _player.pause();
  Future<void> seek(Duration position) => _player.seek(position);
  Future<void> skipToNext() => _player.seekToNext();
  Future<void> skipToPrevious() => _player.seekToPrevious();
  Future<void> seekToIndex(int index) =>
      _player.seek(Duration.zero, index: index);

  void setVolume(double volume) {
    _player.setVolume(volume);
    notifyListeners();
  }

  // Settings
  void toggleShuffle() {
    _isShuffleEnabled = !_isShuffleEnabled;
    _player.setShuffleModeEnabled(_isShuffleEnabled);
    notifyListeners();
  }

  void toggleRepeat() {
    _isRepeatEnabled = !_isRepeatEnabled;
    _player.setLoopMode(_isRepeatEnabled ? LoopMode.all : LoopMode.off);
    notifyListeners();
  }

  void toggleNotifications() {
    _showNotifications = !_showNotifications;
    notifyListeners();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
