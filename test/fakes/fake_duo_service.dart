import 'package:mockito/mockito.dart';
import 'package:giro_jogos/src/services/duo_service.dart';
import 'package:giro_jogos/src/models/duo.dart';

class FakeDuoService extends Mock implements DuoService {
  @override
  Stream<Duo?> getUserDuoStream() {
    return Stream<Duo?>.value(null);
  }

  @override
  Future<void> deleteDuo(String duoId) async {
    // Dummy: não faz nada
    return;
  }
}
