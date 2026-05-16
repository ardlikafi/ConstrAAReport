import 'package:flutter/material.dart';
import 'package:constraa_report/screens/dashboard_screen.dart';
import 'package:constraa_report/screens/rekap_screen.dart';
import 'package:constraa_report/screens/login_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const RekapScreen(),
  ];

  void _onLogout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.domain_verification_outlined),
            SizedBox(width: 8),
            Text('ConstrAAReport', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: PopupMenuButton(
              child: const Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white24,
                    radius: 14,
                    child: Text('R', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                  SizedBox(width: 8),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('robert', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      Text('Pengunjung', style: TextStyle(fontSize: 10, color: Colors.white70)),
                    ],
                  ),
                  Icon(Icons.arrow_drop_down),
                ],
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  onTap: _onLogout,
                  child: const Row(
                    children: [
                      Icon(Icons.logout, color: Colors.black87),
                      SizedBox(width: 8),
                      Text('Keluar'),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: const Color(0xFF2F66A9),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            activeIcon: Icon(Icons.description),
            label: 'Rekap Laporan',
          ),
        ],
      ),
    );
  }
}
