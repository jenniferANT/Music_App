import 'dart:async';

import 'package:my_app/Data/model/song.dart';
import 'package:my_app/Data/repository/repository.dart';

class MusicAppViewModel {
  StreamController<List<Song>> streamController =
      StreamController<List<Song>>();

  void loadSong() {
    final repository = DefaultRepository();
    repository.loadData().then((songs) {
      if (songs != null) {
        streamController.add(songs);
      } else {
        streamController.addError('Failed to load data');
      }
    });
  }
}
