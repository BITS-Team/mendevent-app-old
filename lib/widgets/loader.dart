import 'package:flutter/material.dart';

class AppLoader extends StatefulWidget {
  @override
  _AppLoaderState createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader> with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> animation_rotation;
  Animation<double> animation_to_small;
  Animation<double> animation_to_big;
  final double initialRadius = 50.0;
  double radius = 0.0;

  _AppLoaderState();
  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: Duration(seconds: 5));
    animation_rotation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: controller, curve: Interval(0.0, 1.0, curve: Curves.linear)));

    animation_to_small = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: controller, curve: Interval(0.75, 1.0, curve: Curves.elasticIn)));
    animation_to_big = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: controller, curve: Interval(0.0, 0.25, curve: Curves.elasticOut)));

    controller.addListener(() {
      setState(() {
        if (controller.value >= 0.75 && controller.value <= 1.0) {
          radius = animation_to_small.value * initialRadius;
        } else if (controller.value >= 0.0 && controller.value <= 0.25) {
          radius = animation_to_big.value * initialRadius;
        }
      });
    });
    controller.repeat();
  }
  @override
  void dispose() {
    controller.dispose();
    super.dispose();

  }
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 150,
        height: 150,
        child: Center(
                child: RotationTransition(
                  turns: animation_rotation,
                  child: Stack(
                    children: <Widget>[
                      AnimatedObject(
                        color: Colors.white,
                        //            color: Colors.red,
                        radius: radius + initialRadius,
                        image: Image.asset(
                          'assets/logo_without_text.png',
                          color: Color(0xff021863),
                        ),
                      )
                    ],
                  ),
                ),
              )

        );
  }

}

class AnimatedObject extends StatelessWidget {
  final Image image;
  final Color color;
  final double radius;

  AnimatedObject({this.image, this.color, this.radius});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: this.radius,
        height: this.radius,
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: this.color,
          shape: BoxShape.circle,
        ),
        child: this.image);
  }
}
