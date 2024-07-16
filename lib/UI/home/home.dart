import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:my_app/Data/model/song.dart';
import 'package:my_app/Data/model/viewmodel.dart';
import 'package:my_app/UI/discovery/discovery.dart';
import 'package:my_app/UI/now_play/playing.dart';
import 'package:my_app/UI/settings/settings.dart';
import 'package:my_app/UI/user/user.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Widget> _tabScreens = [
    HomeTab(),
    const DiscoveryTab(),
    const AccountTab(),
    const SettingsTab()
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('Music Player'),
        ),
        child: CupertinoTabScaffold(
          tabBar: CupertinoTabBar(
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.home), label: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.music_albums), label: 'Discover'),
              BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.person), label: 'Account'),
              BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.settings), label: 'Settings'),
            ],
          ),
          tabBuilder: (BuildContext context, int index) {
            return _tabScreens[index];
          },
        ));
  }
}

class HomeTab extends StatelessWidget {
  HomeTab({Key? key});

  @override
  Widget build(BuildContext context) {
    return const HomeTabPage();
  }
}

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  List<Song> songs = [];
  late MusicAppViewModel _viewModel;

  void initState() {
    _viewModel = MusicAppViewModel();
    _viewModel.loadSong();
    observeData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getBody(),
    );
  }

  @override
  void dispose() {
    _viewModel.streamController.close();
    super.dispose();
  }

  Widget getBody() {
    bool showLoading = songs.isEmpty;
    if (showLoading) {
      return getProgressBar();
    } else {
      return getListView();
    }
  }

  Widget getProgressBar() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget getListView() {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: songs.length,
      separatorBuilder: (context, index) => const Divider(
        color: Colors.blueGrey,
        thickness: 0.2,
        indent: 24,
        endIndent: 24,
      ),
      itemBuilder: (context, index) {
        return getRrow(index);
      },
    );
  }

  Widget getRrow(index) {
    return _SongItemSection(parent: this, song: songs[index]);
  }

  void observeData() {
    _viewModel.streamController.stream.listen((songList) {
      setState(() {
        songs.addAll(songList);
      });
    });
  }

  void showBottomSheet() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            child: Container(
              height: 200,
              width: double.infinity,
              color: Colors.white12,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const ListTile(
                    title: Text("Add to Playlist"),
                  ),
                  ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("Add to Playlist")),
                ],
              ),
            ),
          );
        });
  }

  void navigate(Song song) {
    Navigator.push(context, CupertinoPageRoute(builder: (context) {
      return NowPlaying(playingSong: song, songs: songs);
    }));
  }
}

class _SongItemSection extends StatelessWidget {
  const _SongItemSection({
    required this.parent,
    required this.song,
  });

  final _HomeTabPageState parent;
  final Song song;

  @override
  Widget build(BuildContext context) {
    return ListTile(
        onTap: () {
          parent.navigate(song);
        },
        contentPadding: const EdgeInsets.only(
          left: 24,
          right: 8,
        ),
        title: Text(song.title),
        subtitle: Text(song.artist),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: FadeInImage.assetNetwork(
            placeholder: 'assets/Totoro.jpeg',
            image: song.image,
            width: 48,
            height: 48,
            imageErrorBuilder: (context, error, stackTrace) {
              return const Text("Failed");
            },
          ),
        ),
        trailing: IconButton(
            onPressed: () {
              parent.showBottomSheet();
            },
            icon: const Icon(Icons.more_horiz)));
  }
}
