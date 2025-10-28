import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

class DuoTab extends StatelessWidget {
  const DuoTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        final user = authService.currentUser;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho de boas-vindas
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
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
                                style: const TextStyle(fontSize: 20),
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Olá, ${user?.displayName ?? user?.email?.split('@')[0] ?? 'Usuário'}!',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'Encontre seu parceiro de jogo',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Seção de ações principais
              const Text(
                'Duo & Equipe',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Cards de ações
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: [
                    _buildActionCard(
                      context,
                      icon: Icons.person_add,
                      title: 'Encontrar Duo',
                      subtitle: 'Busque um parceiro de jogo',
                      color: Colors.blue,
                      onTap: () {
                        _showComingSoonDialog(context, 'Encontrar Duo');
                      },
                    ),
                    _buildActionCard(
                      context,
                      icon: Icons.group_add,
                      title: 'Criar Equipe',
                      subtitle: 'Monte sua própria equipe',
                      color: Colors.green,
                      onTap: () {
                        _showComingSoonDialog(context, 'Criar Equipe');
                      },
                    ),
                    _buildActionCard(
                      context,
                      icon: Icons.search,
                      title: 'Buscar Equipe',
                      subtitle: 'Encontre equipes para entrar',
                      color: Colors.orange,
                      onTap: () {
                        _showComingSoonDialog(context, 'Buscar Equipe');
                      },
                    ),
                    _buildActionCard(
                      context,
                      icon: Icons.schedule,
                      title: 'Partidas Agendadas',
                      subtitle: 'Veja seus próximos jogos',
                      color: Colors.purple,
                      onTap: () {
                        _showComingSoonDialog(context, 'Partidas Agendadas');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(feature),
          content: const Text(
            'Esta funcionalidade estará disponível em breve!\n\nEstamos trabalhando para trazer a melhor experiência de formação de equipes e duos para você.',
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
}
