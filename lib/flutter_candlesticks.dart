import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class OHLCVGraph extends StatefulWidget {
  OHLCVGraph({
    Key? key,
    required this.data,
    this.lineWidth = 1.0,
    this.fallbackHeight = 100.0,
    this.fallbackWidth = 300.0,
    this.gridLineColor = Colors.grey,
    this.gridLineAmount = 5,
    this.gridLineWidth = 0.5,
    this.gridLineLabelColor = Colors.grey,
    this.labelPrefix = "\$",
    required this.enableGridLines,
    required this.volumeProp,
    this.increaseColor = Colors.green,
    this.decreaseColor = Colors.red,
  }) : super(key: key);

  /// OHLCV data to graph  /// List of Maps containing open, high, low, close and volumeto
  /// Example: [["open" : 40.0, "high" : 75.0, "low" : 25.0, "close" : 50.0, "volumeto" : 5000.0}, {...}]
  final List data;

  /// All lines in chart are drawn with this width
  final double lineWidth;

  /// Enable or disable grid lines
  final bool enableGridLines;

  /// Color of grid lines and label text
  final Color gridLineColor;
  final Color gridLineLabelColor;

  /// Number of grid lines
  final int gridLineAmount;

  /// Width of grid lines
  final double gridLineWidth;

  /// Proportion of paint to be given to volume bar graph
  final double volumeProp;

  /// If graph is given unbounded space,
  /// it will default to given fallback height and width
  final double fallbackHeight;
  final double fallbackWidth;

  /// Symbol prefix for grid line labels
  final String labelPrefix;

  /// Increase color
  final Color increaseColor;

  /// Decrease color
  final Color decreaseColor;

  @override
  State<OHLCVGraph> createState() => _OHLCVGraph();
}

class _OHLCVGraph extends State<OHLCVGraph> {
  Offset? _currentPosition;

  @override
  Widget build(BuildContext context) {
    return LimitedBox(
        maxHeight: widget.fallbackHeight,
        maxWidth: widget.fallbackWidth,
        child: MouseRegion(
          onHover: (PointerHoverEvent event) {
            setState(() {
              _currentPosition = event.localPosition;
            });
          },
          onExit: (PointerExitEvent event) {
            setState(() {
              _currentPosition =
                  null; // Clear position when the mouse leaves the widget
            });
          },
          child: CustomPaint(
            size: Size.infinite,
            painter: _OHLCVPainter(
                currentPosition: _currentPosition,
                data: widget.data,
                lineWidth: widget.lineWidth,
                gridLineColor: widget.gridLineColor,
                gridLineAmount: widget.gridLineAmount,
                gridLineWidth: widget.gridLineWidth,
                gridLineLabelColor: widget.gridLineLabelColor,
                enableGridLines: widget.enableGridLines,
                volumeProp: widget.volumeProp,
                labelPrefix: widget.labelPrefix,
                increaseColor: widget.increaseColor,
                decreaseColor: widget.decreaseColor),
          ),
        ));
  }
}

class _OHLCVPainter extends CustomPainter {
  _OHLCVPainter(
      {required this.currentPosition,
      required this.data,
      required this.lineWidth,
      required this.enableGridLines,
      required this.gridLineColor,
      required this.gridLineAmount,
      required this.gridLineWidth,
      required this.gridLineLabelColor,
      required this.volumeProp,
      required this.labelPrefix,
      required this.increaseColor,
      required this.decreaseColor});

  final Offset? currentPosition;
  final List data;
  final double lineWidth;
  final bool enableGridLines;
  final Color gridLineColor;
  final int gridLineAmount;
  final double gridLineWidth;
  final Color gridLineLabelColor;
  final String labelPrefix;
  final double volumeProp;
  final Color increaseColor;
  final Color decreaseColor;

  double? _min;
  double? _max;
  double? _maxVolume;

  List<TextPainter> gridLineTextPainters = [];
  late TextPainter maxVolumePainter;

