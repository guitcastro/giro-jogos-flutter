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
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        final user = authService.currentUser;

        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Seção do perfil do usuário
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Perfil',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: user?.photoURL != null
                              ? NetworkImage(user!.photoURL!)
                              : null,
                          child: user?.photoURL == null
                              ? Text(
                                  user?.displayName?.isNotEmpty == true
                                      ? user!.displayName![0].toUpperCase()
                                      : user?.email?.isNotEmpty == true
                                          ? user!.email![0].toUpperCase()
                                          : 'U',
                                  style: const TextStyle(fontSize: 24),
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.displayName ?? 'Nome não informado',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (user?.email != null)
                                Text(
                                  user!.email!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            _showEditProfileDialog(context);
                          },
                          icon: const Icon(Icons.edit),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Seção de configurações gerais
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Configurações Gerais',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSettingsItem(
                      icon: Icons.notifications,
                      title: 'Notificações',
                      subtitle: 'Gerencie suas notificações',
                      onTap: () {
                        _showComingSoonDialog(context, 'Notificações');
                      },
                    ),
                    const Divider(),
                    _buildSettingsItem(
                      icon: Icons.privacy_tip,
                      title: 'Privacidade',
                      subtitle: 'Configurações de privacidade',
                      onTap: () {
                        _showComingSoonDialog(context, 'Privacidade');
                      },
                    ),
                    const Divider(),
                    _buildSettingsItem(
                      icon: Icons.language,
                      title: 'Idioma',
                      subtitle: 'Português (BR)',
                      onTap: () {
                        _showComingSoonDialog(context, 'Idioma');
                      },
                    ),
                    const Divider(),
                    _buildSettingsItem(
                      icon: Icons.dark_mode,
                      title: 'Tema',
                      subtitle: 'Claro/Escuro',
                      onTap: () {
                        _showComingSoonDialog(context, 'Tema');
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Seção de gaming
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gaming',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSettingsItem(
                      icon: Icons.games,
                      title: 'Jogos Favoritos',
                      subtitle: 'Configure seus jogos preferidos',
                      onTap: () {
                        _showComingSoonDialog(context, 'Jogos Favoritos');
                      },
                    ),
                    const Divider(),
                    _buildSettingsItem(
                      icon: Icons.leaderboard,
                      title: 'Ranking',
                      subtitle: 'Veja suas estatísticas',
                      onTap: () {
                        _showComingSoonDialog(context, 'Ranking');
                      },
                    ),
                    const Divider(),
                    _buildSettingsItem(
                      icon: Icons.history,
                      title: 'Histórico de Partidas',
                      subtitle: 'Suas partidas anteriores',
                      onTap: () {
                        _showComingSoonDialog(context, 'Histórico de Partidas');
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Seção de suporte
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Suporte',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSettingsItem(
                      icon: Icons.help,
                      title: 'Central de Ajuda',
                      subtitle: 'FAQ e tutoriais',
                      onTap: () {
                        _showComingSoonDialog(context, 'Central de Ajuda');
                      },
                    ),
                    const Divider(),
                    _buildSettingsItem(
                      icon: Icons.feedback,
                      title: 'Enviar Feedback',
                      subtitle: 'Conte-nos sua opinião',
                      onTap: () {
                        _showComingSoonDialog(context, 'Enviar Feedback');
                      },
                    ),
                    const Divider(),
                    _buildSettingsItem(
                      icon: Icons.info,
                      title: 'Sobre o App',
                      subtitle: 'Versão e informações',
                      onTap: () {
                        _showAboutDialog(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Botão de logout
            Card(
              color: Colors.red.shade50,
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Sair da Conta',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  _showLogoutDialog(context, authService);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar Perfil'),
          content: const Text(
            'A funcionalidade de edição de perfil estará disponível em breve!\n\nVocê poderá alterar seu nome, foto de perfil e outras informações pessoais.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(feature),
          content: const Text(
            'Esta funcionalidade estará disponível em breve!\n\nEstamos trabalhando para trazer a melhor experiência para você.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sobre o Giro Jogos'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Giro Jogos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text('Versão: 1.0.0'),
              SizedBox(height: 8),
              Text(
                'A plataforma definitiva para gamers encontrarem seus parceiros de jogo e formarem equipes incríveis.',
              ),
              SizedBox(height: 16),
              Text(
                'Desenvolvido com ❤️ usando Flutter',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context, AuthService authService) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sair da Conta'),
          content: const Text('Tem certeza que deseja sair da sua conta?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await authService.signOut();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Sair'),
            ),
          ],
        );
      },
    );
  }
}
