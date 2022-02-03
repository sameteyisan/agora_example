import 'dart:async';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as rtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as rtcRemoteView;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String appId = "bacf3563e31a40d8ac493f7cab4957ec";

  String token =
      "006bacf3563e31a40d8ac493f7cab4957ecIADgCqLZ7giMjxzz6BotrOCJy4x9knZFznrtwMXchgrjNNLwFaoAAAAAEABJ0h4OFTL9YQEAAQAVMv1h";

  List<int> remoteIdList = [];
  int? presenterIdx;

  late RtcEngine _engine;
  @override
  void initState() {
    initAgora();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Agora Test")),
      body: Stack(
        children: [
          Center(
            child: _bigVideo(),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              children: remoteIdList.map((id) {
                return SizedBox(
                  width: 100,
                  height: 100,
                  child: _getVideo(id),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bigVideo() {
    if (presenterIdx != null) {
      return _getVideo(remoteIdList[presenterIdx!]);
    } else {
      return const Text(
        'Please wait for the presenter.',
        textAlign: TextAlign.center,
      );
    }
  }

  Widget _getVideo(int uid) {
    if (uid == -1) return rtcLocalView.SurfaceView();
    return rtcRemoteView.SurfaceView(
      uid: uid,
    );
  }

  Future<void> initAgora() async {
    await [Permission.microphone, Permission.camera].request();

    _engine = await RtcEngine.create(appId);
    await _engine.enableVideo();
    _engine.setEventHandler(
      RtcEngineEventHandler(
        joinChannelSuccess: (String channel, int uid, int elapsed) {
          print(">>> local user $uid joined");
          setState(() {
            remoteIdList.add(-1);
          });
        },
        userJoined: (int uid, int elapsed) {
          print("remote user $uid joined");
          setState(() {
            remoteIdList.add(uid);
          });
        },
        userOffline: (int uid, UserOfflineReason reason) {
          print("remote user $uid left channel");
          setState(() {
            remoteIdList.remove(uid);
          });
        },
      ),
    );

    await _engine.joinChannel(token, "OneOnOne", null, 0);
  }
}
