import 'package:flutter/material.dart';

enum CharacterOutfit { adventure, underwater, strategy, city }

class CharacterAnimator extends StatefulWidget {
  final bool isWalking;
  final double size;
  final CharacterOutfit outfit;

  const CharacterAnimator({
    super.key,
    this.isWalking = false,
    this.size = 100,
    this.outfit = CharacterOutfit.adventure,
  });

  @override
  State<CharacterAnimator> createState() => _CharacterAnimatorState();
}

class _CharacterAnimatorState extends State<CharacterAnimator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              0,
              widget.isWalking ? -5 * _controller.value : 0, // Bobbing effect
            ),
            child: child,
          );
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Body
            Container(
              width: widget.size * 0.4,
              height: widget.size * 0.6,
              decoration: BoxDecoration(
                color: _getBodyColor(),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            // Head
            Positioned(
              top: 0,
              child: Container(
                width: widget.size * 0.3,
                height: widget.size * 0.3,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFCC80), // Skin tone
                  shape: BoxShape.circle,
                ),
                child: _getHeadAccessory(),
              ),
            ),
            // Accessory (Backpack/Cape/Toolbelt)
            _getAccessory(),
            // Legs
            Positioned(
              bottom: 0,
              left: widget.size * 0.35,
              child: Container(
                width: widget.size * 0.08,
                height: widget.size * 0.25,
                color: Colors.black,
              ),
            ),
            Positioned(
              bottom: 0,
              right: widget.size * 0.35,
              child: Container(
                width: widget.size * 0.08,
                height: widget.size * 0.25,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBodyColor() {
    switch (widget.outfit) {
      case CharacterOutfit.underwater:
        return Colors.blue[800]!; // Wetsuit
      case CharacterOutfit.strategy:
        return Colors.grey[800]!; // Suit
      case CharacterOutfit.city:
        return Colors.orange[700]!; // Safety vest
      case CharacterOutfit.adventure:
      default:
        return Colors.green[700]!; // Eco suit
    }
  }

  Widget _getHeadAccessory() {
    if (widget.outfit == CharacterOutfit.underwater) {
      return Icon(Icons.scuba_diving, size: widget.size * 0.25, color: Colors.black);
    } else if (widget.outfit == CharacterOutfit.city) {
      return Icon(Icons.construction, size: widget.size * 0.25, color: Colors.yellow); // Hard hat metaphor
    }
    return Icon(Icons.face, size: widget.size * 0.25, color: Colors.brown);
  }

  Widget _getAccessory() {
    if (widget.outfit == CharacterOutfit.adventure) {
      return Positioned(
        right: widget.size * 0.2,
        top: widget.size * 0.3,
        child: Container(
          width: widget.size * 0.15,
          height: widget.size * 0.25,
          decoration: BoxDecoration(
            color: Colors.brown[400],
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      );
    } else if (widget.outfit == CharacterOutfit.underwater) {
      return Positioned(
        right: widget.size * 0.15,
        top: widget.size * 0.2,
        child: Container(
          width: widget.size * 0.1,
          height: widget.size * 0.4,
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ); // Oxygen tank
    }
    return const SizedBox();
  }
}
