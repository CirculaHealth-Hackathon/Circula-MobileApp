import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart' as lottie;

class LoadingComponent extends StatelessWidget {
  const LoadingComponent({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
      ),
      child: Center(
        child: lottie.Lottie.asset(
          'assets/animations/loading.json',
          width: 200,
          height: 200,
          repeat: true,
          reverse: false,
          animate: true,
        ),
      ),
    );
  }
}
