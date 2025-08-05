import 'package:devgram/features/home/presentation/pages/home_page.dart';
import 'package:devgram/features/profile/presentation/pages/profile_page.dart';
import 'package:flutter/material.dart';

class RootPage extends StatefulWidget {
  final String uid;
  const RootPage({super.key, required this.uid});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _screens.addAll([
      HomeScreen(), // Your actual Home content
      ProfilePage(userId: widget.uid), // Your profile screen
    ]);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(height: 1, thickness: 1, color: Colors.grey),
          BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surface, // 🔵 Background color
            selectedItemColor: Colors.black, // ✅ Active icon/text color
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
