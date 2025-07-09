import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54, // Semi-transparent overlay
      child: const Center(
        child: SpinKitFadingCircle(color: Colors.white, size: 50.0),
      ),
    );
  }
}
