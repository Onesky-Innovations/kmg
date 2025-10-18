import 'package:flutter/material.dart';
import 'dart:async';

class InfoMessageButton extends StatefulWidget {
  final String message;
  final int durationSeconds;

  const InfoMessageButton({
    super.key,
    required this.message,
    this.durationSeconds = 2,
  });

  @override
  State<InfoMessageButton> createState() => _InfoMessageButtonState();
}

class _InfoMessageButtonState extends State<InfoMessageButton>
    with SingleTickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  Timer? _timer;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
  }

  void _showOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);

    _controller.forward();

    _timer?.cancel();
    _timer = Timer(Duration(seconds: widget.durationSeconds), () {
      _hideOverlay();
    });
  }

  void _hideOverlay() {
    _timer?.cancel();
    _controller.reverse().then((_) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }

  OverlayEntry _createOverlayEntry() {
    final screenWidth = MediaQuery.of(context).size.width;

    return OverlayEntry(
      builder: (context) => Positioned(
        top: 60, // top padding from AppBar
        right: 16,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
            );
          },
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(16),
            color: const Color.fromARGB(255, 62, 200, 255).withOpacity(0.95),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              constraints: BoxConstraints(maxWidth: screenWidth * 0.6),
              child: Text(
                widget.message,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.info_outline),
      onPressed: _showOverlay,
    );
  }
}
