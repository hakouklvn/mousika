import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:music_play/constants.dart';
import 'package:music_play/manager/page_manager.dart';
import 'package:music_play/notifiers/play_button_notifier.dart';
import 'package:music_play/screens/musicPlayer/components/music_description.dart';
import 'package:music_play/screens/musicPlayer/components/music_slider.dart';
import 'package:music_play/services/convert_song.dart';
import 'package:music_play/services/service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'components/music_image_cover.dart';
import 'components/music_play_button.dart';
import 'services/favourite_music_service.dart';

class MusicPlayer extends StatefulWidget {
  final MediaItem currentSong;
  const MusicPlayer({Key? key, required this.currentSong}) : super(key: key);

  @override
  _MusicPlayerState createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> {
  static bool isCurrentSong = true;
  static bool isSongplaying = true;

  final pageManager = getIt<PageManager>();

  final favouriteSongs = getIt<FavouriteSongs>();
  final convertSong = ConvertSong();

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<bool> _isFavourite;

  @override
  void initState() {
    if (widget.currentSong != pageManager.currentSongNotifier.value) {
      isCurrentSong = false;
      isSongplaying = false;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _isFavourite = _prefs.then((SharedPreferences prefs) {
      // print(pageManager.currentSongNotifier.value);
      return prefs.getStringList('favouriteSong')!.contains(
            json.encode(
              convertSong.toSongMetadata(
                // pageManager.currentSongNotifier.value,
                isCurrentSong
                    ? pageManager.currentSongNotifier.value
                    : widget.currentSong,
              ),
            ),
          );
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.chevron_left_rounded,
            size: Theme.of(context).iconTheme.size,
            color: Theme.of(context).iconTheme.color,
          ),
        ),
        title: musicTitle(),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        actions: [
          FutureBuilder<bool>(
            future: _isFavourite,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                return IconButton(
                  onPressed: () {
                    snapshot.data
                        ? favouriteSongs.removeSong(widget.currentSong)
                        : favouriteSongs.addSong(widget.currentSong);
                    setState(() {});
                  },
                  icon: favouriteSongStateIcon(snapshot.data ?? false),
                );
              }
              return Container();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 2,
                child: MusicImageCover(
                  title: widget.currentSong.title,
                  image: widget.currentSong.extras?['image'],
                ),
              ),
              Expanded(
                flex: 1,
                child: ValueListenableBuilder<MediaItem>(
                  valueListenable: pageManager.currentSongNotifier,
                  builder: (_, song, __) {
                    return MusicDescription(
                      currentSong: isCurrentSong ? song : widget.currentSong,
                    );
                  },
                ),
              ),
              musicController()
            ],
          ),
        ),
      ),
    );
  }

  Widget musicTitle() {
    return isCurrentSong
        ? ValueListenableBuilder<ButtonState>(
            valueListenable: pageManager.playButtonNotifier,
            builder: (_, buttonState, __) {
              return Text(
                buttonState == ButtonState.paused ? 'Stopped' : 'Playing now',
                style: Theme.of(context).textTheme.headline6!.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                    ),
              );
            },
          )
        : Text(
            'Stopped',
            style: Theme.of(context).textTheme.headline6!.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                ),
          );
  }

  Column musicController() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // First Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 2,
              child: ValueListenableBuilder<ButtonState>(
                  valueListenable: pageManager.playButtonNotifier,
                  builder: (_, buttonState, __) {
                    return isSongplaying
                        ? PlayButton(
                            press: () {
                              buttonState == ButtonState.paused
                                  ? pageManager.play()
                                  : pageManager.pause();
                            },
                            buttonState: buttonState == ButtonState.paused,
                          )
                        : PlayButton(
                            press: () {
                              isSongplaying = !isSongplaying;
                              pageManager.playSpecificSong(widget.currentSong);
                              pageManager.play();
                              setState(() {});
                            },
                            buttonState: true,
                          );
                  }),
            ),
            Expanded(
              flex: 1,
              child: FloatingActionButton.large(
                heroTag: null,
                onPressed: () {
                  isCurrentSong = true;
                  pageManager.next();

                  setState(() {});
                },
                child: Icon(
                  Icons.skip_next_rounded,
                  size: Theme.of(context).iconTheme.size,
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
        // Second Row
        const SizedBox(height: defaultPadding * 1.3),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FloatingActionButton.large(
              heroTag: null,
              onPressed: () {
                isCurrentSong = true;
                pageManager.previous();
                setState(() {});
              },
              child: Icon(
                Icons.skip_previous_rounded,
                size: Theme.of(context).iconTheme.size,
              ),
              elevation: 0,
            ),
            Expanded(
              child: MusicSlider(isCurrentSong: isSongplaying),
            ),
          ],
        )
      ],
    );
  }

  Icon favouriteSongStateIcon(bool isFavourite) {
    return isFavourite
        ? const Icon(Icons.favorite_rounded, size: 30, color: Colors.green)
        : Icon(
            Icons.favorite_outline_rounded,
            size: 30,
            color: Theme.of(context).iconTheme.color,
          );
  }
}
