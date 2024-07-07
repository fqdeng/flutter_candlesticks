import 'package:flutter/material.dart';
import 'package:flutter_candlesticks/flutter_candlesticks.dart';

void main() {
  List sampleData = [
    {'open': 124.05, 'high': 125.59, 'low': 118.32, 'close': 121.0, 'volumeto': 664696000.0},
    {'open': 119.77, 'high': 121.69, 'low': 118.02, 'close': 120.89, 'volumeto': 412386000.0},
    {'open': 120.37, 'high': 123.1, 'low': 117.01, 'close': 121.79, 'volumeto': 314162700.0},
    {'open': 121.77, 'high': 122.87, 'low': 118.74, 'close': 120.91, 'volumeto': 222551200.0},
    {'open': 123.06, 'high': 126.88, 'low': 122.57, 'close': 125.2, 'volumeto': 299595000.0},
    {'open': 129.39, 'high': 129.8, 'low': 127.16, 'close': 129.61, 'volumeto': 260704500.0},
    {'open': 129.96, 'high': 132.84, 'low': 128.32, 'close': 131.88, 'volumeto': 309320400.0},
    {'open': 132.99, 'high': 133.73, 'low': 129.58, 'close': 130.98, 'volumeto': 288504400.0},
    {'open': 131.14, 'high': 136.33, 'low': 130.69, 'close': 135.58, 'volumeto': 294335100.0},
    {'open': 139.8, 'high': 140.76, 'low': 129.52, 'close': 130.78, 'volumeto': 517768400.0},
    {'open': 127.12, 'high': 130.63, 'low': 124.3, 'close': 126.57, 'volumeto': 655484700.0},
    {'open': 123.24, 'high': 124.46, 'low': 118.04, 'close': 118.11, 'volumeto': 476060900.0},
    {'open': 121.2, 'high': 126.5, 'low': 119.32, 'close': 126.09, 'volumeto': 425787500.0},
    {'open': 126.13, 'high': 128.12, 'low': 122.6, 'close': 126.4, 'volumeto': 362975900.0},
    {'open': 124.1, 'high': 126.41, 'low': 122.92, 'close': 123.99, 'volumeto': 252571700.0},
    {'open': 124.58, 'high': 127.71, 'low': 122.75, 'close': 123.54, 'volumeto': 315516700.0},
    {'open': 123.47, 'high': 124.84, 'low': 118.83, 'close': 124.3, 'volumeto': 284885500.0},
    {'open': 121.13, 'high': 123.41, 'low': 121.03, 'close': 122.67, 'volumeto': 218374000.0},
    {'open': 121.66, 'high': 128.28, 'low': 121.36, 'close': 128.28, 'volumeto': 215749000.0},
    {'open': 127.38, 'high': 128.85, 'low': 125.68, 'close': 125.83, 'volumeto': 213201200.0},

  ];

  runApp(
    new MaterialApp(
      home: new Scaffold(
        backgroundColor: Colors.black,
        body: new Center(
          child: new Container(
            height: 500.0,
            child: new OHLCVGraph(
                data: sampleData,
                enableGridLines: true,
                volumeProp: 0.2
            ),
          ),
        ),
      )
    )
  );
}