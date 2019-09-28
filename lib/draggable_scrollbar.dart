import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Build the Scroll Thumb and label using the current configuration
typedef Widget ScrollThumbBuilder(Color backgroundColor,
    Animation<double> thumbAnimation,
    Animation<double> labelAnimation,
    double size, {
      Text labelText,
      BoxConstraints labelConstraints,
      @required Axis scrollDirection,
    });

/// Build a Text widget using the current scroll offset
typedef Text LabelTextBuilder(double positionOffset);

/// A widget that will display a BoxScrollView with a ScrollThumb that can be dragged
/// for quick navigation of the BoxScrollView.
class DraggableScrollbar extends StatefulWidget {
  /// The view that will be scrolled with the scroll thumb
  final BoxScrollView child;

  /// A function that builds a thumb using the current configuration
  final ScrollThumbBuilder scrollThumbBuilder;

  /// The height/length of the scroll thumb
  final double sizeScrollThumb;

  /// The background color of the label and thumb
  final Color backgroundColor;

  /// The amount of padding that should surround the thumb
  final EdgeInsetsGeometry padding;

  /// Determines how quickly the scrollbar will animate in and out
  final Duration scrollbarAnimationDuration;

  /// How long should the thumb be visible before fading out
  final Duration scrollbarTimeToFade;

  /// Build a Text widget from the current offset in the BoxScrollView
  final LabelTextBuilder labelTextBuilder;

  /// Determines box constraints for Container displaying label
  final BoxConstraints labelConstraints;

  /// The ScrollController for the BoxScrollView
  final ScrollController controller;

  /// Determines scrollThumb displaying. If you draw own ScrollThumb and it is true you just don't need to use animation parameters in [scrollThumbBuilder]
  final bool alwaysVisibleScrollThumb;

  DraggableScrollbar({
    Key key,
    this.alwaysVisibleScrollThumb = false,
    @required this.sizeScrollThumb,
    @required this.backgroundColor,
    @required this.scrollThumbBuilder,
    @required this.child,
    @required this.controller,
    this.padding,
    this.scrollbarAnimationDuration = const Duration(milliseconds: 300),
    this.scrollbarTimeToFade = const Duration(milliseconds: 600),
    this.labelTextBuilder,
    this.labelConstraints,
  })  : assert(controller != null),
        assert(scrollThumbBuilder != null),
        super(key: key);

  DraggableScrollbar.rrect({
    Key key,
    Key scrollThumbKey,
    this.alwaysVisibleScrollThumb = false,
    @required this.child,
    @required this.controller,
    this.sizeScrollThumb = 48.0,
    this.backgroundColor = Colors.white,
    this.padding,
    this.scrollbarAnimationDuration = const Duration(milliseconds: 300),
    this.scrollbarTimeToFade = const Duration(milliseconds: 600),
    this.labelTextBuilder,
    this.labelConstraints,
  })
      : scrollThumbBuilder =
  _thumbRRectBuilder(scrollThumbKey, alwaysVisibleScrollThumb),
        super(key: key);

  DraggableScrollbar.arrows({
    Key key,
    Key scrollThumbKey,
    this.alwaysVisibleScrollThumb = false,
    @required this.child,
    @required this.controller,
    this.sizeScrollThumb = 48.0,
    this.backgroundColor = Colors.white,
    this.padding,
    this.scrollbarAnimationDuration = const Duration(milliseconds: 300),
    this.scrollbarTimeToFade = const Duration(milliseconds: 600),
    this.labelTextBuilder,
    this.labelConstraints,
  })
      : scrollThumbBuilder =
  _thumbArrowBuilder(scrollThumbKey, alwaysVisibleScrollThumb),
        super(key: key);

  DraggableScrollbar.semicircle({
    Key key,
    Key scrollThumbKey,
    this.alwaysVisibleScrollThumb = false,
    @required this.child,
    @required this.controller,
    this.sizeScrollThumb = 48.0,
    this.backgroundColor = Colors.white,
    this.padding,
    this.scrollbarAnimationDuration = const Duration(milliseconds: 300),
    this.scrollbarTimeToFade = const Duration(milliseconds: 600),
    this.labelTextBuilder,
    this.labelConstraints,
  })
      : scrollThumbBuilder = _thumbSemicircleBuilder(
      sizeScrollThumb * 0.6, scrollThumbKey, alwaysVisibleScrollThumb),
        super(key: key);

