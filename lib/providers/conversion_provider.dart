import 'package:flutter/material.dart';

class ConversionProvider extends ChangeNotifier {
  String? resultPath;

  void setResultPath(String path) {
    resultPath = path;
    notifyListeners();
  }

  void clearResult() {
    resultPath = null;
    notifyListeners();
  }
}
