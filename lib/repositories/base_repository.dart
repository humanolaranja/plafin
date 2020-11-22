import 'package:shared_preferences/shared_preferences.dart';

class BaseRepository {
  SharedPreferences _localSource;

  BaseRepository({SharedPreferences localSource}) {
    this._localSource = localSource;
  }

  Future<SharedPreferences> getLocalSource() async {
    return this._localSource ?? await SharedPreferences.getInstance();
  }
}
