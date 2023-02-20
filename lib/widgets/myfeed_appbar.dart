import 'package:flutter/material.dart';

// screens
import '../screens/search_screen.dart';

// class for appbar (with search icon)
// app bar needs preferredsize
class MyFeedAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyFeedAppBar({ Key? key }) : super(key: key);

  // preferredsize getter
  @override
  Size get preferredSize => const Size.fromHeight(60);

  // widget build method
  // takes in context
  // returns the widget
  @override
  Widget build(BuildContext context) {

    // APPBAR
    return AppBar(
      title: const Text('MyFeed'),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red, Colors.purple],
            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
          )
        ),
      ),
      actions: [
        
        // SEARCH ICON
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: ((context) => const SearchScreen()))
            );
          },
        )
      ],
    );
  }
}