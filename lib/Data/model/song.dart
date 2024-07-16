
class Song {
  final String id;
  final String title;
  final String album;
  final String artist;
  final String source;
  final String image;
  final int duration;
  // final bool favorite;
  // final int counter;
  // final int replay;

  Song({
    required this.id,
    required this.title,
    required this.album,
    required this.artist,
    required this.source,
    required this.image,
    required this.duration,
    // required this.favorite,
    // required this.counter,
    // required this.replay,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'],
      title: json['title'],
      album: json['album'],
      artist: json['artist'],
      source: json['source'],
      image: json['image'],
      duration: json['duration'],
      // favorite: json['favorite'],
      // counter: json['counter'],
      // replay: json['replay'],
    );
  }
  @override
  bool operator == (Object other) {
    if (identical(this, other)) return true;

    if (other is! Song) return false;

    return other.title == title && other.artist == artist;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Song(id: $id, title: $title, album: $album, artist: $artist, source: $source, image: $image, duration: $duration)';
  }

}