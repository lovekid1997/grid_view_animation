import 'dart:async';

import 'enum.dart';

class GridViewAnimationController {
  late final StreamController<GridViewAnimationAction> animationActionStream;
  GridViewAnimationController()
      : animationActionStream =
            StreamController<GridViewAnimationAction>.broadcast();

  void refresh() {
    animationActionStream.sink.add(GridViewAnimationAction.refresh);
  }

  void deal() {
    animationActionStream.sink.add(GridViewAnimationAction.deal);
  }

  void cancel() {
    animationActionStream.sink.add(GridViewAnimationAction.cancel);
  }

  dispose() {
    animationActionStream.close();
  }
}
