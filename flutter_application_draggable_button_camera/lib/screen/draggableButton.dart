import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './OutlinedCircleButton.dart';

class Position {
  double _x, _y;
  Position(this._x, this._y);

  void setPosition(double x, double y) {
    this._x = x;
    this._y = y;
  }

  double get x {
    return this._x;
  }

  double get y {
    return this._y;
  }
}

class DraggableButtons extends StatefulWidget {
  final List<IconData> icon;
  final List<VoidCallback> onPressed;
  final VoidCallback onLongPressed;
  final double width;
  final double height;
  final double bottomheight;
  const DraggableButtons({
    required this.icon,
    required this.onPressed,
    required this.onLongPressed,
    required this.width,
    required this.height,
    required this.bottomheight,
  });

  @override
  _DraggableButtonsState createState() => _DraggableButtonsState();
}

class _DraggableButtonsState extends State<DraggableButtons> {
  List<Position> pos = [];
  //위젯 사이즈 camera앞뒤 - camera촬영모드 - camera해상도
  List<double> widgetSize = [50, 70, 50];
  List<double> positionX = [];
  List<double> positionY = [];

  void storeLocation(double xposition, double yposition, int idx) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble('positionX$idx', xposition);
    prefs.setDouble('positionY$idx', yposition);
  }

  void SetPosition() async {
    positionX = [
      (widget.width * 0.5 - ((widgetSize[1] * 0.5) + widgetSize[0] + 60)),
      (widget.width * 0.5 - (widgetSize[1] * 0.5)),
    ];
    positionY = [
      ((widget.height * (1 - (widget.bottomheight * 0.5))) -
          (widgetSize[0] * 0.5)),
      ((widget.height * (1 - (widget.bottomheight * 0.5))) -
          (widgetSize[1] * 0.5)),
    ];
    for (int i = 0; i < 3; i++) pos.add(Position(positionX[i], positionY[i]));
  }

  @override
  void initState() {
    // prefs = await SharedPreferences.getInstance();
    super.initState();
    // addPosition();
    // WidgetsBinding.instance.addPostFrameCallback(addPosition());
  }

  @override
  Widget build(BuildContext context) {
    SetPosition();
    return CustomMultiChildLayout(
      delegate: DragArea(pos),
      children: <Widget>[
        LayoutId(
          id: 't0',
          child: Draggable(
            feedback: OutlinedCircleButton(
              radius: widgetSize[0],
              foregroundColor: Colors.white,
              child: Icon(
                widget.icon[0],
                color: Colors.black,
              ),
              onTap: widget.onPressed[0],
            ),
            child: OutlinedCircleButton(
              radius: widgetSize[0],
              child: Icon(
                widget.icon[0],
                color: Colors.white,
              ),
              onTap: widget.onPressed[0],
            ),
            childWhenDragging: Container(),
            onDragEnd: (DraggableDetails d) {
              setState(() {
                pos[0].setPosition(d.offset.dx, d.offset.dy);
              });
              storeLocation(d.offset.dx, d.offset.dy, 0);
            },
          ),
        ),
        LayoutId(
          id: 't1',
          child: GestureDetector(
            onLongPress: widget.onLongPressed,
            child: Draggable(
              feedback: OutlinedCircleButton(
                borderSize: 0.0,
                borderColor: Colors.grey.withOpacity(0.8),
                foregroundColor: Colors.grey.withOpacity(0.8),
                radius: widgetSize[1],
                child: Icon(
                  widget.icon[1],
                  size: 60,
                  color: Colors.white,
                ),
                onTap: widget.onPressed[1],
              ),
              child: OutlinedCircleButton(
                radius: widgetSize[1],
                child: Icon(
                  widget.icon[1],
                  size: 60,
                  color: Colors.white,
                ),
                onTap: widget.onPressed[1],
              ),
              childWhenDragging: Container(),
              onDragEnd: (DraggableDetails d) {
                setState(() {
                  pos[1].setPosition(d.offset.dx, d.offset.dy);
                });
                storeLocation(d.offset.dx, d.offset.dy, 1);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class DragArea extends MultiChildLayoutDelegate {
  List<Position> _p = [];
  DragArea(this._p);

  @override
  void performLayout(Size size) {
    for (int i = 0; i < 2; i++) {
      layoutChild('t' + i.toString(), BoxConstraints.loose(size));
      positionChild('t' + i.toString(), Offset(_p[i].x, _p[i].y));
    }
  }

  @override
  bool shouldRelayout(MultiChildLayoutDelegate oldDelegate) {
    return false;
  }
}
