import 'package:flutter/material.dart';
import 'package:senzsafe/src/services/auth_service.dart';

class SidebarDrawer extends StatelessWidget {
  final String currentRoute;

  const SidebarDrawer({Key? key, required this.currentRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: const Text(
              "Sidebar Menu",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.dashboard,
            title: "Dashboard",
            route: "/dashboard",
            isSelected: currentRoute == "/dashboard",
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.group,
            title: "Users",
            route: "/users",
            isSelected: currentRoute == "/users",
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.fork_right,
            title: "Branches",
            route: "/branches",
            isSelected: currentRoute == "/branches",
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.fence,
            title: "Gateway",
            route: "/gateway",
            isSelected: currentRoute == "/gateway",
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.electrical_services,
            title: "Controller",
            route: "/controller",
            isSelected: currentRoute == "/controller",
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.circle_outlined,
            title: "Loops",
            route: "/loops",
            isSelected: currentRoute == "/loops",
          ),
          const Divider(), // Divider for separation
          _buildDrawerItem(
            context: context,
            icon: Icons.logout,
            title: "Logout",
            route: "/logout",
            isSelected: false,
            onTap: () async {
              await AuthService.signOut();
              Navigator.popUntil(context, (route) => route.isFirst);
              Navigator.pushReplacementNamed(context, '/signin');
            },
          ),
        ],
      ),
    );
  }

  /// Builds a single drawer item
  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String route,
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? Theme.of(context).primaryColor : Colors.grey),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Theme.of(context).primaryColor : Colors.black,
        ),
      ),
      selected: isSelected,
      onTap: onTap ??
              () {
            Navigator.pop(context); // Close the drawer
            if (route != currentRoute) {
              Navigator.pushReplacementNamed(context, route);
            }
          },
    );
  }
}
