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
    // Just update the current index without any routing
    // The bottom navigation will handle the view switching
    _currentIndex = index;
    notifyListeners();  
  }
}
