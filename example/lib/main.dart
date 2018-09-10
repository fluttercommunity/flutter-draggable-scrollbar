import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(DraggableScrollBarDemo(
    title: 'Draggable Scroll Bar Demo',
  ));
}

class DraggableScrollBarDemo extends StatelessWidget {
  final String title;

  const DraggableScrollBarDemo({
    Key key,
    @required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      home: MyHomePage(title: title),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ScrollController _semicircleController = ScrollController();
  ScrollController _arrowsController = ScrollController();
  ScrollController _rrectController = ScrollController();
  ScrollController _customController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          bottom: TabBar(tabs: [
            Tab(text: 'Semicircle'),
            Tab(text: 'Arrows'),
            Tab(text: 'RRect'),
            Tab(text: 'Custom'),
          ]),
        ),
        body: TabBarView(children: [
          SemicircleDemo(controller: _semicircleController),
          ArrowsDemo(controller: _arrowsController),
          RRectDemo(controller: _rrectController),
          CustomDemo(controller: _customController),
        ]),
      ),
    );
  }
}

class SemicircleDemo extends StatelessWidget {
  static int numItems = 1000;

  final ScrollController controller;

  const SemicircleDemo({
    Key key,
    @required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollbar.semicircle(
      labelTextBuilder: (offset) {
        final int currentItem = controller.hasClients
            ? (controller.offset /
                    controller.position.maxScrollExtent *
                    numItems)
                .floor()
            : 0;

        return Text("$currentItem");
      },
      labelConstraints: BoxConstraints.tightFor(width: 80.0, height: 30.0),
      controller: controller,
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
        ),
        controller: controller,
        padding: EdgeInsets.zero,
        itemCount: numItems,
        itemBuilder: (context, index) {
          return Container(
            alignment: Alignment.center,
            margin: EdgeInsets.all(2.0),
            color: Colors.grey[300],
          );
        },
      ),
    );
  }
}

class ArrowsDemo extends StatelessWidget {
  final ScrollController controller;

  const ArrowsDemo({Key key, @required this.controller}) : super(key: key);

  final _itemExtent = 100.0;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollbar.arrows(
      alwaysVisibleScrollThumb: true,
      backgroundColor: Colors.grey[850],
      padding: EdgeInsets.only(right: 4.0),
      labelTextBuilder: (double offset) => Text("${offset ~/ _itemExtent}",
          style: TextStyle(color: Colors.white)),
      controller: controller,
      child: ListView.builder(
        controller: controller,
        itemCount: 1000,
        itemExtent: _itemExtent,
        itemBuilder: (context, index) {
          return Container(
            padding: EdgeInsets.all(8.0),
            child: Material(
              elevation: 4.0,
              borderRadius: BorderRadius.circular(4.0),
              color: Colors.purple[index % 9 * 100],
              child: Center(
                child: Text(
                  index.toString(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class RRectDemo extends StatelessWidget {
  final ScrollController controller;

  const RRectDemo({Key key, @required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollbar.rrect(
      controller: controller,
      labelTextBuilder: (offset) => Text("${offset.floor()}"),
      child: ListView.builder(
        controller: controller,
        itemCount: 1000,
        itemExtent: 100.0,
        itemBuilder: (context, index) {
          return Container(
            padding: EdgeInsets.all(8.0),
            child: Material(
              elevation: 4.0,
              borderRadius: BorderRadius.circular(4.0),
              color: Colors.green[index % 9 * 100],
              child: Center(
                child: Text(index.toString()),
              ),
            ),
          );
        },
      ),
    );
  }
}

class CustomDemo extends StatelessWidget {
  final ScrollController controller;

  const CustomDemo({Key key, @required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollbar(
      controller: controller,
      child: ListView.builder(
        controller: controller,
        itemCount: 1000,
        itemExtent: 100.0,
        itemBuilder: (context, index) {
          return Container(
            padding: EdgeInsets.all(8.0),
            child: Material(
              elevation: 4.0,
              borderRadius: BorderRadius.circular(4.0),
              color: Colors.cyan[index % 9 * 100],
              child: Center(
                child: Text(index.toString()),
              ),
            ),
          );
        },
      ),
      heightScrollThumb: 48.0,
      backgroundColor: Colors.blue,
      scrollThumbBuilder: (
        Color backgroundColor,
        Animation<double> thumbAnimation,
        Animation<double> labelAnimation,
        double height, {
        Text labelText,
        BoxConstraints labelConstraints,
      }) {
        return FadeTransition(
          opacity: thumbAnimation,
          child: Container(
            height: height,
            width: 20.0,
            color: backgroundColor,
          ),
        );
      },
    );
  }
}
