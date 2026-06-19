import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:tapovana_mobile_app/core/theme/app_fonts.dart';
import 'package:tapovana_mobile_app/core/widgets/media_helper.dart';


class CustomVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final bool autoPlay;

  const CustomVideoPlayer({
    super.key,
    required this.videoUrl,
    this.autoPlay = true,
  });

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() async {
    final resolvedUrl = MediaHelper.resolveMediaUrl(widget.videoUrl);
    _controller = VideoPlayerController.networkUrl(Uri.parse(resolvedUrl));
    try {
      await _controller.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        if (widget.autoPlay) {
          _controller.play();
        }
      }
    } catch (e) {
      debugPrint("❌ Error initializing video player: $e");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (!_isInitialized) return;
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xFFD9A04B)),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _showControls = !_showControls;
        });
      },
      child: Container(
        color: Colors.black,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 1. The Video Player viewport
            Center(
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            ),

            // 2. Play/Pause overlay button in the center
            if (_showControls || !_controller.value.isPlaying)
              GestureDetector(
                onTap: _togglePlay,
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.black54,
                  child: Icon(
                    _controller.value.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: const Color(0xFFD9A04B),
                    size: 36,
                  ),
                ),
              ),

            // 3. Controller Bar at the bottom
            if (_showControls)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black87],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Video progress slider
                      VideoProgressIndicator(
                        _controller,
                        allowScrubbing: true,
                        colors: const VideoProgressColors(
                          playedColor: Color(0xFFD9A04B),
                          bufferedColor: Colors.white24,
                          backgroundColor: Colors.white12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Controls row (time and volume)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ValueListenableBuilder(
                            valueListenable: _controller,
                            builder: (context, VideoPlayerValue value, child) {
                              return Text(
                                "${_formatDuration(value.position)} / ${_formatDuration(value.duration)}",
                                style: AppFonts.poppinsRegular(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              _controller.value.volume == 0
                                  ? Icons.volume_off_rounded
                                  : Icons.volume_up_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                if (_controller.value.volume == 0) {
                                  _controller.setVolume(1.0);
                                } else {
                                  _controller.setVolume(0.0);
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
