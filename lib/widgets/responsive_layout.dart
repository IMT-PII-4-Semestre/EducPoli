import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 800;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 800 &&
      MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 800) {
          return mobile;
        } else if (constraints.maxWidth < 1200) {
          return tablet ?? desktop;
        } else {
          return desktop;
        }
      },
    );
  }
}

// Widget para dashboards responsivos
class ResponsiveDashboard extends StatelessWidget {
  final String title;
  final Color headerColor;
  final List<DashboardMenuItem> menuItems;
  final VoidCallback onLogout;

  const ResponsiveDashboard({
    super.key,
    required this.title,
    required this.headerColor,
    required this.menuItems,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildMobileLayout(context),
      desktop: _buildDesktopLayout(context),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: headerColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: onLogout),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: headerColor),
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...menuItems.map(
              (item) => ListTile(
                leading: Icon(item.icon),
                title: Text(item.title),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, item.route);
                },
              ),
            ),
          ],
        ),
      ),
      body: Container(
        color: Colors.grey[100],
        child: GridView.count(
          crossAxisCount: 2,
          padding: const EdgeInsets.all(16),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: menuItems.map((item) => _buildCard(context, item)).toList(),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            height: 100,
            color: headerColor,
            child: Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                ),
                const Spacer(),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: onLogout,
                  icon: const Icon(Icons.person, color: Colors.white, size: 28),
                ),
              ],
            ),
          ),

          // Corpo
          Expanded(
            child: Row(
              children: [
                // Menu lateral
                Container(
                  width: 250,
                  color: Colors.grey[300],
                  child: ListView(
                    children: [
                      const SizedBox(height: 40),
                      ...menuItems.map(
                        (item) => Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            leading: Icon(item.icon, color: Colors.black),
                            title: Text(
                              item.title,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            onTap: () =>
                                Navigator.pushNamed(context, item.route),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Área principal
                Expanded(
                  child: Container(
                    color: Colors.grey[100],
                    child: Center(
                      child: Wrap(
                        spacing: 40,
                        runSpacing: 40,
                        alignment: WrapAlignment.center,
                        children: menuItems
                            .map((item) => _buildCard(context, item))
                            .toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, DashboardMenuItem item) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, item.route),
      child: Container(
        width: 180,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, size: 40, color: Colors.black54),
            const SizedBox(height: 12),
            Text(
              item.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardMenuItem {
  final String title;
  final IconData icon;
  final String route;

  const DashboardMenuItem({
    required this.title,
    required this.icon,
    required this.route,
  });
}
