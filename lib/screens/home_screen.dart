import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:free_name/bloc/getConfig/config_bloc.dart';
import 'package:free_name/bloc/getConfig/config_event.dart';
import 'package:web_scraper/web_scraper.dart';
import 'package:flutter_v2ray/flutter_v2ray.dart';
import '../bloc/getConfig/config_state.dart';

class MyMain extends StatefulWidget {
  const MyMain({super.key});

  @override
  State<MyMain> createState() => _MyMainState();
}

class _MyMainState extends State<MyMain> {
  late final FlutterV2ray flutterV2ray = FlutterV2ray(
    onStatusChanged: (status) {
      v2rayStatus.value = status;
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

  Future<int> fetchDelay(String link) async {
    final V2RayURL v2rayURL = FlutterV2ray.parseFromURL(link);
    final delay = await flutterV2ray.getServerDelay(
        config: v2rayURL.getFullConfiguration(indent: 0));
    return delay;
  }

  Widget buildDelayWidget(String link) {
    return FutureBuilder<int>(
      future: fetchDelay(link),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListTile(
            title: Text('Link'),
            subtitle: Text('Fetching delay...'),
          );
        } else if (snapshot.hasData) {
          return ListTile(
            title: Text('Link'),
            subtitle: Text('Delay: ${snapshot.data}ms'),
          );
        } else if (snapshot.hasError) {
          return ListTile(
            title: Text('Link'),
            subtitle: Text('Error fetching delay.'),
          );
        } else {
          return SizedBox();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      persistentFooterAlignment: AlignmentDirectional.topCenter,
      appBar: AppBar(
        elevation: 1.2,
        centerTitle: true,
        title: const Text(
          'Free Net',
          style: TextStyle(fontSize: 12),
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
                  vmessLinks = vmessLinks.take(10).toList();
                  vlessLinks = vlessLinks.take(10).toList();
                  trojanLinks = trojanLinks.take(10).toList();

                  /// here i want to start over fetchDelay and delete last awaits

                  return ListView.separated(
                    controller: _scrollController,
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      total = index;
                      if (index < vmessLinks.length) {
                        return buildDelayWidget(vmessLinks[index]);
                      } else if (index <
                          vmessLinks.length + vlessLinks.length) {
                        final vlessIndex = index - vmessLinks.length;
                        return buildDelayWidget(vlessLinks[vlessIndex]);
                      } else {
                        final trojanIndex =
                            index - vmessLinks.length - vlessLinks.length;
                        return buildDelayWidget(trojanLinks[trojanIndex]);
                      }
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
      persistentFooterButtons: [
        ElevatedButton(
            onPressed: () {
              BlocProvider.of<ConfigBloc>(context).add(GetConfigStartEvent());
            },
            child: const Text('Get config')),
        // BlocBuilder<ConfigBloc, GetConfigState>(
        //   builder: (context, state) {
        //     if (state is GetConfigResponseState) {
        //       return state.getConfig.fold(
        //           (l) => Container(),
        //           (r) => ElevatedButton(
        //               onPressed: () async {
        //                 // setState(() {
        //                 //   vlessDelays.clear();
        //                 //   vmessDelays.clear();
        //                 //   trojanDelays.clear();
        //                 // });
        //                 // BlocProvider.of<ConfigBloc>(context)
        //                 //     .add(GetConfigRebuildEvent(r));
        //                 // resetDelayTesting(); // Reset the delay testing index
        //                 // await fetchAllDelays();
        //               },
        //               child: const Text('Test Delay')));
        //     }
        //     return Container();
        //   },
        // ),
        ElevatedButton(onPressed: () {}, child: const Text('connect')),
      ],
    );
  }
}
