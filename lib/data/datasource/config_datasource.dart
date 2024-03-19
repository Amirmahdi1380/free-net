import 'package:web_scraper/web_scraper.dart';

abstract class IConfigDatasource {
  Future<String> getAllConfig();
}

class ConfigDatasource extends IConfigDatasource {
  @override
  Future<String> getAllConfig() async {
    try {
      final webScraper = WebScraper('https://raw.githubusercontent.com');
      await webScraper
          .loadWebPage('/barry-far/V2ray-Configs/main/All_Configs_Sub.txt');
      var content = webScraper.getPageContent();
      return content;
    } catch (e) {
      throw Exception(e);
    }
  }
}