  @override
  _DraggableScrollbarState createState() => _DraggableScrollbarState();

  static buildScrollThumbAndLabel({
    @required Widget scrollThumb,
    @required Color backgroundColor,
    @required Animation<double> thumbAnimation,
    @required Animation<double> labelAnimation,
    @required Text labelText,
    @required BoxConstraints labelConstraints,
    @required bool alwaysVisibleScrollThumb,
    @required bool isVertical,
  }) {
    var children = [
      ScrollLabel(
        animation: labelAnimation,
        child: labelText,
        backgroundColor: backgroundColor,
        constraints: labelConstraints,
      ),
      scrollThumb,
    ];
    var scrollThumbAndLabel = labelText == null
        ? scrollThumb
        : (isVertical
        ? Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: children,
    )
        : Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: children,
    ));

    if (alwaysVisibleScrollThumb) {
      return scrollThumbAndLabel;
    }
    return SlideFadeTransition(
      animation: thumbAnimation,
      child: scrollThumbAndLabel,
    );
  }

  static ScrollThumbBuilder _thumbSemicircleBuilder(
      double width, Key scrollThumbKey, bool alwaysVisibleScrollThumb) {
    return (Color backgroundColor,
        Animation<double> thumbAnimation,
        Animation<double> labelAnimation,
        double height, {
          Text labelText,
          BoxConstraints labelConstraints,
          Axis scrollDirection,
        }) {
      var isVerticalAxis = isVertical(scrollDirection);
      if (!isVerticalAxis) {
        width = width + height;
        height = width - height;
        width = width - height;
      }
      final scrollThumb = CustomPaint(
        key: scrollThumbKey,
        foregroundPainter: ArrowCustomPainter(Colors.grey),
        child: Material(
          elevation: 4.0,
          child: Container(
            constraints: BoxConstraints.tight(Size(width, height)),
          ),
          color: backgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(height),
            bottomLeft: Radius.circular(height),
            topRight: Radius.circular(4.0),
            bottomRight: Radius.circular(4.0),
          ),
        ),
      );

      return buildScrollThumbAndLabel(
        scrollThumb: scrollThumb,
        backgroundColor: backgroundColor,
        thumbAnimation: thumbAnimation,
        labelAnimation: labelAnimation,
        labelText: labelText,
        labelConstraints: labelConstraints,
        alwaysVisibleScrollThumb: alwaysVisibleScrollThumb,
        isVertical: isVerticalAxis,
      );
    };
  }

  static ScrollThumbBuilder _thumbArrowBuilder(
      Key scrollThumbKey, bool alwaysVisibleScrollThumb) {
    return (Color backgroundColor,
        Animation<double> thumbAnimation,
        Animation<double> labelAnimation,
        double size, {
          Text labelText,
          BoxConstraints labelConstraints,
          Axis scrollDirection,
        }) {
      var container = Container(
        height: size,
        width: 20.0,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.all(
            Radius.circular(12.0),
          ),
        ),
      );
      var isVerticalAxis = isVertical(scrollDirection);
      if (!isVerticalAxis) {
        container = Container(
          height: 20.0,
          width: size,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.all(
              Radius.circular(12.0),
            ),
          ),
        );
      }
      final scrollThumb = ClipPath(
        child: container,
        clipper: ArrowClipper(),
      );

      return buildScrollThumbAndLabel(
        scrollThumb: scrollThumb,
        backgroundColor: backgroundColor,
        thumbAnimation: thumbAnimation,
        labelAnimation: labelAnimation,
        labelText: labelText,
        labelConstraints: labelConstraints,
        alwaysVisibleScrollThumb: alwaysVisibleScrollThumb,
        isVertical: isVerticalAxis,
      );
    };
  }

  static ScrollThumbBuilder _thumbRRectBuilder(
      Key scrollThumbKey, bool alwaysVisibleScrollThumb) {
    return (Color backgroundColor,
        Animation<double> thumbAnimation,
        Animation<double> labelAnimation,
        double height, {
          Text labelText,
          BoxConstraints labelConstraints,
          Axis scrollDirection,
        }) {
      var width = 16.0;
      var isVerticalAxis = isVertical(scrollDirection);
      if (!isVerticalAxis) {
        width = width + height;
        height = width - height;
        width = width - height;
      }
      final scrollThumb = Material(
        elevation: 4.0,
        child: Container(
          constraints: BoxConstraints.tight(
            Size(width, height),
          ),
        ),
        color: backgroundColor,
        borderRadius: BorderRadius.all(Radius.circular(7.0)),
      );

      return buildScrollThumbAndLabel(
        scrollThumb: scrollThumb,
        backgroundColor: backgroundColor,
        thumbAnimation: thumbAnimation,
        labelAnimation: labelAnimation,
        labelText: labelText,
        labelConstraints: labelConstraints,
        alwaysVisibleScrollThumb: alwaysVisibleScrollThumb,
        isVertical: isVerticalAxis,
      );
    };
  }
}

