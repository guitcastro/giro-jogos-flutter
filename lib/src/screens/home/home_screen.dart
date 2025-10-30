import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import 'duo_wrapper_screen.dart';
import 'settings_tab.dart';

import '../../services/duo_service.dart';

class HomeScreen extends StatefulWidget {
  final DuoService? duoService;
  const HomeScreen({super.key, this.duoService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        final user = authService.currentUser;
        final screens = [
          DuoWrapperScreen(
            userId: user?.uid ?? '',
            getNames: (ids) async =>
                ids, // TODO: Substitua por função real de nomes
            getScore: (duoId) async =>
                0, // TODO: Substitua por função real de score
          ),
          const SettingsTab(),
        ];
        return Scaffold(
          appBar: AppBar(
            title: const Text('Giro Jogos'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'logout') {
                    await authService.signOut();
                  } else if (value == 'admin') {
                    context.go('/admin');
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    const PopupMenuItem<String>(
                      value: 'admin',
                      child: Row(
                        children: [
                          Icon(Icons.admin_panel_settings),
                          SizedBox(width: 8),
                          Text('Admin Panel'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout),
                          SizedBox(width: 8),
                          Text('Sair'),
                        ],
                      ),
                    ),
                  ];
                },
                icon: const Icon(Icons.more_vert),
              ),
            ],
          ),
          body: screens[_selectedIndex],
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.group),
                label: 'Dupla',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings),
                label: 'Configurações',
              ),
            ],
          ),
        );
      },
    );
  }
}
