import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';

class HomeView extends GetView<AuthController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            decoration: const BoxDecoration(color: Color(0xFF101014)),
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Stack(
                    children: [
                      _buildRotatedContainer(
                        constraints,
                        0.25,
                        0.35,
                        0.6,
                        0.12,
                        -0.31,
                        const Color(0xFFE0E2FB),
                        'App',
                        64,
                        FontWeight.w700,
                      ),
                      _buildContainer(
                        constraints,
                        0.1,
                        0.47,
                        0.7,
                        0.12,
                        const Color(0xFFB5B8E5),
                        'For',
                        64,
                        FontWeight.w700,
                      ),
                      _buildRotatedContainer(
                        constraints,
                        0.3,
                        0.59,
                        0.55,
                        0.12,
                        -0.23,
                        const Color(0xFFFBC87B),
                        'Rent!',
                        64,
                        FontWeight.w700,
                      ),
                      _buildRotatedContainer(
                        constraints,
                        0.1,
                        0.22,
                        0.8,
                        0.12,
                        -0.05,
                        const Color(0xFFF8F8F8),
                        'Amazing',
                        64,
                        FontWeight.w500,
                      ),
                      _buildButton(
                        constraints,
                        0.1,
                        0.82,
                        0.8,
                        0.07,
                        const Color(0xFF282828),
                        'Continue with Phone',
                        const Color(0xFFF8F8F8),
                        'assets/images/phone.png',
                        () {
                          Get.toNamed("/login");
                        },
                      ),
                      _buildButton(
                        constraints,
                        0.1,
                        0.74,
                        0.8,
                        0.07,
                        const Color(0xFFF8F8F8),
                        'Continue with Google',
                        const Color(0xFF282828),
                        'assets/images/google.png',
                        () {
                          controller.signInWithGoogle();
                          }
               
                      ),
      
                        _buildCombinedText(
                        constraints,
                        0.25,
                        0.92,
                        "Don't have an account?",
                        "Create account",
                        const Color(0xFFF8F8F8),
                        const Color(0xFFFBC87B),
                        11,
                        () {
                          Get.toNamed("/register");
                        },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRotatedContainer(
    BoxConstraints constraints,
    double left,
    double top,
    double width,
    double height,
    double angle,
    Color color,
    String text,
    double fontSize,
    FontWeight fontWeight,
  ) {
    return Positioned(
      left: constraints.maxWidth * left,
      top: constraints.maxHeight * top,
      child: Transform.rotate(
        angle: angle,
        child: Container(
          width: constraints.maxWidth * width,
          height: constraints.maxHeight * height,
          decoration: ShapeDecoration(
            color: color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: const Color(0xFF101014),
                fontSize: fontSize,
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: fontWeight,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContainer(
    BoxConstraints constraints,
    double left,
    double top,
    double width,
    double height,
    Color color,
    String text,
    double fontSize,
    FontWeight fontWeight,
  ) {
    return Positioned(
      left: constraints.maxWidth * left,
      top: constraints.maxHeight * top,
      child: Container(
        width: constraints.maxWidth * width,
        height: constraints.maxHeight * height,
        decoration: ShapeDecoration(
          color: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: const Color(0xFF101014),
              fontSize: fontSize,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: fontWeight,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(
    BoxConstraints constraints,
    double left,
    double top,
    double width,
    double height,
    Color color,
    String text,
    Color textColor,
    String imagePath,
    VoidCallback onTap,
  ) {
    return Positioned(
      left: constraints.maxWidth * left,
      top: constraints.maxHeight * top,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: constraints.maxWidth * width,
          height: constraints.maxHeight * height,
          decoration: ShapeDecoration(
            color: color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                imagePath,
                width: constraints.maxWidth * 0.05,
                height: constraints.maxWidth * 0.05,
              ),
              const SizedBox(width: 10),
              Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontSize: 15,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
Widget _buildCombinedText(
    BoxConstraints constraints,
    double left,
    double top,
    String text1,
    String text2,
    Color color1,
    Color color2,
    double fontSize,
    VoidCallback onTap,
  ) {
    return Positioned(
      left: constraints.maxWidth * left,
      top: constraints.maxHeight * top,
      child: Row(
        children: [
          Text(
            text1,
            style: TextStyle(
              color: color1,
              fontSize: fontSize,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 5), // Add some space between the texts
          GestureDetector(
            onTap: onTap,
            child: Text(
              text2,
              style: TextStyle(
                color: color2,
                fontSize: fontSize,
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}