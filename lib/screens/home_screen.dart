import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// providers
import '../providers/user_provider.dart';
// screens
import './add_post_screen.dart';
import './posts_screen.dart';
import './user_profile_screen.dart';
// widgets
import '../widgets/myfeed_appbar.dart';

// screen for homescreen (screen that holds page view)
class HomeScreen extends StatefulWidget {
  const HomeScreen({ Key? key }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// state of screen
class _HomeScreenState extends State<HomeScreen> {
  int currentTab = 0;
  late PageController pageController;

  // initialize state (runs only once)
  // no parameters
  // no return
  @override
  void initState() {
    super.initState();
    initUserProvider();
    pageController = PageController();
  }

  // dispose to release resources
  // no parameters
  // no return
  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  // initialize user provider by calling refreshUser method from the provider
  // no parameters
  // no return
  void initUserProvider() async {
    // to use refreshUser
    // similar to context.read<Model>(); // to use method from provider
    UserProvider _userProvider = Provider.of(context, listen: false); 
    await _userProvider.refreshUser();
  }

  // used when tapping navigation tab
  // takes in page index (tab)
  // no return
  void changeTab(int page) {
    currentTab = page;  // to change selected tab color
    pageController.jumpToPage(page);  // jump to that page
  }
  
  // widget build method
  // takes in context
  // returns the widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyFeedAppBar(),
      backgroundColor: const Color.fromRGBO(27, 22, 38, 1),

      // PAGE VIEW
      body: PageView(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),  // avoid scrolling tabs
        // order of BottomNavigationBarItem corresponds to the screens in the PageView
        children: [   // render screen depending on navigation tab (index-based)
          const PostsScreen(),
          UserProfileScreen(uid: FirebaseAuth.instance.currentUser!.uid),  // pass uid of current user (profile screen)
          const AddPostScreen(),
        ],
      ),

      // BOTTOM NAVIGATION BAR
      bottomNavigationBar: BottomNavigationBar( // need at least 2 items
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        currentIndex: currentTab,
        onTap: (index) {  // get the index of clicked item
          setState(() {
            changeTab(index);
          });
        },
        items: const [
          // HOME
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
            ),
            label: 'Home',
          ),

          // PROFILE
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),

          // ADD POST
          BottomNavigationBarItem(
            icon: Icon(Icons.add_comment),
            label: 'Post'
          ),
        ],
      )
    );
  }
}