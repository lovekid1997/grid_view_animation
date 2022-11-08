import 'dart:async';

import 'package:flutter/material.dart';
import 'package:grid_animation/objects/objects.dart';
import 'package:grid_animation/shared/common.dart';

class CardWidget extends StatefulWidget {
  const CardWidget({
    Key? key,
    required this.create,
    required this.delayPerItem,
    required this.gridAnimationObject,
    required this.initialFadeAnimation,
  }) : super(key: key);
  final Function(GridAnimationObject) create;
  final bool delayPerItem;
  final GridAnimationObject gridAnimationObject;
  final bool initialFadeAnimation;

  @override
  State<CardWidget> createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> with TickerProviderStateMixin {
  // animation
  late Animation<double> animation;
  late AnimationController animationController;

  // state
  Timer? delayedStartAnimationCard;
  bool firstTimeBuild = true;

  // getter
  GridAnimationObject get gridAnimationObject => widget.gridAnimationObject;
  int get index => widget.gridAnimationObject.index;

  @override
  void initState() {
    // get renderBox
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.create(gridAnimationObject);
    });
    createAnimationOpacity();
    startAnimation();
    addListenController();
    super.initState();
  }

  void createAnimationOpacity() {
    // animation
    animationController = AnimationController(
      vsync: this,
      duration: dealDuration,
      reverseDuration: dealDuration,
    );
    animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: curves,
      reverseCurve: curves,
    ))
      ..addListener(() {
        setState(() {});
      });
  }

  /// plus fadeInitDuration when first time build widget and initialFadeAnimation = [True]
  void startAnimation() {
    var delayDuration = deplayPerItemDuration(
      widget.delayPerItem,
      index,
    );
    if (firstTimeBuild) {
      delayDuration = widget.initialFadeAnimation
          ? fadeInitDuration + delayDuration
          : delayDuration;
    }
    delayedStartAnimationCard = Timer(delayDuration, () {
      animationController.forward();
    });
    firstTimeBuild = false;
  }

  void addListenController() {
    gridAnimationObject.addListenRefreshOnCard(
      animationController,
      delayedStartAnimationCard,
      startAnimation,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: gridAnimationObject.globalKey,
      child: Opacity(
        opacity: animation.value >= 1 ? 1 : 0,
        child: gridAnimationObject.child,
      ),
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    delayedStartAnimationCard?.cancel();
    delayedStartAnimationCard = null;
    super.dispose();
  }
}
