import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:free_name/bloc/getConfig/config_bloc.dart';
import 'package:free_name/bloc/getConfig/config_event.dart';
//import 'package:share_plus/share_plus.dart';
import 'package:web_scraper/web_scraper.dart';
import 'package:flutter_v2ray/flutter_v2ray.dart';
import '../bloc/getConfig/config_state.dart';
import 'package:http/http.dart' as http;

class MyMain extends StatefulWidget {
  const MyMain({super.key});

  @override
  State<MyMain> createState() => _MyMainState();
}

class _MyMainState extends State<MyMain> {
  late final FlutterV2ray flutterV2ray = FlutterV2ray(
    onStatusChanged: (status) {
      v2rayStatus.value = status;
      if (v2rayStatus.value.state == 'CONNECTED') {
        showButtonSheet = true;
      }
    },
  );

  ScrollController _scrollController = ScrollController();
  var v2rayStatus = ValueNotifier<V2RayStatus>(V2RayStatus());

  final webScraper = WebScraper('https://raw.githubusercontent.com');
  List<String> vmessLinks = [];
  List<String> vlessLinks = [];
  List<String> trojanLinks = [];
  List<int> vmessDelays = [];
  List<int> vlessDelays = [];
  List<int> trojanDelays = [];
  int? total;
  bool showDelays = true;
  bool showButtonSheet = false;
  int? selectedIndex;
  // Method to reset the state and clear delay lists

  void initState() {
    // TODO: implement initState
    // fetchProducts();
    BlocProvider.of<ConfigBloc>(context).add(GetConfigStartEvent());
    flutterV2ray.initializeV2Ray().then((value) async {
      //coreVersion = await flutterV2ray.getCoreVersion();
      setState(() {});
    });

    super.initState();
  }

  void connectToV2RayWithConfig(String link, int index) async {
    // Prepare the V2Ray configuration using the selected link
    final V2RayURL v2rayURL = FlutterV2ray.parseFromURL(link);

    // Connect to V2Ray
    if (await flutterV2ray.requestPermission()) {
      flutterV2ray.startV2Ray(
        remark: v2rayURL.remark,
        config: v2rayURL.getFullConfiguration(),
        proxyOnly: false,
        bypassSubnets: [],
      );
      setState(() {
        selectedIndex = index;
        // Update the selected index
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permission Denied'),
        ),
      );
    }
  }

  Future<int> getServerDelay(String serverUrl) async {
    try {
      var startTime = DateTime.now();
      var response = await http.get(Uri.parse(serverUrl));
      // var response = ;
      var endTime = DateTime.now();
      var delay = endTime.difference(startTime).inMilliseconds;
      return delay;
    } catch (e) {
      print('Error getting server delay: $e');
      return -1; // Return a negative value to indicate an error
    }
  }

  Future<int> fetchDelay(String link) async {
    final V2RayURL v2rayURL = FlutterV2ray.parseFromURL(link);

    final delay = flutterV2ray.getServerDelay(
        config: v2rayURL.getFullConfiguration(indent: 2));
    return delay;
  }

