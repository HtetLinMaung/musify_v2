import 'package:musify/models/album.dart';

class Category {
  String id;
  String name;
  String wallpaper;
  List<Album> albums;

  Category({
    required this.id,
    required this.name,
    required this.wallpaper,
    required this.albums,
  });
}