class _DraggableScrollbarState extends State<DraggableScrollbar>
    with TickerProviderStateMixin {
  double _barOffset;
  double _viewOffset;
  bool _isDragInProcess;

  AnimationController _thumbAnimationController;
  Animation<double> _thumbAnimation;
  AnimationController _labelAnimationController;
  Animation<double> _labelAnimation;
  Timer _fadeoutTimer;

  @override
  void initState() {
    super.initState();
    _barOffset = 0.0;
    _viewOffset = 0.0;
    _isDragInProcess = false;

    _thumbAnimationController = AnimationController(
      vsync: this,
      duration: widget.scrollbarAnimationDuration,
    );

    _thumbAnimation = CurvedAnimation(
      parent: _thumbAnimationController,
      curve: Curves.fastOutSlowIn,
    );

    _labelAnimationController = AnimationController(
      vsync: this,
      duration: widget.scrollbarAnimationDuration,
    );

    _labelAnimation = CurvedAnimation(
      parent: _labelAnimationController,
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  void dispose() {
    _thumbAnimationController.dispose();
    _fadeoutTimer?.cancel();
    super.dispose();
  }

  /// Getter for scroll direction of the child
  Axis get scrollDirection => widget.child.scrollDirection;

  double get barMaxScrollExtent =>
      isVertical(scrollDirection)
          ? (context.size.height - widget.sizeScrollThumb)
          : (context.size.width - widget.sizeScrollThumb);

  double get barMinScrollExtent => 0.0;

  double get viewMaxScrollExtent => widget.controller.position.maxScrollExtent;

  double get viewMinScrollExtent => widget.controller.position.minScrollExtent;

  @override
  Widget build(BuildContext context) {
    Widget labelText;
    if (widget.labelTextBuilder != null && _isDragInProcess) {
      labelText = widget.labelTextBuilder(
        _viewOffset + _barOffset + widget.sizeScrollThumb / 2,
      );
    }

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          var thumbView = Container(
            alignment: Alignment.topRight,
            margin: EdgeInsets.only(top: _barOffset),
            padding: widget.padding,
            child: widget.scrollThumbBuilder(widget.backgroundColor,
                _thumbAnimation, _labelAnimation, widget.sizeScrollThumb,
                labelText: labelText,
                labelConstraints: widget.labelConstraints,
                scrollDirection: scrollDirection),
          );
          if (!isVertical(scrollDirection)) {
            thumbView = Container(
              alignment: Alignment.bottomLeft,
              margin: EdgeInsets.only(
                left: _barOffset,
              ),
              padding: widget.padding,
              child: widget.scrollThumbBuilder(widget.backgroundColor,
                  _thumbAnimation, _labelAnimation, widget.sizeScrollThumb,
                  labelText: labelText,
                  labelConstraints: widget.labelConstraints,
                  scrollDirection: scrollDirection),
            );
          }
          var detectorWidget = GestureDetector(
            onVerticalDragStart: _onVerticalDragStart,
            onVerticalDragUpdate: _onVerticalDragUpdate,
            onVerticalDragEnd: _onVerticalDragEnd,
            child: thumbView,
          );

          //if the scrollDirection is not vertical then listen for
          // horizontal drag events
          if (!isVertical(scrollDirection)) {
            detectorWidget = GestureDetector(
              onHorizontalDragStart: _onHorizontalDragStart,
              onHorizontalDragUpdate: _onHorizontalDragUpdate,
              onHorizontalDragEnd: _onHorizontalDragEnd,
              child: thumbView,
            );
          }

          Widget result = RepaintBoundary(
            child: detectorWidget,
          );

          return NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification notification) {
              changePosition(notification);
              return true;
            },
            child: Stack(
              children: <Widget>[
                RepaintBoundary(
                  child: widget.child,
                ),
                result,
              ],
            ),
          );
        });
  }

  //scroll bar has received notification that it's view was scrolled
  //so it should also changes his position
  //but only if it isn't dragged
  changePosition(ScrollNotification notification) {
    if (_isDragInProcess) {
      return;
    }

    setState(() {
      if (notification is ScrollUpdateNotification) {
        _barOffset += getBarDelta(
          notification.scrollDelta,
          barMaxScrollExtent,
          viewMaxScrollExtent,
        );

        if (_barOffset < barMinScrollExtent) {
          _barOffset = barMinScrollExtent;
        }
        if (_barOffset > barMaxScrollExtent) {
          _barOffset = barMaxScrollExtent;
        }

        _viewOffset += notification.scrollDelta;
        if (_viewOffset < widget.controller.position.minScrollExtent) {
          _viewOffset = widget.controller.position.minScrollExtent;
        }
        if (_viewOffset > viewMaxScrollExtent) {
          _viewOffset = viewMaxScrollExtent;
        }
      }

      if (notification is ScrollUpdateNotification ||
          notification is OverscrollNotification) {
        if (_thumbAnimationController.status != AnimationStatus.forward) {
          _thumbAnimationController.forward();
        }

        _fadeoutTimer?.cancel();
        _fadeoutTimer = Timer(widget.scrollbarTimeToFade, () {
          _thumbAnimationController.reverse();
          _labelAnimationController.reverse();
          _fadeoutTimer = null;
        });
      }
    });
  }

  double getBarDelta(double scrollViewDelta,
      double barMaxScrollExtent,
      double viewMaxScrollExtent,) {
    return scrollViewDelta * barMaxScrollExtent / viewMaxScrollExtent;
  }

  double getScrollViewDelta(double barDelta,
      double barMaxScrollExtent,
      double viewMaxScrollExtent,) {
    return barDelta * viewMaxScrollExtent / barMaxScrollExtent;
  }

  void _onVerticalDragStart(DragStartDetails details) {
    setState(() {
      _isDragInProcess = true;
      _labelAnimationController.forward();
      _fadeoutTimer?.cancel();
    });
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    setState(() {
      if (_thumbAnimationController.status != AnimationStatus.forward) {
        _thumbAnimationController.forward();
      }
      if (_isDragInProcess) {
        _barOffset += details.delta.dy;

        if (_barOffset < barMinScrollExtent) {
          _barOffset = barMinScrollExtent;
        }
        if (_barOffset > barMaxScrollExtent) {
          _barOffset = barMaxScrollExtent;
        }

        double viewDelta = getScrollViewDelta(
            details.delta.dy, barMaxScrollExtent, viewMaxScrollExtent);

        _viewOffset = widget.controller.position.pixels + viewDelta;
        if (_viewOffset < widget.controller.position.minScrollExtent) {
          _viewOffset = widget.controller.position.minScrollExtent;
        }
        if (_viewOffset > viewMaxScrollExtent) {
          _viewOffset = viewMaxScrollExtent;
        }
        widget.controller.jumpTo(_viewOffset);
      }
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    _fadeoutTimer = Timer(widget.scrollbarTimeToFade, () {
      _thumbAnimationController.reverse();
      _labelAnimationController.reverse();
      _fadeoutTimer = null;
    });
    setState(() {
      _isDragInProcess = false;
    });
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    setState(() {
      _isDragInProcess = true;
      _labelAnimationController.forward();
      _fadeoutTimer?.cancel();
    });
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      if (_thumbAnimationController.status != AnimationStatus.forward) {
        _thumbAnimationController.forward();
      }
      if (_isDragInProcess) {
        _barOffset += details.delta.dx;

        if (_barOffset < barMinScrollExtent) {
          _barOffset = barMinScrollExtent;
        }
        if (_barOffset > barMaxScrollExtent) {
          _barOffset = barMaxScrollExtent;
        }

        double viewDelta = getScrollViewDelta(
            details.delta.dx, barMaxScrollExtent, viewMaxScrollExtent);

        _viewOffset = widget.controller.position.pixels + viewDelta;
        if (_viewOffset < widget.controller.position.minScrollExtent) {
          _viewOffset = widget.controller.position.minScrollExtent;
        }
        if (_viewOffset > viewMaxScrollExtent) {
          _viewOffset = viewMaxScrollExtent;
        }
        widget.controller.jumpTo(_viewOffset);
      }
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    _fadeoutTimer = Timer(widget.scrollbarTimeToFade, () {
      _thumbAnimationController.reverse();
      _labelAnimationController.reverse();
      _fadeoutTimer = null;
    });
    setState(() {
      _isDragInProcess = false;
    });
  }
}

class ScrollLabel extends StatelessWidget {
  final Animation<double> animation;
  final Color backgroundColor;
  final Text child;

  final BoxConstraints constraints;
  static const width = 72.0;
  static const height = 28.0;

  static const BoxConstraints _defaultConstraints =
  BoxConstraints.tightFor(width: width, height: height);

  const ScrollLabel({
    Key key,
    @required this.child,
    @required this.animation,
    @required this.backgroundColor,
    this.constraints = _defaultConstraints,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var margin = EdgeInsets.all(8.0);

    return FadeTransition(
      opacity: animation,
      child: Container(
        margin: margin,
        child: Material(
          elevation: 4.0,
          color: backgroundColor,
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
          child: Container(
            constraints: constraints ?? _defaultConstraints,
            alignment: Alignment.center,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Draws 2 triangles like arrow up and arrow down
class ArrowCustomPainter extends CustomPainter {
  Color color;

  ArrowCustomPainter(this.color);

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const width = 12.0;
    const height = 8.0;
    final baseX = size.width / 2;
    final baseY = size.height / 2;

    canvas.drawPath(
      _trianglePath(Offset(baseX, baseY - 2.0), width, height, true),
      paint,
    );
    canvas.drawPath(
      _trianglePath(Offset(baseX, baseY + 2.0), width, height, false),
      paint,
    );
  }

  static Path _trianglePath(Offset o, double width, double height, bool isUp) {
    return Path()
      ..moveTo(o.dx, o.dy)
      ..lineTo(o.dx + width, o.dy)
      ..lineTo(o.dx + (width / 2), isUp ? o.dy - height : o.dy + height)
      ..close();
  }
}

///This cut 2 lines in arrow shape
class ArrowClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0.0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0.0);
    path.lineTo(0.0, 0.0);
    path.close();

    double arrowWidth = 8.0;
    double startPointX = (size.width - arrowWidth) / 2;
    double startPointY = size.height / 2 - arrowWidth / 2;
    path.moveTo(startPointX, startPointY);
    path.lineTo(startPointX + arrowWidth / 2, startPointY - arrowWidth / 2);
    path.lineTo(startPointX + arrowWidth, startPointY);
    path.lineTo(startPointX + arrowWidth, startPointY + 1.0);
    path.lineTo(
        startPointX + arrowWidth / 2, startPointY - arrowWidth / 2 + 1.0);
    path.lineTo(startPointX, startPointY + 1.0);
    path.close();

    startPointY = size.height / 2 + arrowWidth / 2;
    path.moveTo(startPointX + arrowWidth, startPointY);
    path.lineTo(startPointX + arrowWidth / 2, startPointY + arrowWidth / 2);
    path.lineTo(startPointX, startPointY);
    path.lineTo(startPointX, startPointY - 1.0);
    path.lineTo(
        startPointX + arrowWidth / 2, startPointY + arrowWidth / 2 - 1.0);
    path.lineTo(startPointX + arrowWidth, startPointY - 1.0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class SlideFadeTransition extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const SlideFadeTransition({
    Key key,
    @required this.animation,
    @required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => animation.value == 0.0 ? Container() : child,
      child: SlideTransition(
        position: Tween(
          begin: Offset(0.3, 0.0),
          end: Offset(0.0, 0.0),
        ).animate(animation),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      ),
    );
  }
}

/// Check if the provided scroll direction is
/// equals to [Axis.vertical] or not
bool isVertical(Axis axisType) {
  return axisType == Axis.vertical;
}
