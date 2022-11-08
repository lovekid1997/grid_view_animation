import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:grid_animation/objects/objects.dart';
import 'package:grid_animation/shared/common.dart';
import 'package:grid_animation/shared/controller.dart';
import 'package:grid_animation/widgets/card.dart';
import 'package:grid_animation/widgets/deal_card.dart';

class GridViewAnimation extends StatefulWidget {
  const GridViewAnimation({
    Key? key,
    required this.children,
    required this.delegate,
    this.controller,
    this.defaultDuration = dealDuration,
    this.delayPerItem = false,
    this.initialFadeAnimation = true,
    this.fadeAnimation = true,
  }) : super(key: key);

  final List<Widget> children;
  final SliverGridDelegate delegate;

  /// Used to refresh, create, return to the original state for gridView
  /// use ful because we canceled if instance exists
  final GridViewAnimationController? controller;

  /// default use [_dealDuration]
  final Duration defaultDuration;

  /// If it is [True], it will be similar to dealing with 52 cards
  final bool delayPerItem;

  /// Initial effect of the first element [createFadeAnimation]
  final bool initialFadeAnimation;

  /// Eeffect of the all element
  /// available when [delayPerItem] is [True]
  final bool fadeAnimation;

  @override
  State<GridViewAnimation> createState() => _GridViewAnimationState();
}

class _GridViewAnimationState extends State<GridViewAnimation> {
  // state
  final List<GridAnimationObject> _gridAnimationObjects = [];
  final List<GridAnimationObject> _gridAnimationDealObjects = [];
  Offset? rootOffset;

  // getter
  bool get delayPerItem => widget.delayPerItem;
  bool get initialFadeAnimation => widget.initialFadeAnimation;
  bool get fadeAnimation => widget.fadeAnimation;

  @override
  void initState() {
    // parse children to gridAnimationObject
    // Initialize key and type index
    widget.children.forEachIndexed((index, child) {
      _gridAnimationObjects.add(GridAnimationObject.init(
        index,
        child,
        widget.controller?.animationActionStream,
      ));
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GridView.builder(
            gridDelegate: widget.delegate,
            itemCount: _gridAnimationObjects.length,
            itemBuilder: (_, i) {
              return CardWidget(
                gridAnimationObject: _gridAnimationObjects.elementAt(i),
                create: _create,
                delayPerItem: delayPerItem,
                initialFadeAnimation: initialFadeAnimation,
              );
            },
          ),
        ),
        Positioned.fill(
          child: DealStack(
            gridAnimationDealObjects: _gridAnimationDealObjects,
            delayPerItem: delayPerItem,
            initialFadeAnimation: initialFadeAnimation,
            fadeAnimation: fadeAnimation,
          ),
        ),
      ],
    );
  }

  void _create(GridAnimationObject gridAnimationObject) {
    final globalKey = gridAnimationObject.globalKey;
    final index = gridAnimationObject.index;
    final myOffset = getLocalOffsetByKey(globalKey)!;
    final size = getSizeByKey(globalKey);
    rootOffset ??= index == 0 ? myOffset : null;
    _gridAnimationObjects[index].copyWith(
      rootOffset: rootOffset,
      myOffset: myOffset,
      size: size,
    );
    _gridAnimationDealObjects.add(_gridAnimationObjects[index]);
    setState(() {});
  }
}
