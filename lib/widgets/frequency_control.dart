import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';

/// A widget that displays and allows control of a radio frequency using CAT commands.
///
/// This widget displays frequencies in a human-readable format (MHz.kHz.Hz) and
/// allows users to modify frequency values using mouse wheel scrolling over different
/// segments of the frequency display.
///
/// It parses and generates Kenwood/Yaesu-style "FA" frequency commands
/// (e.g., "FA00014050000;") for radio control.
class FrequencyControl extends StatefulWidget {
  /// The initial frequency command value (e.g., "FA00014050000;")
  final String initialValue;

  /// Callback function triggered when the frequency is changed
  /// The new command string is passed as an argument
  final Function(String) onFrequencyChanged;

  /// Creates a FrequencyControl widget
  ///
  /// [initialValue] must be a valid FA command string (e.g., "FA00014050000;")
  /// [onFrequencyChanged] is called whenever the frequency is adjusted
  const FrequencyControl({
    Key? key,
    required this.initialValue,
    required this.onFrequencyChanged,
  }) : super(key: key);

  @override
  State<FrequencyControl> createState() => _FrequencyControlState();
}

class _FrequencyControlState extends State<FrequencyControl> {
  /// The current frequency in Hertz
  late int _frequency;

  /// The step size for frequency adjustments (in Hz)
  int _stepSize = 1000; // Default step: 1 kHz

  /// Text controller for direct frequency input
  final _frequencyController = TextEditingController();

  /// Whether the user is currently editing the frequency directly
  bool _isEditing = false;

  /// The last "FA" command received or sent
  String _lastCommand = '';

  @override
  void initState() {
    super.initState();
    _parseInitialValue();
  }

  @override
  void didUpdateWidget(FrequencyControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the initial value changes from outside, update our internal state
    if (widget.initialValue != oldWidget.initialValue) {
      _parseInitialValue();
    }
  }

  @override
  void dispose() {
    _frequencyController.dispose();
    super.dispose();
  }

  /// Parses the initial FA command into a frequency value
  void _parseInitialValue() {
    if (widget.initialValue.startsWith('FA') &&
        widget.initialValue.endsWith(';')) {
      // Extract the numeric part (remove 'FA' prefix and ';' suffix)
      final numericPart = widget.initialValue.substring(
        2,
        widget.initialValue.length - 1,
      );
      try {
        _frequency = int.parse(numericPart);
        _frequencyController.text = formattedFrequency;
        _lastCommand = widget.initialValue;
      } catch (e) {
        // Default to 14.050 MHz if parsing fails
        _frequency = 14050000;
        _frequencyController.text = formattedFrequency;
        _lastCommand = 'FA00014050000;';
        print('Error parsing frequency: $e');
      }
    } else {
      // Default if not a valid FA command
      _frequency = 14050000;
      _frequencyController.text = formattedFrequency;
      _lastCommand = 'FA00014050000;';
    }
  }

  /// Converts the frequency in Hz to a formatted string (e.g., "14.050.000")
  String get formattedFrequency {
    // Convert to MHz, kHz, Hz segments
    final mhz = (_frequency / 1000000).floor();
    final khz = ((_frequency % 1000000) / 1000).floor();
    final hz = _frequency % 1000;

    // Format with leading zeros for kHz and Hz segments
    return '$mhz.${khz.toString().padLeft(3, '0')}.${hz.toString().padLeft(3, '0')}';
  }

  /// Generates an FA command string from the current frequency
  String get faCommand {
    return 'FA${_frequency.toString().padLeft(11, '0')};';
  }

  /// Updates the frequency and notifies the parent widget
  void _updateFrequency(int newFrequency) {
    // Ensure frequency is within valid ham radio range (1-30 MHz)
    newFrequency = newFrequency.clamp(1000000, 30000000);

    setState(() {
      _frequency = newFrequency;
      _frequencyController.text = formattedFrequency;
      _lastCommand = faCommand;
    });

    // Notify parent with the new command
    widget.onFrequencyChanged(faCommand);
  }

  /// Handles mouse wheel scroll events to adjust frequency
  ///
  /// [segmentIndex] determines which part of the frequency to adjust:
  ///   0 = MHz, 1 = kHz, 2 = Hz
  /// [scrollDelta] is the scroll wheel delta (negative = up, positive = down)
  void _handleScroll(int segmentIndex, double scrollDelta) {
    int step;

    // Determine which segment is being changed and the step size
    switch (segmentIndex) {
      case 0: // MHz
        step = 1000000;
        break;
      case 1: // kHz
        step = 1000;
        break;
      case 2: // Hz
        step = 1;
        break;
      default:
        return;
    }

    // Adjust for scroll direction (negative for scroll up = increase frequency)
    if (scrollDelta < 0) {
      _updateFrequency(_frequency + step);
    } else {
      _updateFrequency(_frequency - step);
    }
  }

