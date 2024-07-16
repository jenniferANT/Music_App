import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:my_app/Data/model/song.dart';
import 'package:http/http.dart' as http;

abstract interface class DataSource {
  Future<List<Song>?> loadData();
}

class RemoteDataSource implements DataSource {
  @override
  //Phương thức loadData là một hàm bất đồng bộ, trả về một đối tượng Future chứa danh sách các đối tượng Song hoặc null.
  Future<List<Song>?> loadData() async {
    //Dòng này thực hiện một yêu cầu HTTP GET bất đồng bộ đến URL được chỉ định để lấy dữ liệu bài hát.
    final response = await http.get(
        Uri.parse('https://thantrieu.com/resources/braniumapis/songs.json'));
    if (response.statusCode == 200) {
      //Nội dung phản hồi được giải mã từ bytes thành chuỗi UTF-8.
      final bodyContent = utf8.decode(response.bodyBytes);
      //Nội dung JSON của phản hồi được phân tích thành một map của Dart (songWapper).
      //Sau đó, khóa songs được sử dụng để trích xuất danh sách các bài hát (songList).
      var songWapper = jsonDecode(bodyContent) as Map;
      var songList = songWapper['songs'] as List;
      //songList được chuyển đổi thành danh sách các đối tượng Song
      //bằng cách gọi hàm tạo Song.fromJson cho từng phần tử trong danh sách.
      List<Song> songs = songList.map((e) => Song.fromJson(e)).toList();
      return songs;
    } else {
      throw Exception('Failed to load data');
    }
  }
}

class LocalDataSource implements DataSource {
  @override
  Future<List<Song>?> loadData() async {
    try {
      final response = await rootBundle.loadString('assets/songs.json');
      if (response.isNotEmpty) {
        final Map<String, dynamic> songWrapper = jsonDecode(response);
        if (songWrapper['songs'] is List) {
          final List<dynamic> songList = songWrapper['songs'];
          List<Song> songs = songList.map((e) => Song.fromJson(e)).toList();
          return songs;
        } else {
          throw Exception('Invalid data format: songs should be a list');
        }
      } else {
        throw Exception('Empty response from local data');
      }
    } catch (e) {
      throw Exception('Failed to load local data: $e');
    }
  }
}
