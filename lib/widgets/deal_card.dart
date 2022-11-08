import 'dart:async';

import 'package:flutter/material.dart';
import 'package:grid_animation/objects/objects.dart';
import 'package:grid_animation/shared/common.dart';

class DealStack extends StatelessWidget {
  const DealStack({
    super.key,
    required this.gridAnimationDealObjects,
    required this.delayPerItem,
    required this.initialFadeAnimation,
    required this.fadeAnimation,
  });

  final List<GridAnimationObject> gridAnimationDealObjects;
  final bool delayPerItem;
  final bool initialFadeAnimation;
  final bool fadeAnimation;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(
        gridAnimationDealObjects.length,
        (index) => _DealCard(
          gridAnimationDealObject: gridAnimationDealObjects.elementAt(index),
          delayPerItem: delayPerItem,
          initialFadeAnimation: initialFadeAnimation,
          fadeAnimation: fadeAnimation,
        ),
      ),
    );
  }
}

class _DealCard extends StatefulWidget {
  const _DealCard({
    required this.gridAnimationDealObject,
    required this.delayPerItem,
    required this.initialFadeAnimation,
    required this.fadeAnimation,
  });

  final GridAnimationObject gridAnimationDealObject;
  final bool delayPerItem;
  final bool initialFadeAnimation;
  final bool fadeAnimation;
  @override
  State<_DealCard> createState() => _DealCardState();
}

class _DealCardState extends State<_DealCard> with TickerProviderStateMixin {
  // animation
  late Animation<Offset> transitionAnimation;
  Animation<double>? fadeAnimation;
  late AnimationController animationController;

  // fade initial animation
  Animation<double>? initFadeAnimation;
  AnimationController? initFadeAnimationController;

  // state
  bool _hidden = false;
  Timer? delayedStartAnimationCardDeal;

  // getter
  GridAnimationObject get gridAnimationObject => widget.gridAnimationDealObject;

  @override
  void initState() {
    /// The initial effect renders the first element
    /// control by [initialFadeAnimation]
    final createSuccessInItFadeAnimation = createInitFadeAnimation();

    // create transition animation
    createTransitionAnimation();

    /// create effect all element
    /// control by [fadeAnimation]
    createFadeAnimation();

    ///
    if (!createSuccessInItFadeAnimation) {
      startAnimation();
      addListenController();
    }

    super.initState();
  }

  /// [startAnimation] use when [initialFadeAnimation] is [True] and animation status complete
  bool createInitFadeAnimation() {
    if (!widget.initialFadeAnimation) {
      return false;
    }
    // animation
    initFadeAnimationController = AnimationController(
      vsync: this,
      duration: fadeInitDuration,
    );
    initFadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: initFadeAnimationController!,
      curve: curves,
      reverseCurve: curves,
    ))
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        switch (status) {
          case AnimationStatus.completed:
            startAnimation();
            addListenController();
            break;
          default:
            break;
        }
      });
    initFadeAnimationController!.forward();
    return true;
  }

  void createTransitionAnimation() {
    // animation
    animationController = AnimationController(
      vsync: this,
      duration: dealDuration,
      reverseDuration: dealDuration,
    );
    transitionAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: calcOffsetEndItem,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: curves,
      reverseCurve: curves,
    ))
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        switch (status) {
          case AnimationStatus.dismissed:
            break;
          case AnimationStatus.forward:
            break;
          case AnimationStatus.reverse:
            _hidden = false;
            break;
          case AnimationStatus.completed:
            _hidden = true;
            break;
        }
      });
  }

  void createFadeAnimation() {
    if (!widget.fadeAnimation) {
      return;
    }
    fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: animationController,
        curve: curves,
        reverseCurve: curves,
      ),
    );
  }

  /// add listener reverse transion animation [transitionAnimation], cancel [delayedStartAnimationCardDeal] when refresh
  /// call when [animationController], [delayedStartAnimationCardDeal] has created
  /// call after [startAnimation]
  void addListenController() {
    gridAnimationObject.addListenRefreshOnDealCard(
      animationController,
      delayedStartAnimationCardDeal,
      startAnimation,
    );
  }

  /// create [delayedStartAnimationCardDeal]
  /// call before [addListenController]
  void startAnimation() {
    delayedStartAnimationCardDeal = Timer(
      deplayPerItemDuration(
        widget.delayPerItem,
        gridAnimationObject.index,
      ),
      () {
        animationController.forward();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: transitionAnimation.value.dx,
      top: transitionAnimation.value.dy,
      child: Opacity(
        opacity: opacity,
        child: Visibility(
          visible: !_hidden,
          child: SizedBox.fromSize(
            size: gridAnimationObject.size,
            child: gridAnimationObject.child,
          ),
        ),
      ),
    );
  }

  // getter
  double get opacity {
    if (gridAnimationObject.firstItem) {
      return initFadeAnimation?.value ?? 1;
    }
    return fadeAnimation?.value ?? 1;
  }

  Offset get calcOffsetEndItem =>
      (gridAnimationObject.myOffset! - gridAnimationObject.rootOffset!);

  @override
  void dispose() {
    animationController.dispose();
    initFadeAnimationController?.dispose();
    delayedStartAnimationCardDeal?.cancel();
    delayedStartAnimationCardDeal = null;
    gridAnimationObject.dispose();
    super.dispose();
  }
}
