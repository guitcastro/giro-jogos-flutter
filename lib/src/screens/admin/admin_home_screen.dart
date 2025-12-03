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
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import 'submissions_screen.dart';
import 'score_screen.dart';
import '../../services/challenge_service.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _currentIndex = 0;
  late final ChallengeService _challengeService = ChallengeService();

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;
    final pages = <Widget>[
      const SubmissionsScreen(),
      ScoreScreen(
        service: _challengeService,
        isAdmin: authService.isAdmin,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel Admin'),
        actions: [
          PopupMenuButton<String>(
            icon: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                (user?.displayName?.isNotEmpty ?? false)
                    ? user!.displayName![0].toUpperCase()
                    : (user?.email?.isNotEmpty ?? false)
                        ? user!.email![0].toUpperCase()
                        : 'A',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
            onSelected: (value) async {
              if (value == 'logout') {
                await authService.signOut();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'logout',
                child: Text('Sair'),
              ),
            ],
          ),
        ],
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Symbols.list_alt),
            label: 'Submissões',
          ),
          BottomNavigationBarItem(
            icon: Icon(Symbols.leaderboard),
            label: 'Pontuação',
          ),
        ],
      ),
    );
  }
}
