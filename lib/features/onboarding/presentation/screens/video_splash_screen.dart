import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// A premium video splash screen that plays `Getzio.mp4` on a solid `#162225` background
/// and then transitions smoothly to the next screen.
class VideoSplashScreen extends StatefulWidget {
  final Widget nextScreen;

  const VideoSplashScreen({
    super.key,
    required this.nextScreen,
  });

  @override
  State<VideoSplashScreen> createState() => _VideoSplashScreenState();
}

class _VideoSplashScreenState extends State<VideoSplashScreen> {
  late VideoPlayerController _controller;
  bool _isNavigated = false;
  Timer? _fallbackTimer;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset('assets/images/splash/Getzio.mp4');

    _controller.initialize().then((_) {
      if (mounted) {
        setState(() {});
        _controller.play();
      }
    }).catchError((error) {
      debugPrint('[VideoSplash] Error initializing video player: $error');
      _navigateToNext();
    });

    _controller.addListener(_videoListener);

    // Fallback timer: navigate after 5 seconds in case video fails or gets stuck
    _fallbackTimer = Timer(const Duration(seconds: 5), () {
      _navigateToNext();
    });
  }

  void _videoListener() {
    if (!mounted) return;
    final value = _controller.value;
    if (value.isInitialized && value.position >= value.duration) {
      _navigateToNext();
    }
  }

  void _navigateToNext() {
    if (_isNavigated) return;
    _isNavigated = true;

    _fallbackTimer?.cancel();
    _controller.removeListener(_videoListener);
    _controller.pause();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => widget.nextScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    _controller.removeListener(_videoListener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF162254),
      body: Stack(
        children: [
          Positioned.fill(
            child: _controller.value.isInitialized
                ? FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: VideoPlayer(_controller),
                    ),
                  )
                : Container(
                    color: const Color(0xFF162254),
                  ),
          ),
        ],
      ),
    );
  }
}
