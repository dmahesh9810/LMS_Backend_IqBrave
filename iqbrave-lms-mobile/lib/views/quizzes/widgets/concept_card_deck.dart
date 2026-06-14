import 'package:flutter/material.dart';

class ConceptCardDeckWidget extends StatefulWidget {
  final List<dynamic> cards;
  final String? keyTakeaway;
  final VoidCallback onStartQuiz;

  const ConceptCardDeckWidget({
    Key? key,
    required this.cards,
    this.keyTakeaway,
    required this.onStartQuiz,
  }) : super(key: key);

  @override
  State<ConceptCardDeckWidget> createState() => _ConceptCardDeckWidgetState();
}

class _ConceptCardDeckWidgetState extends State<ConceptCardDeckWidget> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextCard() {
    if (_currentIndex < widget.cards.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      setState(() {
        _currentIndex++; // Push to Key Takeaway view
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isFinished = _currentIndex >= widget.cards.length;

    return Column(
      children: [
        // ── Progress Bar ────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white54),
                onPressed: () => Navigator.of(context).pop(),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: isFinished
                        ? 1.0
                        : (_currentIndex + 1) / (widget.cards.length + 1),
                    backgroundColor: Colors.white10,
                    color: Colors.blueAccent,
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 48), // Balance icon button
            ],
          ),
        ),

        // ── Cards View ──────────────────────────────────────────────────
        Expanded(
          child: isFinished ? _buildKeyTakeaway() : _buildCardsPager(),
        ),

        // ── Bottom Action Button ────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 40),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isFinished ? Colors.green.shade600 : Colors.blueAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
              ),
              onPressed: isFinished ? widget.onStartQuiz : _nextCard,
              child: Text(
                isFinished ? 'Start Quiz ✨' : 'Got it! Continue',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardsPager() {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: (index) => setState(() => _currentIndex = index),
      itemCount: widget.cards.length,
      itemBuilder: (context, index) {
        final card = widget.cards[index];
        final bool isActive = index == _currentIndex;
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.only(
            left: 8, right: 8,
            top: isActive ? 10 : 30,
            bottom: isActive ? 20 : 40,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white12),
            boxShadow: [
              if (isActive)
                BoxShadow(
                  color: Colors.blueAccent.withValues(alpha: 0.15),
                  blurRadius: 24,
                  spreadRadius: 4,
                )
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  card['emoji'] ?? '💡',
                  style: const TextStyle(fontSize: 72),
                ),
                const SizedBox(height: 24),
                Text(
                  card['title'] ?? 'Concept',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  card['body'] ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildKeyTakeaway() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.star_rounded, color: Colors.amber, size: 64),
          ),
          const SizedBox(height: 32),
          const Text(
            'Key Takeaway',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.amber,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.keyTakeaway ?? 'You are ready for the quiz!',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Let\'s see how much you remember.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.white54),
          ),
        ],
      ),
    );
  }
}
