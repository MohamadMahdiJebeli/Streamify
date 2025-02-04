import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:file_picker/file_picker.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class Mainscreen extends StatefulWidget {
  final String streamUrl;
  const Mainscreen({super.key, required this.streamUrl});

  @override
  State<Mainscreen> createState() => _MainscreenState();
}

class _MainscreenState extends State<Mainscreen> with SingleTickerProviderStateMixin {
  late VideoPlayerController _controller;
  late AnimationController _animationController;
  bool _isControllerVisible = true;
  bool _isFullScreen = false;
  bool _showLoading = true;
  Duration? _totalDuration;
  List<Subtitle> _subtitles = [];
  String _currentSubtitle = '';

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    WakelockPlus.enable();
  }

  void _initializeVideo() async {
    try {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.streamUrl))
        ..addListener(() {
          if (_controller.value.hasError) {
            setState(() => _showLoading = false);
          }
          _updateCurrentSubtitle();
        });

      await _controller.initialize();
      _totalDuration = _controller.value.duration;
      setState(() => _showLoading = false);
      _controller.play();

      // Auto-hide controls after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _isControllerVisible = false);
      });
    } catch (e) {
      setState(() => _showLoading = false);
    }
  }

  void _toggleControls() {
    setState(() {
      _isControllerVisible = !_isControllerVisible;
      if (_isControllerVisible) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });

    if (_isControllerVisible) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _isControllerVisible = false);
      });
    }
  }

  void _toggleFullScreen() {
    setState(() => _isFullScreen = !_isFullScreen);
    if (_isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  void _closeControls() {
    setState(() {
      _isControllerVisible = false;
      _animationController.reverse();
    });
  }

  Future<void> _pickSubtitleFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['srt', 'vtt'],
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      String? filePath = file.path;

      if (filePath != null) {
        final content = await File(filePath).readAsString();
        setState(() {
          _subtitles = _parseSrt(content);
        });
      }
    }
  }

  List<Subtitle> _parseSrt(String content) {
    final List<Subtitle> subtitles = [];
    final List<String> lines = content.split('\n');

    for (int i = 0; i < lines.length; i++) {
      if (lines[i].contains('-->')) {
        final times = lines[i].split('-->');
        final startTime = _parseTime(times[0].trim());
        final endTime = _parseTime(times[1].trim());
        final text = lines[i + 1].trim();

        subtitles.add(Subtitle(
          startTime: startTime,
          endTime: endTime,
          text: text,
        ));
      }
    }

    return subtitles;
  }

  Duration _parseTime(String time) {
    final parts = time.split(':');
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);
    final seconds = double.parse(parts[2].replaceAll(',', '.'));

    return Duration(
      hours: hours,
      minutes: minutes,
      seconds: seconds.toInt(),
      milliseconds: ((seconds - seconds.toInt()) * 1000).toInt(),
    );
  }

  void _updateCurrentSubtitle() {
    if (_subtitles.isEmpty) return;

    final currentTime = _controller.value.position;
    for (var subtitle in _subtitles) {
      if (currentTime >= subtitle.startTime && currentTime <= subtitle.endTime) {
        setState(() => _currentSubtitle = subtitle.text);
        return;
      }
    }
    setState(() => _currentSubtitle = '');
  }

  void _togglePlayPause() {
  setState(() {
    if (_controller.value.isPlaying) {
      _controller.pause();
      WakelockPlus.disable();
    } else {
      _controller.play();
      WakelockPlus.enable();
    }
  });
}

String _formatDuration(Duration? duration) {
  if (duration == null) return '--:--';
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);

  if (hours > 0) {
    return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
  } else {
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }
}
  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
    WakelockPlus.enabled;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        top: !_isFullScreen,
        bottom: !_isFullScreen,
        child: GestureDetector(
          onTap: _toggleControls,
          child: Stack(
            children: [

              // Video Player
              Center(
                child: _controller.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      )
                    : const SizedBox(),
              ),

              // Loading/Error Overlay
              if (_showLoading)
                const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.amber,
                  ),
                ),

              // Subtitle Overlay
              if (_currentSubtitle.isNotEmpty)
                Positioned(
                  bottom: _isControllerVisible?150:10,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color:Colors.black54,
                        borderRadius: BorderRadius.all(Radius.circular(30))
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          _currentSubtitle,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontFamily: 'Dana',
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              // Controls Overlay
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _animationController.value,
                    child: child,
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      // Top Controls
                      AppBar(
                        backgroundColor: Colors.transparent,
                        leading: IconButton(
                          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        actions: [
                          IconButton(
                            icon: Icon(
                              _isFullScreen
                                  ? Icons.fullscreen_exit_rounded
                                  : Icons.fullscreen_rounded,
                              color: Colors.white,
                            ),
                            onPressed: _toggleFullScreen,
                          ),
                          IconButton(
                            icon: const Icon(Icons.subtitles_rounded, color: Colors.white),
                            onPressed: _pickSubtitleFile,
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: _closeControls,
                          ),
                        ],
                      ),

                      // Spacer
                      const Spacer(),

                      // Bottom Controls
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            // Progress Bar
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    _formatDuration(_controller.value.position),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                Expanded(
                                  child: VideoProgressIndicator(
                                    _controller,
                                    allowScrubbing: true,
                                    colors: const VideoProgressColors(
                                      playedColor: Colors.amber,
                                      bufferedColor: Colors.white54,
                                      backgroundColor: Colors.white24,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    _formatDuration(_totalDuration),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Playback Controls
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.replay_10_rounded, size: 32),
                                  color: Colors.white,
                                  onPressed: () => _controller.seekTo(
                                    _controller.value.position - const Duration(seconds: 10),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    _controller.value.isPlaying
                                        ? Icons.pause_circle_filled_rounded
                                        : Icons.play_circle_filled_rounded,
                                    size: 48,
                                  ),
                                  color: Colors.amber,
                                  onPressed: _togglePlayPause,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.forward_10_rounded, size: 32),
                                  color: Colors.white,
                                  onPressed: () => _controller.seekTo(
                                    _controller.value.position + const Duration(seconds: 10),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Subtitle {
  final Duration startTime;
  final Duration endTime;
  final String text;

  Subtitle({
    required this.startTime,
    required this.endTime,
    required this.text,
  });
}