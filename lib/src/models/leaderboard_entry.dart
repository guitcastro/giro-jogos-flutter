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

class LeaderboardEntry {
  final String duoId;
  final String duoName;
  final List<String> members;
  final int totalPoints;
  final DateTime updatedAt;

  const LeaderboardEntry({
    required this.duoId,
    required this.duoName,
    required this.members,
    required this.totalPoints,
    required this.updatedAt,
  });
}
