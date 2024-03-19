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
      // v2rayStatus.value = status;
    },
  );
  ScrollController _scrollController = ScrollController();
  final webScraper = WebScraper('https://raw.githubusercontent.com');
  List<String> vmessLinks = [];
  List<String> vlessLinks = [];
  List<String> trojanLinks = [];
  List<int> vmessDelays = [];
  List<int> vlessDelays = [];
  List<int> trojanDelays = [];
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
        config: v2rayURL.getFullConfiguration());
    return delay;
  }

  void fetchAllDelays() {
    for (final link in vmessLinks) {
      fetchAndAddDelay(link, 'VMess');
    }
    for (final link in vlessLinks) {
      fetchAndAddDelay(link, 'VLess');
    }
    for (final link in trojanLinks) {
      fetchAndAddDelay(link, 'Trojan');
    }
  }

// Method to fetch and add delay for a single link
  void fetchAndAddDelay(String link, String linkType) async {
    final delay = await fetchDelay(link);

    // Update the UI based on the link type
    if (linkType == 'VMess') {
      vmessDelays.add(delay);
    } else if (linkType == 'VLess') {
      vlessDelays.add(delay);
    } else if (linkType == 'Trojan') {
      trojanDelays.add(delay);
    }
    // Update the UI after adding delay
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      persistentFooterAlignment: AlignmentDirectional.topCenter,
      appBar: AppBar(
        elevation: 1.2,
        centerTitle: true,
        title: const Text('Free Net'),
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
                  return ListView.separated(
                    controller: _scrollController,
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      if (index < vmessLinks.length) {
                        return FutureBuilder<int>(
                          future: fetchDelay(vmessLinks[index]),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return ListTile(
                                title: Text('VMess link ${index + 1}'),
                                // subtitle: Text(vmessLinks[index]),
                              );
                            } else if (snapshot.hasData) {
                              return ListTile(
                                title: Text('VMess link ${index + 1}'),
                                trailing: Text(
                                  'Delay: ${snapshot.data}ms',
                                  style: const TextStyle(color: Colors.red),
                                ),
                              );
                            } else if (snapshot.hasError) {
                              return ListTile(
                                title: Text('VMess link ${index + 1}'),
                                //subtitle: Text(vmessLinks[index]),
                              );
                            } else {
                              return SizedBox();
                            }
                          },
                        );
                      } else if (index <
                          vmessLinks.length + vlessLinks.length) {
                        final vlessIndex = index - vmessLinks.length;
                        return FutureBuilder<int>(
                          future: fetchDelay(vlessLinks[vlessIndex]),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return ListTile(
                                title: Text('VLess link ${vlessIndex + 1}'),
                                // subtitle: Text(vlessLinks[vlessIndex]),
                              );
                            } else if (snapshot.hasData) {
                              return ListTile(
                                title: Text('VLess link ${vlessIndex + 1}'),
                                trailing: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    //Text(vlessLinks[vlessIndex]),
                                    Text('Delay: ${snapshot.data}ms',
                                        style:
                                            const TextStyle(color: Colors.red)),
                                  ],
                                ),
                              );
                            } else if (snapshot.hasError) {
                              return ListTile(
                                title: Text('VLess link ${vlessIndex + 1}'),
                                // subtitle: Text(vlessLinks[vlessIndex]),
                              );
                            } else {
                              return SizedBox();
                            }
                          },
                        );
                      } else {
                        final trojanIndex =
                            index - vmessLinks.length - vlessLinks.length;
                        return FutureBuilder<int>(
                          future: fetchDelay(trojanLinks[trojanIndex]),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return ListTile(
                                title: Text('Trojan link ${trojanIndex + 1}'),
                                //subtitle: Text(trojanLinks[trojanIndex]),
                              );
                            } else if (snapshot.hasData) {
                              return ListTile(
                                title: Text('Trojan link ${trojanIndex + 1}'),
                                trailing: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Text(trojanLinks[trojanIndex]),
                                    Text('Delay: ${snapshot.data}ms',
                                        style:
                                            const TextStyle(color: Colors.red)),
                                  ],
                                ),
                              );
                            } else if (snapshot.hasError) {
                              return ListTile(
                                title: Text('Trojan link ${trojanIndex + 1}'),
                                //  subtitle: Text(trojanLinks[trojanIndex]),
                              );
                            } else {
                              return SizedBox();
                            }
                          },
                        );
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
        ElevatedButton(
            onPressed: () {
              setState(() {
                vmessDelays.clear();
                vlessDelays.clear();
                trojanDelays.clear();
              });
              fetchAllDelays();
            },
            child: const Text('Test Delay')),
        ElevatedButton(onPressed: () {}, child: const Text('connect')),
      ],
    );
  }
}
