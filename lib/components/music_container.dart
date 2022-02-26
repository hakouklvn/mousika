import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:music_play/components/music_card.dart';
import 'package:music_play/components/song_info.dart';
import 'package:music_play/constants.dart';
import 'package:music_play/screens/musicPlayer/music_player.dart';

class MusicContainer extends StatelessWidget {
  final MediaItem currentSong;
  final double containerWidth;
  const MusicContainer({
    Key? key,
    required this.currentSong,
    required this.containerWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        // hide keyboard programaticlly first to avoid renderflex error
        FocusScope.of(context).unfocus();
        Navigator.of(context).push(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 700),
            pageBuilder: (context, animation, _) => MusicPlayer(
              currentSong: currentSong,
            ),
          ),
        );
      },
      child: Container(
        width: double.maxFinite,
        height: height * 0.1,
        margin: const EdgeInsets.symmetric(vertical: defaultPadding * 0.1),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            AnimatedContainer(
              constraints: const BoxConstraints(
                maxWidth: double.maxFinite,
                minWidth: 0.0,
              ),
              width: containerWidth,
              height: height * 0.1,
              duration: const Duration(seconds: 1),
              curve: Curves.fastOutSlowIn,
              color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.4),
            ),
            Row(
              children: [
                Hero(
                  tag: 'song${currentSong.title}',
                  transitionOnUserGestures: true,
                  createRectTween: (begin, end) {
                    return MaterialRectCenterArcTween(begin: begin, end: end);
                  },
                  child: currentSong.extras!['image'] == null
                      ? const MusicCard(
                          width: 80,
                          height: double.maxFinite,
                          icon: Icons.music_note_rounded,
                          size: 40,
                          opacity: 0.0,
                        )
                      : musicImage(),
                ),
                const SizedBox(width: defaultPadding * 0.7),
                Flexible(
                  flex: 3,
                  fit: FlexFit.tight,
                  child: SongInfo(
                    title: currentSong.title,
                    artist: currentSong.artist ?? '',
                    size: 0.01,
                    fontSize: 18,
                  ),
                ),
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Icon(
                    Icons.more_vert_rounded,
                    color: Theme.of(context).iconTheme.color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Container musicImage() {
    return Container(
      width: 80,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/arcade.png'),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          bottomLeft: Radius.circular(10),
        ),
      ),
    );
  }
}
