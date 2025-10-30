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

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        final user = authService.currentUser;
        // Espera que DuoService já esteja provido externamente via Provider
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
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(
                  icon: Icon(Icons.group),
                  text: 'Dupla',
                ),
                Tab(
                  icon: Icon(Icons.settings),
                  text: 'Configurações',
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              DuoWrapperScreen(
                userId: user?.uid ?? '',
                getNames: (ids) async =>
                    ids, // TODO: Substitua por função real de nomes
                getScore: (duoId) async =>
                    0, // TODO: Substitua por função real de score
              ),
              const SettingsTab(),
            ],
          ),
        );
      },
    );
  }
}
