// lib/screens/time_tools/stopwatch_timer_screen.dart
import 'package:flutter/material.dart';
import 'dart:async'; // For Timer and Stream
import 'package:utilimate/widgets/custom_app_bar.dart';
import 'package:utilimate/widgets/custom_button.dart';

class StopwatchTimerScreen extends StatefulWidget {
  const StopwatchTimerScreen({super.key});

  @override
  State<StopwatchTimerScreen> createState() => _StopwatchTimerScreenState();
}

class _StopwatchTimerScreenState extends State<StopwatchTimerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // --- Stopwatch Variables ---
  final Stopwatch _stopwatch = Stopwatch(); // FIX: Made _stopwatch final
  Timer? _stopwatchTimer;
  String _stopwatchDisplay = '00:00:00.00';

  // --- Timer Variables ---
  Timer? _countdownTimer;
  Duration _initialDuration = const Duration(minutes: 5); // Default 5 minutes
  Duration _currentDuration = Duration.zero;
  String _countdownDisplay = '00:00';
  bool _isCountdownRunning = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _resetCountdown(); // Initialize countdown display
  }

  // --- Stopwatch Methods ---
  void _startStopwatch() {
    _stopwatch.start();
    _stopwatchTimer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      if (mounted) {
        setState(() {
          _stopwatchDisplay = _formatDuration(_stopwatch.elapsed);
        });
      }
    });
  }

  void _pauseStopwatch() {
    _stopwatch.stop();
    _stopwatchTimer?.cancel();
  }

  void _resetStopwatch() {
    _stopwatch.reset();
    _stopwatch.stop();
    _stopwatchTimer?.cancel();
    setState(() {
      _stopwatchDisplay = '00:00:00.00';
    });
  }

  // --- Timer Methods ---
  void _setTimerDuration() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: _initialDuration.inHours,
        minute: _initialDuration.inMinutes.remainder(60),
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Theme.of(context).colorScheme.onPrimary,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        _initialDuration = Duration(
          hours: pickedTime.hour,
          minutes: pickedTime.minute,
        );
        _currentDuration = _initialDuration;
        _countdownDisplay = _formatDuration(_currentDuration);
        _isCountdownRunning = false;
        _countdownTimer?.cancel();
      });
    }
  }

  void _startCountdown() {
    if (_currentDuration.inSeconds <= 0 && _initialDuration.inSeconds <= 0) {
      // If no duration set yet, default to 5 minutes
      _initialDuration = const Duration(minutes: 5);
      _currentDuration = _initialDuration;
    } else if (_currentDuration.inSeconds <= 0 &&
        _initialDuration.inSeconds > 0) {
      // If timer ran out, reset to initial duration before starting
      _currentDuration = _initialDuration;
    }

    _isCountdownRunning = true;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_currentDuration.inSeconds > 0) {
            _currentDuration = _currentDuration - const Duration(seconds: 1);
            _countdownDisplay = _formatDuration(_currentDuration);
          } else {
            _countdownTimer?.cancel();
            _isCountdownRunning = false;
            _showTimerFinishedDialog();
          }
        });
      }
    });
  }

  void _pauseCountdown() {
    _countdownTimer?.cancel();
    _isCountdownRunning = false;
  }

  void _resetCountdown() {
    _countdownTimer?.cancel();
    _isCountdownRunning = false;
    setState(() {
      _currentDuration = _initialDuration;
      _countdownDisplay = _formatDuration(_initialDuration);
    });
  }

  void _showTimerFinishedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Timer Finished!'),
          content: const Text('Your countdown timer has completed.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetCountdown(); // Reset timer after dialog is closed
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
      barrierDismissible: false, // Prevent dismissing by tapping outside
    );
  }

  // --- Helper for formatting Duration ---
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final String hours = twoDigits(duration.inHours);
    final String minutes = twoDigits(duration.inMinutes.remainder(60));
    final String seconds = twoDigits(duration.inSeconds.remainder(60));
    final String milliseconds = twoDigits(
      duration.inMilliseconds.remainder(1000) ~/ 10,
    ); // Two digits for milliseconds

    if (duration.inHours > 0) {
      return '$hours:$minutes:$seconds.$milliseconds';
    } else if (duration.inMinutes > 0 || duration.inSeconds > 0) {
      // For timer, we only need MM:SS
      if (_tabController.index == 1) {
        // If it's the timer tab
        return '$minutes:$seconds';
      }
      return '$minutes:$seconds.$milliseconds';
    } else {
      // For timer, if it's 00:00, show that. For stopwatch, show 00:00:00.00
      if (_tabController.index == 1) {
        return '00:00';
      }
      return '00:00:00.00';
    }
  }

  @override
  void dispose() {
    _stopwatchTimer?.cancel();
    _countdownTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Stopwatch & Timer',
        helpContentKey: 'STOPWATCH_TIMER_TOOL',
        bottom: PreferredSize(
          // FIX: Wrap TabBar in PreferredSize
          preferredSize: const Size.fromHeight(
            kTextTabBarHeight,
          ), // Explicitly set TabBar height
          child: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Stopwatch', icon: Icon(Icons.timer_outlined)),
              Tab(text: 'Timer', icon: Icon(Icons.hourglass_empty)),
            ],
            labelColor: Theme.of(context).colorScheme.onPrimary,
            unselectedLabelColor: Theme.of(context).colorScheme.onPrimary
                .withAlpha((255 * 0.7).round()), // FIX: Used withAlpha
            indicatorColor: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // --- Stopwatch Tab Content ---
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.timer,
                          size: 60,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _stopwatchDisplay,
                          style: Theme.of(
                            context,
                          ).textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontFeatures: const [
                              FontFeature.tabularFigures(),
                            ], // Monospaced numbers
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            CustomButton(
                              text: _stopwatch.isRunning ? 'Pause' : 'Start',
                              onPressed:
                                  _stopwatch.isRunning
                                      ? _pauseStopwatch
                                      : _startStopwatch,
                              icon:
                                  _stopwatch.isRunning
                                      ? Icons.pause
                                      : Icons.play_arrow,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              textStyle: const TextStyle(fontSize: 18),
                            ),
                            CustomButton(
                              text: 'Reset',
                              onPressed: _resetStopwatch,
                              icon: Icons.refresh,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              textStyle: const TextStyle(fontSize: 18),
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

          // --- Timer Tab Content ---
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.hourglass_full,
                          size: 60,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _countdownDisplay,
                          style: Theme.of(
                            context,
                          ).textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontFeatures: const [
                              FontFeature.tabularFigures(),
                            ], // Monospaced numbers
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            CustomButton(
                              text: 'Set Timer',
                              onPressed:
                                  _isCountdownRunning
                                      ? null
                                      : _setTimerDuration,
                              icon: Icons.edit,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              textStyle: const TextStyle(fontSize: 18),
                            ),
                            CustomButton(
                              text: _isCountdownRunning ? 'Pause' : 'Start',
                              onPressed:
                                  _isCountdownRunning
                                      ? _pauseCountdown
                                      : _startCountdown,
                              icon:
                                  _isCountdownRunning
                                      ? Icons.pause
                                      : Icons.play_arrow,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              textStyle: const TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        CustomButton(
                          text: 'Reset',
                          onPressed: _resetCountdown,
                          icon: Icons.refresh,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
