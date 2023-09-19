import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'Webview.dart';

import 'main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fallAnimation;
  late Animation<double> _jumpAnimation;
  final double initialHeight = 0.0; // The initial height of the ball
  final double maxHeight = 200.0;

  final db = FirebaseFirestore.instance.collection('data');
  late bool isUpdate;
  late String googlePlayLink;
  late String appStoreLink;
  late String my_web_link;

   fetchData() async {

    await db.doc("data1").get().then((event) {
      setState(() {
        isUpdate = event['switch'];
        print('888 $isUpdate');
        my_web_link = event['my_web_link'];
        googlePlayLink = event['google_play_link'];
        appStoreLink = event['app_store_link'];
      });} ).then((value) {
      _animationController.addStatusListener((status) {
        // if (status == AnimationStatus.completed) {
          // Animation completed, navigate to the next page
          Timer(const Duration(milliseconds: 2000), () {
            _animationController.dispose();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => InAppWebViewScreen(
                isUpdate: isUpdate ,
                googlePlayLink: googlePlayLink,
                appStoreLink:appStoreLink,
                my_web_link: my_web_link,
              ),),
            );
          });

      });
      // Timer(const Duration(milliseconds: 5000), () {
      //   _animationController.dispose();
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(builder: (context) => InAppWebViewScreen(
      //       isUpdate: isUpdate ,
      //       googlePlayLink: googlePlayLink,
      //       appStoreLink:appStoreLink,
      //       my_web_link: my_web_link,
      //     ),),
      //   );
      // });
      });}
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fallAnimation = Tween<double>(begin: initialHeight, end: maxHeight).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _jumpAnimation = Tween<double>(begin: maxHeight, end: initialHeight).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );
    _animationController.repeat(reverse: true);
    fetchData();

  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (BuildContext context, Widget? child) {
          return Transform.translate(
            offset: Offset(0.0, _fallAnimation.value),
            child: Center(
              child: Image.asset(
                'assets/logo.png',
                fit: BoxFit.fill,
                height: 150,
              ),
            ),
          );
        },
      ),
    );
  }
}
