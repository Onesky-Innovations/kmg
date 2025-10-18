import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ViewLimitNotifier extends ChangeNotifier {
  int _viewCount = 0;
  int _viewLimit = 20;
  bool _applyLimitToFemale = false;

  int get viewCount => _viewCount;
  int get viewLimit => _viewLimit;
  bool get applyLimitToFemale => _applyLimitToFemale;
  int get remaining => _viewLimit - _viewCount;

  ViewLimitNotifier() {
    _loadFromFirestore();
  }

  Future<void> _loadFromFirestore() async {
    final docRef = FirebaseFirestore.instance
        .collection('appSettings')
        .doc('matrimony_view_config');

    // Listen for real-time changes
    docRef.snapshots().listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data()!;
        updateLimit(data['defaultViewLimit'] ?? 20);
        updateFemaleLimit(data['applyLimitToFemale'] ?? false);
      }
    });
  }

  void setValues({int? count, int? limit, bool? femaleLimit}) {
    if (count != null) _viewCount = count;
    if (limit != null) _viewLimit = limit;
    if (femaleLimit != null) _applyLimitToFemale = femaleLimit;
    notifyListeners();
  }

  void increment() {
    _viewCount++;
    notifyListeners();
  }

  void resetCount() {
    _viewCount = 0;
    notifyListeners();
  }

  void updateLimit(int newLimit) {
    _viewLimit = newLimit;
    notifyListeners();
  }

  void updateFemaleLimit(bool newValue) {
    _applyLimitToFemale = newValue;
    notifyListeners();
  }
}

// 🔥 Global notifier instance
final viewLimitNotifier = ViewLimitNotifier();
