import 'package:flutter/material.dart';
import 'package:musify/components/layout.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:musify/components/mini_player.dart';
import 'package:musify/constants.dart';
import 'package:musify/main.dart';
import 'package:musify/models/album.dart';
import 'package:musify/models/category.dart';
import 'package:musify/screens/album_screen.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:musify/screens/albums_screen.dart';

import '../utils/musify_http_client.dart';

class ListenNowScreen extends HookConsumerWidget {
  static const routeName = 'ListenNow';

  const ListenNowScreen({Key? key}) : super(key: key);

  Future<List<Category>> fetchData() async {
    var categoryRes = await MusifyHttpClient.get('/musifyserver/categories');
    if (categoryRes['code'] != 200) {
      return [];
    }
    List<Category> categories = [];
    for (var c in categoryRes['data']) {
      var albumRes = await MusifyHttpClient.get(
          '/musifyserver/albums?categories=${c['_id']}');
      List<Album> albums = [];
      if (albumRes['code'] == 200) {
        for (var a in albumRes['data']) {
          albums.add(Album(
            id: a["_id"],
            name: a["name"],
            wallpaper: "$kMusifyHost${a["wallpaper"]}",
          ));
        }
      }
      categories.add(Category(
        id: c['_id'],
        name: c['name'],
        wallpaper: "$kMusifyHost${c["wallpaper"]}",
        albums: albums,
      ));
    }
    return categories;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final miniPlayer = ref.watch(miniPlayerProvider);

    return Layout(
      body: FutureBuilder<List<Category>>(
        future: fetchData(),
        builder: (context, snapshot) {
          List<Widget> children;
          if (snapshot.hasData) {
            children = <Widget>[];

            children.add(Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 25,
                vertical: 10,
              ),
              child: Text(
                "Listen Now",
                style: GoogleFonts.varelaRound(
                  textStyle: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ));
            var categories = snapshot.data ?? [];
            for (var c in categories) {
              children.add(Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      c.name,
                      style: GoogleFonts.varelaRound(
                        textStyle: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AlbumsScreen.routeName,
                            arguments: c);
                      },
                      child: Text(
                        'See All',
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            fontSize: 16,
                            color: Color(0xffEA4C89),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ));

              children.add(Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                height: 225,
                child: ListView.builder(
                    padding: const EdgeInsets.only(left: 25),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      var album = c.albums[index];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AlbumScreen.routeName,
                                arguments: album,
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(
                                right: 10,
                                bottom: 10,
                              ),
                              width: 165,
                              height: 170,
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
                            ),
                          ),
                          Text(
                            album.name,
                            style: GoogleFonts.poppins(
                              textStyle: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                    itemCount: c.albums.length),
              ));

              children.add(const Padding(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: Divider(
                  thickness: 1,
                ),
              ));
            }
          } else if (snapshot.hasError) {
            children = <Widget>[];
          } else {
            return const Center(
              child: SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(),
              ),
            );
          }
          return ListView.builder(
              padding: const EdgeInsets.only(
                top: 80,
              ),
              itemBuilder: (context, index) {
                return children[index];
              },
              itemCount: children.length);
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
