import 'package:flutter/material.dart';
import 'package:kmg/theme/app_theme.dart';

class MatrimonyScreen extends StatefulWidget {
  const MatrimonyScreen({super.key});

  @override
  State<MatrimonyScreen> createState() => _MatrimonyScreenState();
}

class _MatrimonyScreenState extends State<MatrimonyScreen> {
  final int _currentIndex = 0;

  void _onFabPressed() {
    Navigator.pushNamed(context, "/matrimony"); // ✅ route from main.dart
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text("💍 Matrimony Screen", style: TextStyle(fontSize: 24)),
      ),

      // Show FAB only on Matrimony screen
      floatingActionButton: _currentIndex == 0
          ? TweenAnimationBuilder<Offset>(
              tween: Tween(begin: const Offset(0, 1), end: Offset.zero),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutBack,
              builder: (context, offset, child) {
                return Transform.translate(
                  offset: offset * 50, // controls slide distance
                  child: Opacity(
                    opacity: 1.0, // fully visible when shown
                    child: child,
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 79, 91, 254),
                      Color.fromARGB(255, 236, 134, 236),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: FloatingActionButton.extended(
                  onPressed: _onFabPressed,
                  backgroundColor: Colors.transparent, // important for gradient
                  elevation: 4,
                  icon: const Icon(
                    Icons.person_add_alt_1,
                    color: AppTheme.iconOnPrimary,
                  ),
                  label: const Text(
                    "Add Profile",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            )
          : const SizedBox.shrink(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
