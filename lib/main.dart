import 'package:flutter/material.dart';
import 'package:web_scraper/web_scraper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FreeNet',
      theme: ThemeData(
        brightness: Brightness.dark,
        //colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyMain(),
    );
  }
}

class MyMain extends StatefulWidget {
  const MyMain({super.key});

  @override
  State<MyMain> createState() => _MyMainState();
}

class _MyMainState extends State<MyMain> {
  ScrollController _scrollController = ScrollController();
  final webScraper = WebScraper('https://raw.githubusercontent.com');
  List<String> vmessLinks = [];
  List<String> vlessLinks = [];
  void initState() {
    // TODO: implement initState
    fetchProducts();
    super.initState();
  }

  void fetchProducts() async {
    if (await webScraper
        .loadWebPage('/barry-far/V2ray-Configs/main/All_Configs_Sub.txt')) {
      setState(() {
        final content = webScraper.getPageContent();

        final lines = content.split('\n');
        for (final line in lines) {
          if (line.startsWith('vmess://')) {
            vmessLinks.add(line);
          } else if (line.startsWith('vless://')) {
            vlessLinks.add(line);
          }
        }
      });
    }
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
      body: ListView(
        controller: _scrollController,
        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ListView.separated(
            controller: _scrollController,
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              if (index < vmessLinks.length) {
                return ListTile(
                  title: Text('VMess link ${index + 1}'),
                  subtitle: Text(vmessLinks[index]),
                );
              } else {
                final vlessIndex = index - vmessLinks.length;
                return ListTile(
                  title: Text('VLess link ${vlessIndex + 1}'),
                  subtitle: Text(vlessLinks[vlessIndex]),
                );
              }
            },
            separatorBuilder: (context, index) {
              return const Divider();
            },
            itemCount: vmessLinks.length + vlessLinks.length,
          ),
        ],
      ),
      persistentFooterButtons: [
        ElevatedButton(onPressed: () {}, child: const Text('Get config')),
        ElevatedButton(onPressed: () {}, child: const Text('Test')),
        ElevatedButton(onPressed: () {}, child: const Text('connect')),
      ],
    );
  }
}
