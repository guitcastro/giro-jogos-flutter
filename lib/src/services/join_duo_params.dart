import 'package:flutter/foundation.dart';

class JoinDuoParams extends ChangeNotifier {
  String? duoId;
  String? inviteCode;

  void setParams(String duoId, String inviteCode) {
    this.duoId = duoId;
    this.inviteCode = inviteCode;
    notifyListeners();
  }

  void clear() {
    duoId = null;
    inviteCode = null;
    notifyListeners();
  }

  bool get hasParams => duoId != null && inviteCode != null;
}