  Widget buildDelayWidget(String link, int index) {
    final V2RayURL v2rayURL = FlutterV2ray.parseFromURL(link);
    return FutureBuilder<int>(
      future: fetchDelay(link),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListTile(
            trailing: IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: v2rayURL.url));

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      showCloseIcon: true,
                      content: Text('Copied to clipboard'),
                    ),
                  );
                },
                icon: const Icon(Icons.copy)),
            title: Text(v2rayURL.remark),
            subtitle: const Text('Fetching delay...'),
          );
        } else if (snapshot.hasData) {
          return ListTile(
            trailing: IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: v2rayURL.url));

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      showCloseIcon: true,
                      content: Text('Copied to clipboard'),
                    ),
                  );
                },
                icon: const Icon(Icons.copy)),
            title: Text(v2rayURL.remark),
            subtitle: Text('Delay: ${snapshot.data}ms'),
            leading: snapshot.data == -1
                ? Icon(
                    Icons.cancel,
                    color: selectedIndex == index ? Colors.green : null,
                  )
                : Icon(
                    Icons.check,
                    color: selectedIndex == index
                        ? Colors.green
                        : null, // Change color if selected
                  ),
            onTap: () {
              connectToV2RayWithConfig(link, index);
            },
          );
        } else if (snapshot.hasError) {
          return ListTile(
            title: Text(v2rayURL.remark),
            subtitle: const Text('Error fetching delay.'),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      persistentFooterAlignment: AlignmentDirectional.topCenter,
      appBar: AppBar(
        elevation: 1.2,
        centerTitle: true,
        title: const Text(
          'Free Net',
        ),
      ),
      body: BlocBuilder<ConfigBloc, GetConfigState>(
        builder: (context, state) {
          return ListView(
            controller: _scrollController,
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (state is GetConfigLoadingState) ...[
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: MediaQuery.of(context).size.height * 0.3),
                    child: const CircularProgressIndicator(),
                  ),
                )
              ],
              if (state is GetConfigResponseState) ...[
                state.getConfig.fold((l) => Text(l), (content) {
                  final lines = content.split('\n');

                  vmessLinks.clear();
                  vlessLinks.clear();
                  trojanLinks.clear();

                  for (final line in lines) {
                    if (line.startsWith('vmess://')) {
                      vmessLinks.add(line);
                    } else if (line.startsWith('vless://')) {
                      vlessLinks.add(line);
                    } else if (line.startsWith('trojan://')) {
                      trojanLinks.add(line);
                    }
                  }
                  vmessLinks.shuffle();
                  vlessLinks.shuffle();
                  trojanLinks.shuffle();

                  // Take the first ten elements from each list
                  vmessLinks = vmessLinks.take(20).toList();
                  vlessLinks = vlessLinks.take(20).toList();
                  trojanLinks = trojanLinks.take(20).toList();

                  /// here i want to start over fetchDelay and delete last awaits

                  List<String> combinedLinks = [];
                  combinedLinks.addAll(trojanLinks);
                  combinedLinks.addAll(vlessLinks);
                  combinedLinks.addAll(vmessLinks);

                  combinedLinks.shuffle();

                  return ListView.separated(
                    controller: _scrollController,
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      total = index;
                      if (index < combinedLinks.length) {
                        return buildDelayWidget(combinedLinks[index], index);
                      }
                      // } else if (index <
                      //     vmessLinks.length + vlessLinks.length) {
                      //   final vlessIndex = index - vmessLinks.length;
                      //   return buildDelayWidget(vlessLinks[vlessIndex], index);
                      // } else {
                      //   final trojanIndex =
                      //       index - vmessLinks.length - vlessLinks.length;
                      //   return buildDelayWidget(
                      //       trojanLinks[trojanIndex], index);
                      // }
                    },
                    separatorBuilder: (context, index) {
                      return const Divider();
                    },
                    itemCount: vmessLinks.length +
                        vlessLinks.length +
                        trojanLinks.length,
                  );
                })
              ]
            ],
          );
        },
      ),
      //floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('status'),
        onPressed: () {
          scaffoldKey.currentState!.showBottomSheet(
            (context) => ValueListenableBuilder(
              valueListenable: v2rayStatus,
              builder: (context, value, child) {
                return Container(
                  height: 400,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(value.state),
                      const SizedBox(height: 10),
                      Text(value.duration),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Speed:'),
                          const SizedBox(width: 10),
                          Text(value.uploadSpeed),
                          const Text('↑'),
                          const SizedBox(width: 10),
                          Text(value.downloadSpeed),
                          const Text('↓'),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Traffic:'),
                          const SizedBox(width: 10),
                          Text(value.upload),
                          const Text('↑'),
                          const SizedBox(width: 10),
                          Text(value.download),
                          const Text('↓'),
                        ],
                      ),
                      const SizedBox(height: 10),
                      //Text('Core Version: $coreVersion'),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
      persistentFooterButtons: [
        ElevatedButton(
            onPressed: () {
              BlocProvider.of<ConfigBloc>(context).add(GetConfigStartEvent());
            },
            child: const Text('Get config')),
        ValueListenableBuilder(
            valueListenable: v2rayStatus,
            builder: (context, value, child) {
              if (value.state == 'CONNECTED') {
                showButtonSheet = true;

                return ElevatedButton(
                    style: const ButtonStyle(
                        backgroundColor:
                            MaterialStatePropertyAll(Colors.green)),
                    onPressed: () {
                      flutterV2ray.stopV2Ray();
                    },
                    child: const Text('CONNECTED'));
              } else {
                return ElevatedButton(
                    onPressed: () {
                      flutterV2ray.stopV2Ray();
                    },
                    child: const Text('DISCONNECT'));
              }
            }),
      ],
    );
  }
}
