import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ima_player/ima_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routes: {
        "/": (context) => const AppHome(),
        "/player": (context) => const PlayerScreen(),
      },
    );
  }
}

class AppHome extends StatefulWidget {
  const AppHome({super.key});

  @override
  State<AppHome> createState() => _AppHomeState();
}

class _AppHomeState extends State<AppHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FilledButton(
          onPressed: () => Navigator.of(context).pushNamed('/player'),
          child: const Icon(Icons.play_arrow),
        ),
      ),
    );
  }
}

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});
  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  var position = ValueNotifier(Duration.zero);
  var events = <AdEventType>[];

  final controllerAsset = ImaPlayerController.asset(
    'assets/video.mp4',
    imaTag:
        'https://pubads.g.doubleclick.net/gampad/ads?iu=/21775744923/external/single_ad_samples&sz=640x480&cust_params=sample_ct%3Dlinear&ciu_szs=300x250%2C728x90&gdfp_req=1&output=vast&unviewed_position_start=1&env=vp&impl=s&correlator=',
    options: const ImaPlayerOptions(
      autoPlay: true,
      initialVolume: 1.0,
      isMixWithOtherMedia: true,
    ),
  );

  // final controllerNetwork = ImaPlayerController.network(
  //   'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
  //   // imaTag:
  //   //    'https://pubads.g.doubleclick.net/gampad/ads?iu=/21775744923/external/single_preroll_skippable&sz=640x480&ciu_szs=300x250%2C728x90&gdfp_req=1&output=vast&unviewed_position_start=1&env=vp&impl=s&correlator=',
  //   options: const ImaPlayerOptions(
  //     autoPlay: false,
  //     initialVolume: 1.0,
  //     isMixWithOtherMedia: true,
  //   ),
  // );

  @override
  void initState() {
    super.initState();

    controllerAsset.onPlayerReady.then((value) {
      print('#####');
      print('READY');
      print('#####');
    });

    controllerAsset.onAdLoaded.listen((event) {
      print('#####');
      print('event: $event');
      print('#####');
    });

    controllerAsset.onAdEvent.listen((event) {
      print('#####');
      print('event: $event');
      print('#####');

      events.add(event);
      setState(() {});
    });

    controllerAsset.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    Timer.periodic(const Duration(milliseconds: 200), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (!controllerAsset.value.isReady) {
        return;
      }

      position.value = await controllerAsset.position;
    });
  }

  @override
  void dispose() {
    controllerAsset.dispose();
    // controllerNetwork.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ImaPlayer(controllerAsset),
          ),
          // ImaPlayerUI(
          //   player: ImaPlayer(controllerNetwork),
          // ),
          ValueListenableBuilder(
            valueListenable: position,
            builder: (context, pos, child) {
              return Text(pos.toString());
            },
          ),
          Text(controllerAsset.value.bufferedDuration.toString()),
          FilledButton(
            onPressed: controllerAsset.play,
            child: Text('PLAY'),
          ),
          FilledButton(
            onPressed: controllerAsset.pause,
            child: Text('PAUSE'),
          ),
          FilledButton(
            onPressed: controllerAsset.stop,
            child: Text('STOP'),
          ),
          FilledButton(
            onPressed: () {
              controllerAsset.play(
                uri:
                    'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
              );
            },
            child: Text('PLAY ANOTHER VIDEO'),
          ),
          FilledButton(
            onPressed: () =>
                ImaPlayerController.pauseImaPlayers(controllerAsset),
            child: Text('PAUSE OTHER PLAYERS'),
          ),
          FilledButton(
            onPressed: controllerAsset.skipAd,
            child: Text('SKIP AD'),
          ),
          FilledButton(
            onPressed: () => controllerAsset.setVolume(0.2),
            child: Text('SET VOLUME (0.2)'),
          ),
          FilledButton(
            onPressed: () =>
                controllerAsset.seekTo(const Duration(seconds: 10)),
            child: Text('SEEK TO (10 SEC)'),
          ),
          const Divider(),
          Text(controllerAsset.value.toString()),
          const Divider(),
          StreamBuilder(
            stream: controllerAsset.onAdLoaded,
            builder: (context, snap) {
              if (!snap.hasData) {
                return Text('No ad data');
              }

              return Text(snap.requireData.toString());
            },
          ),
          const Divider(),
          Text(events.join('\n')),
          const SizedBox(height: 1000)
        ],
      ),
    );
  }
}
