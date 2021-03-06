import 'package:flutter/material.dart';

class Layout extends StatelessWidget {
  final Widget? body;
  final PreferredSizeWidget? appBar;
  final List<Widget>? persistentFooterButtons;

  const Layout({
    Key? key,
    this.body,
    this.appBar,
    this.persistentFooterButtons,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: body,
      persistentFooterButtons: persistentFooterButtons,
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_fill_rounded),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: '',
          ),
        ],
      ),
    );
  }
}
