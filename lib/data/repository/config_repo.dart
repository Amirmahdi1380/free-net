import 'package:dartz/dartz.dart';
import 'package:free_name/data/datasource/config_datasource.dart';
import 'package:free_name/di/di.dart';

abstract class IConfigRepository {
  Future<Either<String, String>> getAllConfigs();
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
}
