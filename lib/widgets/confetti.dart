import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class ConfettiPopup extends StatefulWidget {
  final String petName;

  const ConfettiPopup({super.key, required this.petName});

  @override
  _ConfettiPopupState createState() => _ConfettiPopupState();
}

class _ConfettiPopupState extends State<ConfettiPopup> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      // Use Dialog instead of AlertDialog to avoid constraints issues
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Container(
        width: 300, // Set a fixed width for the container
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize
              .min, // Ensures the dialog doesn't take unnecessary space
          children: [
            Text(
              'You\'ve adopted ${widget.petName}! 🎉',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 100, // Ensuring ConfettiWidget has a defined height
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: ConfettiWidget(
                      confettiController: _confettiController,
                      blastDirectionality: BlastDirectionality.explosive,
                      shouldLoop: false,
                      colors: const [
                        Colors.green,
                        Colors.blue,
                        Colors.pink,
                        Colors.green,
                        Colors.purple,
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }
}
