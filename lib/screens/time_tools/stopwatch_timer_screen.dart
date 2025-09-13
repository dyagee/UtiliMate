// lib/screens/time_tools/stopwatch_timer_screen.dart
import 'package:flutter/material.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
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

  final StopWatchTimer _stopWatchTimer = StopWatchTimer();
  late final StopWatchTimer _countDownTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _countDownTimer = StopWatchTimer(
      mode: StopWatchMode.countDown,
      onEnded: () {
        _showTimerFinishedDialog();
      },
    );
  }

  // --- Stopwatch Methods ---
  void _startStopwatch() {
    _stopWatchTimer.onStartTimer();
  }

  void _pauseStopwatch() {
    _stopWatchTimer.onStopTimer();
  }

  void _resetStopwatch() {
    _stopWatchTimer.onResetTimer();
  }

  // --- Timer Methods ---
  void _setTimerDuration() async {
    int initialHours = _countDownTimer.rawTime.value ~/ (1000 * 60 * 60);
    int initialMinutes = (_countDownTimer.rawTime.value ~/ (1000 * 60)) % 60;
    int initialSeconds = (_countDownTimer.rawTime.value ~/ 1000) % 60;

    final hoursController = TextEditingController(
      text: initialHours.toString().padLeft(2, '0'),
    );
    final minutesController = TextEditingController(
      text: initialMinutes.toString().padLeft(2, '0'),
    );
    final secondsController = TextEditingController(
      text: initialSeconds.toString().padLeft(2, '0'),
    );

    if (_countDownTimer.rawTime.value == 0) {
      minutesController.text = '05';
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Set Countdown Duration'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 50,
                child: TextField(
                  controller: hoursController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(labelText: 'HH'),
                ),
              ),
              const Text(':'),
              SizedBox(
                width: 50,
                child: TextField(
                  controller: minutesController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(labelText: 'MM'),
                ),
              ),
              const Text(':'),
              SizedBox(
                width: 50,
                child: TextField(
                  controller: secondsController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(labelText: 'SS'),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Set'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      final hours = int.tryParse(hoursController.text) ?? 0;
      final minutes = int.tryParse(minutesController.text) ?? 0;
      final seconds = int.tryParse(secondsController.text) ?? 0;

      if (hours >= 0 && minutes >= 0 && seconds >= 0) {
        final totalMilliseconds =
            (hours * 3600 + minutes * 60 + seconds) * 1000;
        _countDownTimer.onResetTimer();
        _countDownTimer.setPresetTime(mSec: totalMilliseconds);
      }
    }
  }

  void _startCountdown() {
    _countDownTimer.onStartTimer();
  }

  void _pauseCountdown() {
    _countDownTimer.onStopTimer();
  }

  void _resetCountdown() {
    _countDownTimer.onResetTimer();
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
                _resetCountdown();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
      barrierDismissible: false,
    );
  }

  @override
  void dispose() async {
    _tabController.dispose();
    super.dispose();
    await _stopWatchTimer.dispose();
    await _countDownTimer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Stopwatch & Timer',
        helpContentKey: 'STOPWATCH_TIMER_TOOL',
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kTextTabBarHeight),
          child: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Stopwatch', icon: Icon(Icons.timer_outlined)),
              Tab(text: 'Timer', icon: Icon(Icons.hourglass_empty)),
            ],
            labelColor: Theme.of(context).colorScheme.onPrimary,
            unselectedLabelColor: Theme.of(
              context,
            ).colorScheme.onPrimary.withAlpha((255 * 0.7).round()),
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
                        StreamBuilder<int>(
                          stream: _stopWatchTimer.rawTime,
                          initialData: _stopWatchTimer.rawTime.value,
                          builder: (context, snap) {
                            final value = snap.data!;
                            final displayTime = StopWatchTimer.getDisplayTime(
                              value,
                              hours: true,
                              milliSecond: true,
                            );
                            return Text(
                              displayTime,
                              style: Theme.of(
                                context,
                              ).textTheme.displayMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                                fontSize: 24,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            StreamBuilder<int>(
                              stream: _stopWatchTimer.rawTime,
                              initialData: _stopWatchTimer.rawTime.value,
                              builder: (context, snap) {
                                final isRunning = _stopWatchTimer.isRunning;
                                return CustomButton(
                                  text: isRunning ? 'Pause' : 'Start',
                                  onPressed:
                                      isRunning
                                          ? _pauseStopwatch
                                          : _startStopwatch,
                                  icon:
                                      isRunning
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  textStyle: const TextStyle(fontSize: 18),
                                );
                              },
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
                        StreamBuilder<int>(
                          stream: _countDownTimer.rawTime,
                          initialData: _countDownTimer.rawTime.value,
                          builder: (context, snap) {
                            final value = snap.data!;
                            final displayTime = StopWatchTimer.getDisplayTime(
                              value,
                              hours: false,
                              milliSecond: false,
                            );
                            return Text(
                              displayTime,
                              style: Theme.of(
                                context,
                              ).textTheme.displayMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        CustomButton(
                          text: 'Set Timer',
                          onPressed:
                              _countDownTimer.isRunning
                                  ? null
                                  : _setTimerDuration,
                          icon: Icons.edit,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            StreamBuilder<int>(
                              stream: _countDownTimer.rawTime,
                              initialData: _countDownTimer.rawTime.value,
                              builder: (context, snap) {
                                final isRunning = _countDownTimer.isRunning;
                                return CustomButton(
                                  text: isRunning ? 'Pause' : 'Start',
                                  onPressed:
                                      isRunning
                                          ? _pauseCountdown
                                          : _startCountdown,
                                  icon:
                                      isRunning
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  textStyle: const TextStyle(fontSize: 18),
                                );
                              },
                            ),
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
