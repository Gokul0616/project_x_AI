// lib/features/home/home_viewmodel.dart
import 'package:flutter/foundation.dart';

class HomeViewModel with ChangeNotifier {
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void navigateTo(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}
