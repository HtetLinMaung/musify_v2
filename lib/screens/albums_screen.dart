import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:musify/components/layout.dart';
import 'package:musify/components/mini_player.dart';
import 'package:musify/constants.dart';
import 'package:musify/main.dart';
import 'package:musify/models/album.dart';
import 'package:musify/models/category.dart';
import 'package:musify/screens/album_screen.dart';
import 'package:musify/utils/musify_http_client.dart';

class AlbumsScreen extends HookConsumerWidget {
  static const routeName = 'Albums';

  const AlbumsScreen({Key? key}) : super(key: key);

  Future<List<Album>> fetchAlbums(String categoryId) async {
    var albumRes = await MusifyHttpClient.get(
        "/musifyserver/albums?categories=$categoryId");
    print(albumRes);
    List<Album> albums = <Album>[];
    if (albumRes['code'] == 200) {
      for (var a in albumRes['data']) {
        albums.add(Album(
          id: a["_id"],
          name: a["name"],
          wallpaper: "$kMusifyHost${a["wallpaper"]}",
        ));
      }
    }
    return albums;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = ModalRoute.of(context)!.settings.arguments as Category;
    final miniPlayer = ref.watch(miniPlayerProvider);

    return Layout(
      appBar: AppBar(
        title: Text(
          category.name,
          style: GoogleFonts.varelaRound(
            textStyle: const TextStyle(color: Colors.black),
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: FutureBuilder<List<Album>>(
        future: fetchAlbums(category.id),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final albums = snapshot.data ?? [];
            return GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 15,
                crossAxisSpacing: 10,
              ),
              itemCount: albums.length,
              itemBuilder: (context, index) {
                final album = albums[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AlbumScreen.routeName,
                      arguments: album,
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(album.wallpaper),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.5),
                            Colors.black.withOpacity(0.0),
                          ],
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            album.name,
                            style: GoogleFonts.varelaRound(
                              textStyle: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(
              child: SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
      persistentFooterButtons: miniPlayer
          ? [
              const MiniPlayer(),
            ]
          : null,
    );
  }
}
