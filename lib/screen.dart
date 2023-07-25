import 'package:flutter_mjpeg/flutter_mjpeg.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

class Screen extends StatefulWidget {
  final bool _isScreenOn;
  const Screen(this._isScreenOn);
  @override
  _ScreenState createState() => _ScreenState();
}

class _ScreenState extends State<Screen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Neumorphic(
          style: const NeumorphicStyle(
              shape: NeumorphicShape.flat,
              depth: -3,
              surfaceIntensity: 10,
              shadowDarkColor: Colors.black,
              border: NeumorphicBorder(
                color: Color(0x33000000),
                width: 2,
              )),
          child: widget._isScreenOn
              ? const SizedBox(
                  height: 240,
                  width: 320,
                  child: Mjpeg(
                    isLive: true,
                    stream: "http://192.168.110.84/mjpeg/1",
                  ))
              : const SizedBox(
                  height: 240,
                  width: 320,
                  child: Mjpeg(
                    isLive: false,
                    stream: "http://192.168.110.84/mjpeg/1",
                  ))),
    );
  }
}
