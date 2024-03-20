import 'package:flutter_v2ray/flutter_v2ray.dart';
import 'package:flutter_v2ray/url/url.dart';
import 'package:web_scraper/web_scraper.dart';

abstract class IConfigDatasource {
  Future<String> getAllConfig();
  Future<int> getDelayConfig(String link);
}

class ConfigDatasource extends IConfigDatasource {
  @override
  Future<String> getAllConfig() async {
    try {
      final webScraper = WebScraper('https://raw.githubusercontent.com');
      await webScraper
          .loadWebPage('/barry-far/V2ray-Configs/main/All_Configs_Sub.txt');
      var content = webScraper.getPageContent();
      //print(content);
      return content;
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<int> getDelayConfig(String link) async {
    late final FlutterV2ray flutterV2ray = FlutterV2ray(
      onStatusChanged: (status) {
        // v2rayStatus.value = status;
      },
    );
    final V2RayURL v2rayURL = FlutterV2ray.parseFromURL(link);

    final delay = await flutterV2ray.getServerDelay(
        config: v2rayURL.getFullConfiguration());
    return delay;
  }
}
