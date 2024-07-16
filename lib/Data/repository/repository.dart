import 'package:my_app/Data/model/song.dart';
import 'package:my_app/Data/source/sources.dart';

abstract interface class Repository {
  Future<List<Song>?> loadData();
}

class DefaultRepository implements Repository {
  final _remotDataSource = RemoteDataSource();
  final _localDataSource = LocalDataSource();

  @override
  Future<List<Song>?> loadData() async {
    try {
      return await _remotDataSource.loadData();
    } catch (e) {
      return await _localDataSource.loadData();
    }
  }
}