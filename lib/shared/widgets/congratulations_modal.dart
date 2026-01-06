import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class CongratulationsModal extends StatefulWidget {
  final String courseTitle;
  final VoidCallback onWriteReview;
  final VoidCallback onClose;

  const CongratulationsModal({
    super.key,
    required this.courseTitle,
    required this.onWriteReview,
    required this.onClose,
  });

  @override
  State<CongratulationsModal> createState() => _CongratulationsModalState();
}

class _CongratulationsModalState extends State<CongratulationsModal>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiControllerLeft;
  late ConfettiController _confettiControllerRight;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _confettiControllerLeft = ConfettiController(
      duration: const Duration(seconds: 5),
    );
    _confettiControllerRight = ConfettiController(
      duration: const Duration(seconds: 5),
    );

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    // Start animations
    _animationController.forward();
    _confettiControllerLeft.play();
    _confettiControllerRight.play();
  }

  @override
  void dispose() {
    _confettiControllerLeft.dispose();
    _confettiControllerRight.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Confetti from left top corner
        Align(
          alignment: Alignment.topLeft,
          child: ConfettiWidget(
            confettiController: _confettiControllerLeft,
            blastDirection: 0,
            blastDirectionality: BlastDirectionality.explosive,
            maxBlastForce: 20,
            minBlastForce: 10,
            emissionFrequency: 0.01,
            numberOfParticles: 50,
            gravity: 0.1,
            colors: const [
              Color(0xFF581C87),
              Color(0xFF9D65AA),
              Colors.amber,
              Colors.pink,
              Colors.blue,
              Colors.orange,
            ],
          ),
        ),
        // Confetti from right top corner
        Align(
          alignment: Alignment.topRight,
          child: ConfettiWidget(
            confettiController: _confettiControllerRight,
            blastDirection: 3.14,
            blastDirectionality: BlastDirectionality.explosive,
            maxBlastForce: 20,
            minBlastForce: 10,
            emissionFrequency: 0.01,
            numberOfParticles: 50,
            gravity: 0.1,
            colors: const [
              Color(0xFF581C87),
              Color(0xFF9D65AA),
              Colors.amber,
              Colors.pink,
              Colors.blue,
              Colors.orange,
            ],
          ),
        ),
        // Dialog content
        Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Dialog(
                backgroundColor: Colors.transparent,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                         Colors.white,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF581C87).withOpacity(0.3),
                        blurRadius: 40,
                        offset: const Offset(0, 15),
                      ),
                    ],
                    border: Border.all(
                      color: const Color(0xFF581C87).withOpacity(0.1),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 32),
                      // Trophy with animated glow
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF581C87), Color(0xFF9D65AA)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF581C87).withOpacity(0.4),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.emoji_events,
                          size: 56,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 28),
                      // Congratulations text
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'Congratulations!',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF581C87),
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF581C87).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'You\'ve completed',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          widget.courseTitle,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF581C87),
                            height: 1.3,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 36),
                      // Buttons
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: widget.onWriteReview,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF581C87),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                              shadowColor: const Color(
                                0xFF581C87,
                              ).withOpacity(0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Write a Review',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: widget.onClose,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: Text(
                          'Maybe Later',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
