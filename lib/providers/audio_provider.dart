import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/poem.dart';

/// ═══════════════════════════════════════════════════════════════
/// AUDIO PROVIDER
/// Manages persistent audio player that works across the entire app
/// User can navigate anywhere while audio continues playing
/// ═══════════════════════════════════════════════════════════════

class AudioProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Current playing state
  Poem? _currentPoem;
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  // Playback speed
  double _playbackSpeed = 1.0;

  // ───────────────────────────────────────────────────────────────
  // GETTERS
  // ───────────────────────────────────────────────────────────────

  Poem? get currentPoem => _currentPoem;
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  Duration get duration => _duration;
  Duration get position => _position;
  double get playbackSpeed => _playbackSpeed;

  bool get hasAudio => _currentPoem != null;

  // Progress percentage (0.0 to 1.0)
  double get progress {
    if (_duration.inMilliseconds == 0) return 0.0;
    return _position.inMilliseconds / _duration.inMilliseconds;
  }

  // Formatted time strings
  String get positionText => _formatDuration(_position);
  String get durationText => _formatDuration(_duration);

  // ───────────────────────────────────────────────────────────────
  // CONSTRUCTOR: Set up audio player listeners
  // ───────────────────────────────────────────────────────────────

  AudioProvider() {
    _initializePlayer();
  }

  void _initializePlayer() {
    // Listen to player state changes
    _audioPlayer.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      _isLoading = state == PlayerState.buffering;
      notifyListeners();
    });

    // Listen to duration changes
    _audioPlayer.onDurationChanged.listen((duration) {
      _duration = duration;
      notifyListeners();
    });

    // Listen to position changes
    _audioPlayer.onPositionChanged.listen((position) {
      _position = position;
      notifyListeners();
    });

    // Listen to completion
    _audioPlayer.onPlayerComplete.listen((_) {
      _position = Duration.zero;
      _isPlaying = false;
      notifyListeners();
    });
  }

  // ───────────────────────────────────────────────────────────────
  // PLAY AUDIO: Start playing a poem's audio
  // ───────────────────────────────────────────────────────────────

  Future<void> playAudio(Poem poem) async {
    if (poem.audioUrl == null || poem.audioUrl!.isEmpty) {
      print('⚠️ No audio URL for poem ${poem.id}');
      return;
    }

    try {
      _isLoading = true;
      notifyListeners();

      // If same poem, just resume
      if (_currentPoem?.id == poem.id && _position.inSeconds > 0) {
        await _audioPlayer.resume();
      } else {
        // New poem, load and play
        _currentPoem = poem;
        _position = Duration.zero;

        // Determine if it's a URL or local file
        if (poem.audioUrl!.startsWith('http')) {
          await _audioPlayer.play(UrlSource(poem.audioUrl!));
        } else {
          await _audioPlayer.play(DeviceFileSource(poem.audioUrl!));
        }
      }

      _isLoading = false;
      notifyListeners();

      print('✅ Playing audio for poem ${poem.id}');
    } catch (e) {
      print('Error playing audio: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  // ───────────────────────────────────────────────────────────────
  // PAUSE AUDIO
  // ───────────────────────────────────────────────────────────────

  Future<void> pause() async {
    await _audioPlayer.pause();
    print('⏸️ Audio paused');
  }

  // ───────────────────────────────────────────────────────────────
  // RESUME AUDIO
  // ───────────────────────────────────────────────────────────────

  Future<void> resume() async {
    await _audioPlayer.resume();
    print('▶️ Audio resumed');
  }

  // ───────────────────────────────────────────────────────────────
  // STOP AUDIO
  // ───────────────────────────────────────────────────────────────

  Future<void> stop() async {
    await _audioPlayer.stop();
    _position = Duration.zero;
    _isPlaying = false;
    notifyListeners();
    print('⏹️ Audio stopped');
  }

  // ───────────────────────────────────────────────────────────────
  // SEEK TO POSITION
  // ───────────────────────────────────────────────────────────────

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
    print('⏩ Seeked to ${_formatDuration(position)}');
  }

  // ───────────────────────────────────────────────────────────────
  // SKIP FORWARD (10 seconds)
  // ───────────────────────────────────────────────────────────────

  Future<void> skipForward() async {
    final newPosition = _position + const Duration(seconds: 10);
    if (newPosition < _duration) {
      await seek(newPosition);
    } else {
      await seek(_duration);
    }
  }

  // ───────────────────────────────────────────────────────────────
  // SKIP BACKWARD (10 seconds)
  // ───────────────────────────────────────────────────────────────

  Future<void> skipBackward() async {
    final newPosition = _position - const Duration(seconds: 10);
    if (newPosition > Duration.zero) {
      await seek(newPosition);
    } else {
      await seek(Duration.zero);
    }
  }

  // ───────────────────────────────────────────────────────────────
  // SET PLAYBACK SPEED
  // ───────────────────────────────────────────────────────────────

  Future<void> setPlaybackSpeed(double speed) async {
    if (speed < 0.5 || speed > 2.0) return;

    await _audioPlayer.setPlaybackRate(speed);
    _playbackSpeed = speed;
    notifyListeners();
    print('⚡ Playback speed set to ${speed}x');
  }

  // ───────────────────────────────────────────────────────────────
  // TOGGLE PLAY/PAUSE
  // ───────────────────────────────────────────────────────────────

  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await pause();
    } else {
      await resume();
    }
  }

  // ───────────────────────────────────────────────────────────────
  // FORMAT DURATION (convert to mm:ss)
  // ───────────────────────────────────────────────────────────────

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  // ───────────────────────────────────────────────────────────────
  // CLEAR CURRENT AUDIO (when navigating away from poem)
  // ───────────────────────────────────────────────────────────────

  Future<void> clearAudio() async {
    await stop();
    _currentPoem = null;
    _duration = Duration.zero;
    _position = Duration.zero;
    notifyListeners();
    print('🗑️ Audio cleared');
  }

  // ───────────────────────────────────────────────────────────────
  // DISPOSE: Clean up resources
  // ───────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}

