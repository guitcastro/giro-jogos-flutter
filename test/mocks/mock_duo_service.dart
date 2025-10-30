import 'package:mockito/mockito.dart';
import 'package:giro_jogos/src/services/duo_service.dart';
import 'package:giro_jogos/src/models/duo.dart';

class MockDuoService extends Mock implements DuoService {
  @override
  Stream<Duo?> getUserDuoStream(String userId) {
    return Stream<Duo?>.value(null);
  }
}
