import 'package:free_name/data/datasource/config_datasource.dart';
import 'package:free_name/data/repository/config_repo.dart';
import 'package:get_it/get_it.dart';

var locator = GetIt.instance;

Future<void> getItInit() async {
  //datasource
  locator.registerFactory<IConfigDatasource>(() => ConfigDatasource());

  //repository
  locator.registerFactory<IConfigRepository>(() => ConfigRepository());
}
