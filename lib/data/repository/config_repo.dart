import 'package:dartz/dartz.dart';
import 'package:free_name/data/datasource/config_datasource.dart';
import 'package:free_name/di/di.dart';

abstract class IConfigRepository {
  Future<Either<String, String>> getAllConfigs();
  Future<Either<String, int>> getDelayConfigs(String link);
  Future<Either<String, String>> rebuildConfigs(String content);
}

class ConfigRepository extends IConfigRepository {
  @override
  final IConfigDatasource _datasource = locator.get();
  Future<Either<String, String>> getAllConfigs() async {
    try {
      var resposne = await _datasource.getAllConfig();
      return right(resposne);
    } catch (e) {
      return left(e.toString());
    }
  }

  @override
  Future<Either<String, int>> getDelayConfigs(String link) async {
    try {
      var resposne = await _datasource.getDelayConfig(link);
      return right(resposne);
    } catch (e) {
      return left(e.toString());
    }
  }

  @override
  Future<Either<String, String>> rebuildConfigs(String content) async {
    try {
      await Future.delayed(Duration(seconds: 1));
      return right(content);
    } catch (e) {
      return left(e.toString());
    }
  }
}
