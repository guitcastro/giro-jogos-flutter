import 'dart:async';
import 'package:giro_jogos/src/services/terms_service.dart';

class FakeTermsService implements TermsService {
  final bool acceptedInitially;
  final Map<String, Map<String, TermsAcceptance>> _store = {};
  final Map<String, StreamController<TermsAcceptance?>> _controllers = {};

  FakeTermsService({this.acceptedInitially = true});

  @override
  Stream<TermsAcceptance?> termsStream(
    String uid, {
    String year = TermsService.termsYear,
  }) {
    final key = '$uid:$year';
    _controllers.putIfAbsent(
        key, () => StreamController<TermsAcceptance?>.broadcast());
    final controller = _controllers[key]!;

    // Seed initial state if requested
    if (acceptedInitially && !(_store[uid]?.containsKey(year) ?? false)) {
      final acceptance = TermsAcceptance(
        year: year,
        name: 'Teste',
        document: 'Doc',
        emergencyName: 'Contato',
        emergencyPhone: '0000',
        acceptedAt: DateTime.now(),
      );
      _store.putIfAbsent(uid, () => {});
      _store[uid]![year] = acceptance;
    }

    // Emit current value immediately if present.
    final current = _store[uid]?[year];
    scheduleMicrotask(() {
      if (!controller.isClosed) {
        controller.add(current);
      }
    });
    return controller.stream;
  }

  @override
  Future<bool> hasAccepted(String uid,
      {String year = TermsService.termsYear}) async {
    return _store[uid]?.containsKey(year) ?? false;
  }

  @override
  Future<void> acceptTerms({
    required String uid,
    required String name,
    required String document,
    required String emergencyName,
    required String emergencyPhone,
    String year = TermsService.termsYear,
  }) async {
    final acceptance = TermsAcceptance(
      year: year,
      name: name,
      document: document,
      emergencyName: emergencyName,
      emergencyPhone: emergencyPhone,
      acceptedAt: DateTime.now(),
    );
    _store.putIfAbsent(uid, () => {});
    _store[uid]![year] = acceptance;

    final key = '$uid:$year';
    if (_controllers.containsKey(key) && !_controllers[key]!.isClosed) {
      _controllers[key]!.add(acceptance);
    }
  }

  void dispose() {
    for (final controller in _controllers.values) {
      controller.close();
    }
    _controllers.clear();
  }
}