  /// Handles tuning step button presses to adjust frequency
  ///
  /// [increment] determines direction (true = increase, false = decrease)
  void _handleTuningStep(bool increment) {
    if (increment) {
      _updateFrequency(_frequency + _stepSize);
    } else {
      _updateFrequency(_frequency - _stepSize);
    }
  }

  /// Switches to direct frequency input mode
  void _startDirectEdit() {
    setState(() {
      _isEditing = true;
    });
  }

  /// Applies the directly entered frequency and returns to display mode
  void _applyDirectEdit() {
    try {
      // Remove any non-numeric characters
      final cleanInput = _frequencyController.text.replaceAll(
        RegExp(r'[^\d]'),
        '',
      );

      if (cleanInput.isNotEmpty) {
        // Convert to integer (as Hz)
        final inputFreq = int.parse(cleanInput);
        _updateFrequency(inputFreq);
      }
    } catch (e) {
      print('Error parsing direct frequency input: $e');
    } finally {
      setState(() {
        _isEditing = false;
        _frequencyController.text = formattedFrequency;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Frequency display title
        const Text(
          'Radio Frequency',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 12),

        // Frequency display/input
        _isEditing ? _buildDirectInput() : _buildFrequencyDisplay(),

        const SizedBox(height: 20),

        // Tuning step selector
        _buildTuningStepSelector(),

        const SizedBox(height: 15),

        // Tuning buttons
        _buildTuningButtons(),

        const SizedBox(height: 10),

        // Command display (for debugging/information)
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'CAT Command: $_lastCommand',
            style: const TextStyle(fontFamily: 'Monospace', fontSize: 14),
          ),
        ),
      ],
    );
  }

  /// Builds a direct text input field for frequency entry
  Widget _buildDirectInput() {
    return SizedBox(
      width: 200,
      child: TextField(
        controller: _frequencyController,
        autofocus: true,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontFamily: 'Monospace',
        ),
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          hintText: 'Enter frequency in Hz',
        ),
        onSubmitted: (_) => _applyDirectEdit(),
      ),
    );
  }

  /// Builds the interactive frequency display with scrollable segments
  Widget _buildFrequencyDisplay() {
    final segments = formattedFrequency.split('.');

    return GestureDetector(
      onTap: _startDirectEdit,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // MHz segment (first segment)
          _buildFrequencySegment(segments[0], 0),

          // Dot separator
          Text(
            '.',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          // kHz segment (second segment)
          _buildFrequencySegment(segments[1], 1),

          // Dot separator
          Text(
            '.',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          // Hz segment (third segment)
          _buildFrequencySegment(segments[2], 2),
        ],
      ),
    );
  }

  /// Builds an individual segment of the frequency display (MHz, kHz, or Hz)
  ///
  /// [value] is the text to display
  /// [segmentIndex] determines which part of the frequency this segment represents
  Widget _buildFrequencySegment(String value, int segmentIndex) {
    return Listener(
      // Listen for mouse wheel events
      onPointerSignal: (pointerSignal) {
        if (pointerSignal is PointerScrollEvent) {
          _handleScroll(segmentIndex, pointerSignal.scrollDelta.dy);
        }
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeUpDown,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Monospace',
            ),
          ),
        ),
      ),
    );
  }

  /// Builds a selector for tuning step size
  Widget _buildTuningStepSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tuning Step:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SegmentedButton<int>(
          segments: [
            ButtonSegment<int>(value: 1, label: Text('1 Hz')),
            ButtonSegment<int>(value: 10, label: Text('10 Hz')),
            ButtonSegment<int>(value: 100, label: Text('100 Hz')),
            ButtonSegment<int>(value: 1000, label: Text('1 kHz')),
            ButtonSegment<int>(value: 10000, label: Text('10 kHz')),
          ],
          selected: {_stepSize},
          onSelectionChanged: (Set<int> selection) {
            setState(() {
              _stepSize = selection.first;
            });
          },
        ),
      ],
    );
  }

  /// Builds the up/down tuning buttons
  Widget _buildTuningButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Decrease frequency button
        ElevatedButton(
          onPressed: () => _handleTuningStep(false),
          child: Icon(Icons.remove),
          style: ElevatedButton.styleFrom(
            shape: CircleBorder(),
            padding: EdgeInsets.all(16),
          ),
        ),

        SizedBox(width: 20),

        // Increase frequency button
        ElevatedButton(
          onPressed: () => _handleTuningStep(true),
          child: Icon(Icons.add),
          style: ElevatedButton.styleFrom(
            shape: CircleBorder(),
            padding: EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }
}
