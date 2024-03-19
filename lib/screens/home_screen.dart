import 'package:flutter/material.dart';
import 'package:web_scraper/web_scraper.dart';

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
  List<String> trojanLinks = [];
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
          } else if (line.startsWith('trojan://')) {
            trojanLinks.add(line);
          }
        }
      });
    }
    vmessLinks.shuffle();
    vlessLinks.shuffle();
    trojanLinks.shuffle();

    // Take the first ten elements from each list
    vmessLinks = vmessLinks.take(10).toList();
    vlessLinks = vlessLinks.take(10).toList();
    trojanLinks = trojanLinks.take(10).toList();
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
              } else if (index < vmessLinks.length + vlessLinks.length) {
                final vlessIndex = index - vmessLinks.length;
                return ListTile(
                  title: Text('VLess link ${vlessIndex + 1}'),
                  subtitle: Text(vlessLinks[vlessIndex]),
                );
              } else {
                final trojanIndex =
                    index - vmessLinks.length - vlessLinks.length;
                return ListTile(
                  title: Text('Trojan link ${trojanIndex + 1}'),
                  subtitle: Text(trojanLinks[trojanIndex]),
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
