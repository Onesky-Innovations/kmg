import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// 🔹 Global in-memory cache for user names
final Map<String, String> _userNameCache = {};

/// Widget that fetches and displays a user’s name from /users/{userId}
class UserNameFetcher extends StatefulWidget {
  final String userId;
  final TextStyle? style;

  const UserNameFetcher({super.key, required this.userId, this.style});

  @override
  State<UserNameFetcher> createState() => _UserNameFetcherState();
}

class _UserNameFetcherState extends State<UserNameFetcher> {
  String? _displayName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final userId = widget.userId.trim();

    if (userId.isEmpty) {
      setState(() {
        _displayName = 'KMG';
        _isLoading = false;
      });
      return;
    }

    // 🧠 Use cache if available
    if (_userNameCache.containsKey(userId)) {
      setState(() {
        _displayName = _userNameCache[userId];
        _isLoading = false;
      });
      return;
    }

    // 🚀 Fetch from Firestore
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      String name = 'KMG';
      if (doc.exists) {
        final data = doc.data();
        name =
            (data?['name'] ?? data?['displayName'] ?? data?['email'] ?? 'KMG')
                .toString()
                .trim();
      }

      _userNameCache[userId] = name;

      if (mounted) {
        setState(() {
          _displayName = name;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _displayName = 'KMG';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // return const Text(
      //   'Loading...',
      //   style: TextStyle(fontSize: 12, color: Colors.grey),
      // );
    }

    return Text(
      _displayName ?? 'KMG',
      style:
          widget.style ??
          const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
    );
  }
}
