import 'package:flutter/material.dart';
import 'package:get/utils.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:remixicon/remixicon.dart';
import 'package:rotalog/modules/home/home_page.dart';
import 'package:rotalog/modules/settings/settings_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  List<Widget> _pages = [HomePage(), SettingsPage()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,
      body: _pages[_selectedIndex],
      bottomNavigationBar: _buildBottomNav(theme),
    );
  }

  Widget _buildBottomNav(ThemeData theme) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.1),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: GNav(
            gap: screenWidth < 360 ? 4 : 8,
            iconSize: screenWidth < 360 ? 20 : 24,
            curve: Curves.easeOutExpo,
            rippleColor: theme.dividerColor.withOpacity(0.1),
            hoverColor: theme.dividerColor.withOpacity(0.05),
            haptic: true,
            tabBorderRadius: 28,
            activeColor: Colors.blueAccent,
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth < 360 ? 10 : 20,
              vertical: 12,
            ),
            tabBackgroundColor: Colors.blueAccent.withOpacity(0.1),
            selectedIndex: _selectedIndex,
            onTabChange: _onItemTapped,
            tabs: [
              GButton(
                icon: _selectedIndex == 0
                    ? RemixIcons.truck_fill
                    : RemixIcons.truck_line,
                text: "ms_minhas_viagens".tr,
                textStyle: TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth < 360 ? 11 : 13,
                ),
              ),
              GButton(
                icon: _selectedIndex == 1
                    ? RemixIcons.tools_fill
                    : RemixIcons.tools_line,
                text: "ms_configuracao".tr,
                textStyle: TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth < 360 ? 11 : 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
