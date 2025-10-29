import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/duo_service.dart';
import '../../models/duo.dart';

class DuoTab extends StatefulWidget {
  final DuoService? duoService;
  const DuoTab({super.key, this.duoService});

  @override
  State<DuoTab> createState() => _DuoTabState();
}

class _DuoTabState extends State<DuoTab> {
  DuoService? _duoService;
  List<Duo> _userDuos = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // _duoService será inicializado em didChangeDependencies para garantir acesso ao Provider
  }

  bool _didLoadUserDuos = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _duoService ??=
        widget.duoService ?? Provider.of<DuoService>(context, listen: false);
    if (!_didLoadUserDuos) {
      _didLoadUserDuos = true;
      _loadUserDuos();
    }
  }

  Future<void> _loadUserDuos() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    if (user == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final duos = await _duoService!.getUserDuos(user.uid);
      setState(() {
        _userDuos = duos;
      });
    } catch (e) {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erro ao carregar duos: $e')),
            );
          }
        });
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        final user = authService.currentUser;

        return RefreshIndicator(
          onRefresh: _loadUserDuos,
          child: Padding(
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
                                'Gerencie seus duos e equipes',
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

                // Seção de duos do usuário
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_userDuos.isNotEmpty) ...[
                  const Text(
                    'Meus Duos',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...(_userDuos
                      .map((duo) => _buildDuoCard(duo, user?.uid ?? ''))),
                  const SizedBox(height: 24),
                ],

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
                        icon: Icons.add,
                        title: 'Criar Duo',
                        subtitle: 'Crie seu próprio duo',
                        color: Colors.blue,
                        onTap: () => _showCreateDuoDialog(context),
                      ),
                      _buildActionCard(
                        context,
                        icon: Icons.group_add,
                        title: 'Entrar em Duo',
                        subtitle: 'Entre em um duo existente',
                        color: Colors.green,
                        onTap: () => _showJoinDuoDialog(context),
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
          ),
        );
      },
    );
  }

  Widget _buildDuoCard(Duo duo, String currentUserId) {
    final isOwner = duo.isOwner(currentUserId);

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isOwner ? Icons.star : Icons.group,
                  color: isOwner ? Colors.amber : Colors.blue,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    duo.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isOwner ? 'Seu duo' : 'Participante',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.people,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  '${duo.totalMembers}/2 membros',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.code,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  'Código: ${duo.inviteCode}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isOwner) ...[
                  TextButton.icon(
                    onPressed: () => _showManageDuoDialog(context, duo),
                    icon: const Icon(Icons.settings, size: 16),
                    label: const Text('Gerenciar'),
                  ),
                ] else ...[
                  TextButton.icon(
                    onPressed: () => _leaveDuo(duo.id),
                    icon: const Icon(Icons.exit_to_app, size: 16),
                    label: const Text('Sair'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
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

  void _showCreateDuoDialog(BuildContext context) {
    final nameController = TextEditingController();
    // Removido: maxParticipantsController
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Criar Novo Duo'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do Duo',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, insira um nome';
                    }
                    if (value.trim().length > 50) {
                      return 'Nome muito longo (máximo 50 caracteres)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  // controller removido
                  decoration: const InputDecoration(
                    labelText: 'Máximo de Participantes',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira um número';
                    }
                    final number = int.tryParse(value);
                    if (number == null || number < 2 || number > 50) {
                      return 'Número deve ser entre 2 e 50';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  Navigator.of(context).pop();
                  await _createDuo(
                    nameController.text.trim(),
                  );
                }
              },
              child: const Text('Criar'),
            ),
          ],
        );
      },
    );
  }

  void _showJoinDuoDialog(BuildContext context) {
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Entrar em Duo'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do Duo',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, insira o nome do duo';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: codeController,
                  decoration: const InputDecoration(
                    labelText: 'Código de Convite',
                    border: OutlineInputBorder(),
                    hintText: 'Ex: ABC123',
                  ),
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, insira o código de convite';
                    }
                    if (value.trim().length != 6) {
                      return 'Código deve ter 6 caracteres';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  Navigator.of(context).pop();
                  await _joinDuo(
                    nameController.text.trim(),
                    codeController.text.trim().toUpperCase(),
                  );
                }
              },
              child: const Text('Entrar'),
            ),
          ],
        );
      },
    );
  }

  void _showManageDuoDialog(BuildContext context, Duo duo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Gerenciar ${duo.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Código de Convite: ${duo.inviteCode}'),
              Text('Membros: ${duo.totalMembers}/2'),
              const SizedBox(height: 16),
              if (duo.participants.isNotEmpty) ...[
                const Text(
                  'Participantes:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...duo.participants.map((participantId) => ListTile(
                      dense: true,
                      title: Text('Usuário: $participantId'),
                      trailing: IconButton(
                        icon:
                            const Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () {
                          Navigator.of(context).pop();
                          _removeParticipant(duo.id, participantId);
                        },
                      ),
                    )),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fechar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showDeleteDuoConfirmation(context, duo);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Deletar Duo'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDuoConfirmation(BuildContext context, Duo duo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Deletar Duo'),
          content: Text('Tem certeza que deseja deletar o duo "${duo.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteDuo(duo.id);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Deletar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _createDuo(String name) async {
    try {
      await _duoService!.createDuo(
        name: name,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Duo criado com sucesso!')),
        );
        _loadUserDuos();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao criar duo: $e')),
        );
      }
    }
  }

  Future<void> _joinDuo(String duoName, String inviteCode) async {
    try {
      await _duoService!.joinDuo(
        duoName: duoName,
        inviteCode: inviteCode,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entrou no duo com sucesso!')),
        );
        _loadUserDuos();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao entrar no duo: $e')),
        );
      }
    }
  }

  Future<void> _leaveDuo(String duoId) async {
    try {
      await _duoService!.leaveDuo(duoId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saiu do duo com sucesso!')),
        );
        _loadUserDuos();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao sair do duo: $e')),
        );
      }
    }
  }

  Future<void> _deleteDuo(String duoId) async {
    try {
      await _duoService!.deleteDuo(duoId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Duo deletado com sucesso!')),
        );
        _loadUserDuos();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao deletar duo: $e')),
        );
      }
    }
  }

  Future<void> _removeParticipant(String duoId, String participantId) async {
    try {
      await _duoService!.removeParticipant(
        duoId: duoId,
        participantId: participantId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Participante removido com sucesso!')),
        );
        _loadUserDuos();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao remover participante: $e')),
        );
      }
    }
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