/* 
═══════════════════════════════════════════════════════════════
TEACHER'S EXPLANATION:
═══════════════════════════════════════════════════════════════

1. WHAT is a persistent audio player?
   - Plays audio that continues across screens
   - User can navigate away from poem screen
   - Audio keeps playing in background
   - Mini player shown at bottom of app
   
   Example:
   User on Poem Detail → Plays audio → Navigates to Home
   → Audio continues playing
   → Mini player visible at bottom

2. WHY use audioplayers package?
   - Cross-platform (Android, iOS, Web)
   - Supports streaming and local files
   - Background playback
   - Event listeners for state changes

3. HOW to use in UI (Poem Detail Screen)?
   
   Consumer<AudioProvider>(
     builder: (context, audioProvider, child) {
       final isCurrentPoem = audioProvider.currentPoem?.id == widget.poemId;
       final isPlaying = isCurrentPoem && audioProvider.isPlaying;
       
       return Column(
         children: [
           // Audio controls
           Row(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
               // Skip backward
               IconButton(
                 icon: Icon(Icons.replay_10),
                 onPressed: audioProvider.skipBackward,
               ),
               
               // Play/Pause
               IconButton(
                 icon: Icon(
                   isPlaying ? Icons.pause_circle : Icons.play_circle,
                   size: 64,
                 ),
                 onPressed: () {
                   if (isCurrentPoem) {
                     audioProvider.togglePlayPause();
                   } else {
                     audioProvider.playAudio(widget.poem);
                   }
                 },
               ),
               
               // Skip forward
               IconButton(
                 icon: Icon(Icons.forward_10),
                 onPressed: audioProvider.skipForward,
               ),
             ],
           ),
           
           // Progress bar
           Slider(
             value: isCurrentPoem ? audioProvider.progress : 0.0,
             onChanged: (value) {
               if (isCurrentPoem) {
                 final position = audioProvider.duration * value;
                 audioProvider.seek(position);
               }
             },
           ),
           
           // Time display
           Padding(
             padding: EdgeInsets.symmetric(horizontal: 16),
             child: Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 Text(audioProvider.positionText),
                 Text(audioProvider.durationText),
               ],
             ),
           ),
         ],
       );
     },
   );

4. HOW to show persistent mini player?
   
   // In main screen (wrap Scaffold body)
   Consumer<AudioProvider>(
     builder: (context, audioProvider, child) {
       return Column(
         children: [
           Expanded(
             child: child!, // Your main screen content
           ),
           
           // Mini player (shown when audio is playing)
           if (audioProvider.hasAudio)
             Container(
               height: 64,
               color: Colors.grey[900],
               child: Row(
                 children: [
                   // Poem info
                   Expanded(
                     child: ListTile(
                       title: Text(
                         audioProvider.currentPoem?.getTitle('en') ?? '',
                         style: TextStyle(color: Colors.white),
                       ),
                       subtitle: LinearProgressIndicator(
                         value: audioProvider.progress,
                       ),
                     ),
                   ),
                   
                   // Play/Pause button
                   IconButton(
                     icon: Icon(
                       audioProvider.isPlaying 
                         ? Icons.pause 
                         : Icons.play_arrow,
                       color: Colors.white,
                     ),
                     onPressed: audioProvider.togglePlayPause,
                   ),
                   
                   // Close button
                   IconButton(
                     icon: Icon(Icons.close, color: Colors.white),
                     onPressed: audioProvider.clearAudio,
                   ),
                 ],
               ),
             ),
         ],
       );
     },
   );

5. WHAT are the audio player states?
   
   PlayerState.stopped → Not playing
   PlayerState.playing → Currently playing
   PlayerState.paused → Paused
   PlayerState.buffering → Loading audio (_isLoading = true)
   PlayerState.completed → Finished playing

6. HOW does seek work?
   - User drags slider
   - onChanged gives value 0.0 to 1.0
   - Calculate position: duration * value
   - Seek to that position
   
   Example:
   Duration: 5 minutes (300 seconds)
   User drags slider to 0.5 (middle)
   Position = 300 * 0.5 = 150 seconds (2:30)

7. WHY format duration?
   - Duration.toString() = "0:03:25.000000"
   - _formatDuration() = "03:25"
   - Better for UI display

8. PLAYBACK SPEED:
   - 0.5x = Half speed (slower)
   - 1.0x = Normal speed
   - 1.5x = 1.5x faster
   - 2.0x = Double speed
   
   Usage:
   DropdownButton<double>(
     value: audioProvider.playbackSpeed,
     items: [0.5, 0.75, 1.0, 1.25, 1.5, 2.0].map((speed) {
       return DropdownMenuItem(
         value: speed,
         child: Text('${speed}x'),
       );
     }).toList(),
     onChanged: (speed) {
       if (speed != null) {
         audioProvider.setPlaybackSpeed(speed);
       }
     },
   );

9. IMPORTANT: Audio sources
   
   Online URL:
   await _audioPlayer.play(UrlSource(poem.audioUrl));
   // Streams from internet
   
   Local file (downloaded):
   await _audioPlayer.play(DeviceFileSource(poem.audioUrl));
   // Plays from device storage

10. LIFECYCLE:
    
    App starts
    → AudioProvider created
    → Listeners attached
    
    User plays audio
    → playAudio() called
    → Audio starts
    → Position updates every second
    → UI rebuilds showing progress
    
    User navigates away
    → Audio continues playing
    → Mini player visible
    
    User closes app
    → dispose() called
    → Audio player cleaned up

═══════════════════════════════════════════════════════════════
*/