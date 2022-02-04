import 'dart:async';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as rtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as rtcRemoteView;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String appId = "bacf3563e31a40d8ac493f7cab4957ec";

  String token =
      "006bacf3563e31a40d8ac493f7cab4957ecIACCyHaGI8Oo7tfd6wiDobQp9Gg5OdbD8Sqp8Xbwxku1EKMlb/oAAAAAEABJ0h4Oyyb+YQEAAQDLJv5h";
  String channelName = "Event";

  List<int> remoteIdList = [];
  int? presenterId;

  bool audioEnabled = false;
  bool videoEnabled = false;

  late RtcEngine _engine;
  @override
  void initState() {
    initAgora();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Agora Test"),
        actions: [
          IconButton(
            onPressed: () async {
              audioEnabled = !audioEnabled;
              await _engine.enableLocalAudio(audioEnabled);
              setState(() {});
            },
            icon: Icon(audioEnabled ? Icons.mic : Icons.mic_off),
          ),
          IconButton(
            onPressed: () async {
              videoEnabled = !videoEnabled;
              await _engine.enableLocalVideo(videoEnabled);
              setState(() {});
            },
            icon: Icon(videoEnabled ? Icons.videocam : Icons.videocam_off),
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: _bigVideo(),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              children: remoteIdList.map((id) {
                return GestureDetector(
                  onTap: () {
                    if (presenterId != null) {
                      remoteIdList.add(presenterId!);
                    }
                    remoteIdList.remove(id);
                    presenterId = id;
                    setState(() {});
                  },
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: _getVideo(id),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bigVideo() {
    if (presenterId != null) {
      return _getVideo(presenterId!);
    } else {
      return const Text(
        'Click on any camera to make it big.',
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
    //await _engine.enableAudio();
    await _engine.enableVideo();

    await _engine.enableLocalVideo(false);
    await _engine.enableLocalAudio(false);
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
        userMuteAudio: (int uid, bool isMuted) {
          print("remote user $uid audio mute status : $isMuted");
          setState(() {});
        },
        userMuteVideo: (int uid, bool isMuted) {
          print("remote user $uid video mute status : $isMuted");
          setState(() {});
        },
      ),
    );

    await _engine.joinChannel(token, channelName, null, 0);
  }
}
