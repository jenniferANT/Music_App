import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:my_app/Data/model/song.dart';
import 'package:my_app/UI/now_play/audio_player_manager.dart';

class NowPlaying extends StatelessWidget {
  const NowPlaying({super.key, required this.songs, required this.playingSong});

  final Song playingSong;
  final List<Song> songs;

  @override
  Widget build(BuildContext context) {
    return NowPlayingPage(songs: songs, playingSong: playingSong);
  }
}

class NowPlayingPage extends StatefulWidget {
  const NowPlayingPage(
      {super.key, required this.songs, required this.playingSong});

  final Song playingSong;
  final List<Song> songs;

  @override
  State<NowPlayingPage> createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _imageAnimaController;
  late AudioPlayerManager _audioPlayerManager;
  late int selectedIndex;
  late Song _song;
  bool _isShuffle = false;

  @override
  void initState() {
    super.initState();
    _song = widget.playingSong;
    _imageAnimaController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
    _audioPlayerManager =
        AudioPlayerManager(songUrl: widget.playingSong.source);
    _audioPlayerManager.init();

    selectedIndex = widget.songs.indexOf(widget.playingSong);
  }

  @override
  void dispose() {
    _imageAnimaController.dispose();
    _audioPlayerManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const delta = 64;
    final radius = (screenWidth + delta) / 2;
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Now Playing'),
        trailing: IconButton(
          icon: const Icon(Icons.more_horiz),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      child: Scaffold(
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _song.album,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            const SizedBox(height: 10),
            const Text('_ ____ _'),
            const SizedBox(height: 20),
            RotationTransition(
              turns: Tween(begin: 0.0, end: 1.0).animate(_imageAnimaController),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(radius),
                child: FadeInImage.assetNetwork(
                  placeholder: "assets/Totoro.jpeg",
                  image: _song.image,
                  width: screenWidth - delta,
                  height: screenWidth - delta,
                  fit: BoxFit.cover,
                  imageErrorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      "assets/Totoro.jpeg",
                      width: screenWidth - delta,
                      height: screenWidth - delta,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: SizedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                        icon: const Icon(Icons.share_outlined),
                        onPressed: () {}),
                    Column(
                      children: [
                        Text(
                          _song.title,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                        Text(
                          _song.artist,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(color: Colors.black),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.favorite_border),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                right: 24,
                top: 32,
                left: 24,
                bottom: 10,
              ),
              child: _progressBar(),
            ),
            Padding(
              padding: const EdgeInsets.only(
                right: 24,
                top: 0,
                left: 24,
                bottom: 16,
              ),
              child: _mediaButton(),
            ),
          ],
        )),
      ),
    );
  }

  Widget _mediaButton() {
    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          MediaButton(
            function: _setShuffle,
            icon: Icons.shuffle,
            size: 24,
            color: _getShuffleColor(),
          ),
          MediaButton(
            function: () {
              _setPreviousSong();
            },
            icon: Icons.skip_previous,
            size: 36,
            color: Colors.black,
          ),
          _playButton(),
          MediaButton(
            function: () {
              _setNextSong();
            },
            icon: Icons.skip_next,
            size: 36,
            color: Colors.black,
          ),
          MediaButton(
            function: () {
              // _audioPlayerManager.seekToNext();
            },
            icon: Icons.repeat,
            size: 24,
            color: Colors.black,
          ),
        ],
      ),
    );
  }

  StreamBuilder<DurationState> _progressBar() {
    return StreamBuilder<DurationState>(
        stream: _audioPlayerManager.durationStateStream,
        builder: (context, snapshot) {
          final durationState = snapshot.data;
          final progress = durationState?.progress ?? Duration.zero;
          final buffered = durationState?.buffered ?? Duration.zero;
          final total = durationState?.total ?? Duration.zero;
          return ProgressBar(
            progress: progress,
            total: total,
            onSeek: _audioPlayerManager.player.seek,
          );
        });
  }

  StreamBuilder<PlayerState> _playButton() {
    return StreamBuilder(
        stream: _audioPlayerManager.player.playerStateStream,
        builder: (context, snapshot) {
          final playState = snapshot.data;
          final processingState = playState?.processingState;
          final playing = playState?.playing;
          if (processingState == ProcessingState.loading ||
              processingState == ProcessingState.buffering) {
            return Container(
              margin: const EdgeInsets.all(8.0),
              width: 48.0,
              height: 48.0,
              child: const CircularProgressIndicator(),
            );
          } else if (playing != true) {
            return MediaButton(
              function: () {
                _audioPlayerManager.player.play();
              },
              icon: Icons.play_arrow,
              color: null,
              size: 48.0,
            );
          } else if (processingState != ProcessingState.completed) {
            return MediaButton(
              function: () {
                _audioPlayerManager.player.pause();
              },
              icon: Icons.pause,
              color: null,
              size: 48.0,
            );
          } else {
            return MediaButton(
              function: () {
                _audioPlayerManager.player.seek(Duration.zero);
              },
              icon: Icons.replay,
              color: null,
              size: 48.0,
            );
          }
        });
  }

  void _setNextSong() {
    ++selectedIndex;
    final nextSong = widget.songs[selectedIndex];
    _audioPlayerManager.updateSongUrl(nextSong.source);
    setState(() {
      _song = nextSong;
    });
  }

  void _setPreviousSong() {
    --selectedIndex;
    final previousSong = widget.songs[selectedIndex];
    _audioPlayerManager.updateSongUrl(previousSong.source);
    setState(() {
      _song = previousSong;
    });
  }

  void _setShuffle() {
    setState(() {
      _isShuffle = !_isShuffle;
    });
  }

  Color? _getShuffleColor() {
    return _isShuffle ? Colors.black : null;
  }
}

class MediaButton extends StatefulWidget {
  const MediaButton(
      {super.key,
      required this.function,
      required this.icon,
      required this.color,
      required this.size});

  final void Function()? function;
  final IconData icon;
  final double? size;
  final Color? color;

  @override
  State<MediaButton> createState() => _MediaButtonState();
}

class _MediaButtonState extends State<MediaButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(widget.icon),
      iconSize: widget.size,
      color: widget.color,
      onPressed: widget.function,
    );
  }
}
