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
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            _showEditProfileDialog(context);
                          },
                          icon: const Icon(Symbols.edit),
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
                      icon: Symbols.notifications,
                      title: 'Notificações',
                      subtitle: 'Gerencie suas notificações',
                      onTap: () {
                        _showComingSoonDialog(context, 'Notificações');
                      },
                    ),
                    const Divider(),
                    _buildSettingsItem(
                      icon: Symbols.privacy_tip,
                      title: 'Privacidade',
                      subtitle: 'Configurações de privacidade',
                      onTap: () {
                        _showComingSoonDialog(context, 'Privacidade');
                      },
                    ),
                    const Divider(),
                    _buildSettingsItem(
                      icon: Symbols.language,
                      title: 'Idioma',
                      subtitle: 'Português (BR)',
                      onTap: () {
                        _showComingSoonDialog(context, 'Idioma');
                      },
                    ),
                    const Divider(),
                    _buildSettingsItem(
                      icon: Symbols.dark_mode,
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
                      icon: Symbols.help,
                      title: 'Central de Ajuda',
                      subtitle: 'FAQ e tutoriais',
                      onTap: () {
                        _showComingSoonDialog(context, 'Central de Ajuda');
                      },
                    ),
                    const Divider(),
                    _buildSettingsItem(
                      icon: Symbols.feedback,
                      title: 'Enviar Feedback',
                      subtitle: 'Conte-nos sua opinião',
                      onTap: () {
                        _showComingSoonDialog(context, 'Enviar Feedback');
                      },
                    ),
                    const Divider(),
                    _buildSettingsItem(
                      icon: Symbols.info,
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
              color: Theme.of(context).colorScheme.errorContainer,
              child: ListTile(
                leading: Icon(Symbols.logout,
                    color: Theme.of(context).colorScheme.error),
                title: Text(
                  'Sair da Conta',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
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
      trailing: const Icon(Symbols.arrow_forward_ios, size: 16),
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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Giro Jogos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text('Versão: 1.0.0'),
              const SizedBox(height: 8),
              const Text(
                'A plataforma definitiva para gamers encontrarem seus parceiros de jogo e formarem equipes incríveis.',
              ),
              const SizedBox(height: 16),
              Text(
                'Desenvolvido com ❤️ usando Flutter',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Sair'),
            ),
          ],
        );
      },
    );
  }
}
