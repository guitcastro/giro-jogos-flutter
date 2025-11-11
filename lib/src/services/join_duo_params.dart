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
