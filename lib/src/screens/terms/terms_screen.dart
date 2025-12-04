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
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../widgets/app_icon.dart';
import '../../services/terms_service.dart';

class BrazilianPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (text.isEmpty) return newValue.copyWith(text: '');

    final buffer = StringBuffer();
    if (text.isNotEmpty) {
      buffer.write('(');
      buffer.write(text.substring(0, text.length >= 2 ? 2 : text.length));
    }
    if (text.length >= 3) {
      buffer.write(') ');
      if (text.length <= 10) {
        // Formato: (XX) XXXX-XXXX
        buffer.write(text.substring(2, text.length >= 6 ? 6 : text.length));
        if (text.length >= 7) {
          buffer.write('-');
          buffer.write(text.substring(6, text.length >= 10 ? 10 : text.length));
        }
      } else {
        // Formato: (XX) XXXXX-XXXX
        buffer.write(text.substring(2, text.length >= 7 ? 7 : text.length));
        if (text.length >= 8) {
          buffer.write('-');
          buffer.write(text.substring(7, text.length >= 11 ? 11 : text.length));
        }
      }
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class TermsScreen extends StatefulWidget {
  final String userId;
  const TermsScreen({super.key, required this.userId});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _documentController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  bool _isSubmitting = false;

  String _formatDatePtBr(DateTime dt) {
    const months = [
      'janeiro',
      'fevereiro',
      'março',
      'abril',
      'maio',
      'junho',
      'julho',
      'agosto',
      'setembro',
      'outubro',
      'novembro',
      'dezembro',
    ];
    final day = dt.day.toString().padLeft(2, '0');
    final month = months[dt.month - 1];
    return '$day de $month de ${dt.year}';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _documentController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final termsService = Provider.of<TermsService>(context, listen: false);
      await termsService.acceptTerms(
        uid: widget.userId,
        name: _nameController.text.trim(),
        document: _documentController.text.trim(),
        emergencyName: _emergencyNameController.text.trim(),
        emergencyPhone: _emergencyPhoneController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Termos aceitos com sucesso.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro ao salvar os termos. Tente novamente.\n$e',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final todayStr = _formatDatePtBr(DateTime.now());
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon(size: 24),
            SizedBox(width: 8),
            Text('Giro Jogos'),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Termo de Responsabilidade e Acordo de Implicação de Risco - Giro Jogos 2025',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Belo Horizonte 2025',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Eu, abaixo identificado(a), no perfeito uso de minhas faculdades e de livre espontânea vontade, sendo maior de idade e capaz, DECLARO para os devidos fins de direito que:\n\n'
                      'Minha inscrição para o Giro Jogos 2025 é por livre e espontânea vontade nesta data, na qualidade de participante;\n\n'
                      'Assumo o compromisso de não participar do pedal se estiver medicamente incapacitado(a), mal treinado(a) ou indisposto(a), sob efeito do uso de drogas lícitas e/ou ilícitas, assumindo, como de minha inteira responsabilidade, todos os riscos associados a este evento, inclusive, mas não somente, os riscos decorrentes de mau tempo, quedas, acidentes e contato com outros ciclistas, voluntários ou espectadores;\n\n'
                      'Como participante do Giro Jogos 2025, comprometo-me a respeitar a legislação vigente, seja ela municipal, estadual ou federal, assumindo toda e qualquer consequência de meus atos no período de duração da atividade, bem como os atos individuais que antecedem e sucedem e que possam se relacionar com as atividades do Giro Jogos 2025 no percurso;\n\n'
                      'Isento a organização, colaboradores e patrocinadores de qualquer responsabilidade civil ou criminal por acidentes, danos ou prejuízos decorrentes da minha participação;\n\n'
                      'A pessoa indicada no contato de emergência indicado está ciente da minha participação no Giro Jogo 2025, não está inscrita como participante do do Giro Jogos 2025 e está disponível para ser acionada caso seja necessário;\n\n'
                      'USO DA IMAGEM: Autorizo o uso e divulgação de minha imagem e voz, seja através de fotos, filmes e entrevistas para veiculação em rádios, jornais, revistas, televisão, internet, e demais mídias para fins informativos, promocionais ou publicitários, sem acarretar ônus à organização, patrocinadores ou aos próprios meios de veiculação.\n\n'
                      'Belo Horizonte - MG, $todayStr.',
                    ),
                    const SizedBox(height: 24),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Seu nome completo',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Informe o nome'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _documentController,
                            decoration: const InputDecoration(
                              labelText: 'Documento',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Informe o documento'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Contato de Emergência',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _emergencyNameController,
                            decoration: const InputDecoration(
                              labelText: 'Nome',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Informe o nome do contato de emergência'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _emergencyPhoneController,
                            decoration: const InputDecoration(
                              labelText: 'Telefone',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.phone,
                            inputFormatters: [BrazilianPhoneFormatter()],
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Informe o telefone do contato de emergência'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isSubmitting ? null : _submit,
                              child: _isSubmitting
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : const Text('Aceitar Termos'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
