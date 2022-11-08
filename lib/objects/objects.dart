import 'dart:async';

import 'package:flutter/material.dart';

import '../shared/enum.dart';

class GridAnimationObject {
  final GlobalKey globalKey;
  final int index;
  final Widget child;
  final StreamController<GridViewAnimationAction>? animationActionStream;
  Offset? rootOffset;
  Offset? myOffset;
  Size? size;

  GridAnimationObject({
    required this.globalKey,
    required this.index,
    required this.child,
    required this.animationActionStream,
    required this.rootOffset,
    required this.myOffset,
    required this.size,
  });

  factory GridAnimationObject.init(int index, Widget child,
      StreamController<GridViewAnimationAction>? controller) {
    return GridAnimationObject(
      globalKey: GlobalKey(),
      index: index,
      child: child,
      animationActionStream: controller,
      myOffset: null,
      rootOffset: null,
      size: null,
    );
  }
  void copyWith({
    Offset? rootOffset,
    Offset? myOffset,
    Size? size,
  }) {
    this.rootOffset = rootOffset ?? rootOffset;
    this.myOffset = myOffset ?? myOffset;
    this.size = size ?? size;
  }

  // first item
  bool get firstItem => index == 0;

  bool get hasRootOffset => rootOffset != null;

  /// size [_DealCard]
  double? get width => size?.width;
  double? get height => size?.height;

  StreamSubscription? _listenSubcriptionOnDealCard;
  StreamSubscription? _listenSubcriptionOnCard;

  /// add listen refresh
  /// register listener when [controller] != null
  void addListenRefreshOnDealCard(
    AnimationController animationController,
    Timer? delayedStartAnimationCardDeal,
    void Function() startAnimation,
  ) {
    if (animationActionStream == null) {
      return;
    }
    _listenSubcriptionOnDealCard ??=
        animationActionStream!.stream.listen((event) async {
      switch (event) {
        case GridViewAnimationAction.refresh:
          delayedStartAnimationCardDeal?.cancel();
          animationController.reverse().then((_) {
            animationController.forward();
          });
          break;
        case GridViewAnimationAction.deal:
          startAnimation();
          break;
        case GridViewAnimationAction.cancel:
          delayedStartAnimationCardDeal?.cancel();
          animationController.reverse();
          break;
      }
    });
  }

  ///add listen refresh
  /// register listener when [controller] != null
  void addListenRefreshOnCard(
    AnimationController animationController,
    Timer? delayedStartAnimationCard,
    void Function() startAnimation,
  ) {
    if (animationActionStream == null) {
      return;
    }
    _listenSubcriptionOnCard ??= animationActionStream!.stream.listen((event) {
      switch (event) {
        case GridViewAnimationAction.refresh:
          delayedStartAnimationCard?.cancel();
          animationController.reverse().then((_) {
            animationController.forward();
          });
          break;
        case GridViewAnimationAction.deal:
          startAnimation();
          break;
        case GridViewAnimationAction.cancel:
          delayedStartAnimationCard?.cancel();
          animationController.reverse();
          break;
      }
    });
  }

  void dispose() {
    // deal card
    _listenSubcriptionOnDealCard?.cancel();
    _listenSubcriptionOnDealCard = null;

    // card
    _listenSubcriptionOnCard?.cancel();
    _listenSubcriptionOnCard = null;
  }
}
