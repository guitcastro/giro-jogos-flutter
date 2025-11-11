/*
 * This file is part of Giro Jogos.
 * 
 * Giro Jogos is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * Giro Jogos is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Affero General Public License for more details.
 * 
 * You should have received a copy of the GNU Affero General Public License
 * along with Giro Jogos. If not, see <https://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/join_duo_params.dart';
import 'duo_wrapper_screen.dart';
import 'settings_tab.dart';
import '../challenge/challenge_screen.dart';

import '../../services/duo_service.dart';

class HomeScreen extends StatefulWidget {
  final DuoService? duoService;
  const HomeScreen({super.key, this.duoService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authService = Provider.of<AuthService>(context, listen: false);
    final joinParams = Provider.of<JoinDuoParams>(context, listen: false);
    if (!authService.isAuthenticated) {
      return;
    }
    if (!joinParams.hasParams) {}
  }

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
          const ChallengeScreen(),
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
                icon: Icon(Icons.flag),
                label: 'Desafios',
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
