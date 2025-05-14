import 'package:flutter/material.dart';

class CustomAnimatedButton extends StatefulWidget {
  final VoidCallback onButtonpressed;
  final String buttonTitle;
  final Color buttonColor;
  final double width;
  final Color borderColor;
  final Color textColor;
  final double buttonPadding;

  const CustomAnimatedButton(
      {Key? key,
      required this.onButtonpressed,
      required this.buttonTitle,
      this.buttonColor = const Color(0xFF216FFF),
      this.width = double.infinity,
      this.borderColor = const Color(0xFF216FFF),
      this.textColor = const Color(0xFFFFFFFF),
      this.buttonPadding = 0})
      : super(key: key);

  @override
  State<CustomAnimatedButton> createState() => _CustomAnimatedButtonState();
}

class _CustomAnimatedButtonState extends State<CustomAnimatedButton> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _scale = 0.9;
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _scale = 1.0;
    });
  }

  void _onTapCancel() {
    setState(() {
      _scale = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: InkWell(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: widget.onButtonpressed,
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 100),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: widget.buttonColor,
              border: Border.all(
                color: widget.borderColor, // 🔴 Border color
                width: 2, // Optional: Border width
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.all(widget.buttonPadding),
                  child: Text(
                    widget.buttonTitle,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: widget.textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