  numCommaParse(number) {
    return number.round().toString().replaceAllMapped(
        new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]},");
  }

  update() {
    _min = double.infinity;
    _max = -double.infinity;
    _maxVolume = -double.infinity;
    for (var i in data) {
      if (i["high"] > _max) {
        _max = i["high"].toDouble();
      }
      if (i["low"] < _min) {
        _min = i["low"].toDouble();
      }
      if (i["volumeto"] > _maxVolume) {
        _maxVolume = i["volumeto"].toDouble();
      }
    }

    if (enableGridLines) {
      double gridLineValue;
      for (int i = 0; i < gridLineAmount; i++) {
        // Label grid lines
        gridLineValue = _max! - (((_max! - _min!) / (gridLineAmount - 1)) * i);

        String gridLineText;
        if (gridLineValue < 1) {
          gridLineText = gridLineValue.toStringAsPrecision(4);
        } else if (gridLineValue < 999) {
          gridLineText = gridLineValue.toStringAsFixed(2);
        } else {
          gridLineText = gridLineValue.round().toString().replaceAllMapped(
              new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => "${m[1]},");
        }

        gridLineTextPainters.add(new TextPainter(
            text: new TextSpan(
                text: labelPrefix + gridLineText,
                style: new TextStyle(
                    color: gridLineLabelColor,
                    fontSize: 10.0,
                    fontWeight: FontWeight.bold)),
            textDirection: TextDirection.ltr));
        gridLineTextPainters[i].layout();
      }

      // Label volume line
      maxVolumePainter = new TextPainter(
          text: new TextSpan(
              text: labelPrefix + numCommaParse(_maxVolume),
              style: new TextStyle(
                  color: gridLineLabelColor,
                  fontSize: 10.0,
                  fontWeight: FontWeight.bold)),
          textDirection: TextDirection.ltr);
      maxVolumePainter.layout();
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (_min == null || _max == null || _maxVolume == null) {
      update();
    }

    final double volumeHeight = size.height * volumeProp;
    final double volumeNormalizer = volumeHeight / _maxVolume!;

    double width = size.width;
    final double height = size.height * (1 - volumeProp);

    if (enableGridLines) {
      InlineSpan inlineSpan = gridLineTextPainters[0].text!;
      width = size.width - inlineSpan.toPlainText().length * 6;
      Paint gridPaint = new Paint()
        ..color = gridLineColor
        ..strokeWidth = gridLineWidth;

      double gridLineDist = height / (gridLineAmount - 1);
      late double gridLineY;

      // Draw grid lines
      for (int i = 0; i < gridLineAmount; i++) {
        gridLineY = (gridLineDist * i).round().toDouble();
        canvas.drawLine(new Offset(0.0, gridLineY),
            new Offset(width, gridLineY), gridPaint);

        // Label grid lines
        gridLineTextPainters[i]
            .paint(canvas, new Offset(width + 2.0, gridLineY - 6.0));
      }

      // Label volume line
      maxVolumePainter.paint(canvas, new Offset(0.0, gridLineY + 2.0));
    }

    final double heightNormalizer = height / (_max! - _min!);
    final double rectWidth = width / data.length;

    double rectLeft;
    double rectTop;
    double rectRight;
    double rectBottom;

    Paint rectPaint;

    // Loop through all data
    for (int i = 0; i < data.length; i++) {
      rectLeft = (i * rectWidth) + lineWidth / 2;
      rectRight = ((i + 1) * rectWidth) - lineWidth / 2;
      data[i]["rectLeft"] = rectLeft;
      data[i]["rectRight"] = rectRight;

      double volumeBarTop = (height + volumeHeight) -
          (data[i]["volumeto"] * volumeNormalizer - lineWidth / 2);
      double volumeBarBottom = height + volumeHeight + lineWidth / 2;

      if (data[i]["open"] > data[i]["close"]) {
        // Draw candlestick if decrease
        rectTop = height - (data[i]["open"] - _min) * heightNormalizer;
        rectBottom = height - (data[i]["close"] - _min) * heightNormalizer;
        rectPaint = new Paint()
          ..color = decreaseColor
          ..strokeWidth = lineWidth;
        drawCandleLineAndVolume(rectLeft, rectTop, rectRight, rectBottom,
            canvas, rectPaint, volumeBarTop, volumeBarBottom);
      } else {
        // Draw candlestick if increase
        rectTop = (height - (data[i]["close"] - _min) * heightNormalizer) +
            lineWidth / 2;
        rectBottom = (height - (data[i]["open"] - _min) * heightNormalizer) -
            lineWidth / 2;
        rectPaint = new Paint()
          ..color = increaseColor
          ..strokeWidth = lineWidth;
        drawCandleLineAndVolume(rectLeft, rectTop, rectRight, rectBottom,
            canvas, rectPaint, volumeBarTop, volumeBarBottom);
      }

      // Draw low/high candlestick wicks
      double low = height - (data[i]["low"] - _min) * heightNormalizer;
      double high = height - (data[i]["high"] - _min) * heightNormalizer;
      canvas.drawLine(
          new Offset(rectLeft + rectWidth / 2 - lineWidth / 2, rectBottom),
          new Offset(rectLeft + rectWidth / 2 - lineWidth / 2, low),
          rectPaint);
      canvas.drawLine(
          new Offset(rectLeft + rectWidth / 2 - lineWidth / 2, rectTop),
          new Offset(rectLeft + rectWidth / 2 - lineWidth / 2, high),
          rectPaint);
    }

    if (currentPosition != null) {
      final Paint linePaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;

      // Draw vertical line
      canvas.drawLine(
        Offset(currentPosition!.dx, 0),
        Offset(currentPosition!.dx, size.height),
        linePaint,
      );

      // Draw horizontal line
      canvas.drawLine(
        Offset(0, currentPosition!.dy),
        Offset(size.width, currentPosition!.dy),
        linePaint,
      );

      // Draw a white rectangle at the mouse position
      final Paint rectPaint = Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.fill;

      var item = 0;
      for (int i = 0; i < data.length; i++) {
        if (currentPosition!.dx > data[i]["rectLeft"] &&
            currentPosition!.dx < data[i]["rectRight"]) {
          item = i;
          break;
        }
      }

      final double rectWidth = 220.0;
      final double rectHeight = 200.0;

      Rect rect = Rect.fromLTWH(
          currentPosition!.dx + 2, // Left
          currentPosition!.dy + 2, // Top
          rectWidth, // Width
          rectHeight // Height
          );
      canvas.drawRect(rect, rectPaint);

      var open = data[item]["open"];
      var close = data[item]["close"];
      var high = data[item]["high"];
      var low = data[item]["low"];
      var volumeto = data[item]["volumeto"];
      var offset = null;
      offset = drawText("open: $open", null, rectWidth, canvas);
      offset = drawText("close: $close", offset, rectWidth, canvas);
      offset = drawText("high: $high", offset, rectWidth, canvas);
      offset = drawText("high: $close", offset, rectWidth, canvas);
      offset = drawText("low: $low", offset, rectWidth, canvas);
      offset = drawText("volume: $volumeto", offset, rectWidth, canvas);
    }
  }

  Offset drawText(text, Offset? initOffset, double rectWidth, Canvas canvas) {
    final double positionOffsetDx = 20;
    final double positionOffsetDy = 10;

    // Drawing text inside the rectangle
    final textStyle = TextStyle(color: Colors.white, fontSize: 14);
    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(minWidth: 0, maxWidth: rectWidth);

    var offset = null;
    if (initOffset == null) {
      offset = Offset(currentPosition!.dx + positionOffsetDx,
          currentPosition!.dy + positionOffsetDy);
    } else {
      offset = Offset(currentPosition!.dx + positionOffsetDx,
          initOffset.dy + textPainter.height + positionOffsetDy);
    }
    textPainter.paint(canvas, offset);
    return offset;
  }

  void drawCandleLineAndVolume(
      double rectLeft,
      double rectTop,
      double rectRight,
      double rectBottom,
      Canvas canvas,
      Paint rectPaint,
      double volumeBarTop,
      double volumeBarBottom) {
    Rect ocRect = new Rect.fromLTRB(rectLeft, rectTop, rectRight, rectBottom);
    canvas.drawRect(ocRect, rectPaint);

    // Draw volume bars
    Rect volumeRect =
        new Rect.fromLTRB(rectLeft, volumeBarTop, rectRight, volumeBarBottom);
    canvas.drawRect(volumeRect, rectPaint);
  }

  @override
  bool shouldRepaint(_OHLCVPainter old) {
    return old.currentPosition != currentPosition ||
        data != old.data ||
        lineWidth != old.lineWidth ||
        enableGridLines != old.enableGridLines ||
        gridLineColor != old.gridLineColor ||
        gridLineAmount != old.gridLineAmount ||
        gridLineWidth != old.gridLineWidth ||
        volumeProp != old.volumeProp ||
        gridLineLabelColor != old.gridLineLabelColor;
  }
}
