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
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/terms_service.dart';
import 'terms_screen.dart';

class TermsWrapper extends StatelessWidget {
  final Widget child;
  const TermsWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    if (auth.isAuthLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (!auth.isAuthenticated || auth.currentUser == null) {
      // AuthWrapper should handle redirect; we just guard here.
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final uid = auth.currentUser!.uid;
    final termsService = Provider.of<TermsService?>(context, listen: false);
    if (termsService == null) {
      // If TermsService is not provided (e.g., in tests), skip gating.
      return child;
    }

    return StreamBuilder<TermsAcceptance?>(
      stream: termsService.termsStream(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final hasAccepted = snapshot.hasData && snapshot.data != null;
        if (hasAccepted) {
          return child;
        }

        // Block the app with the TermsScreen until accepted
        return TermsScreen(userId: uid);
      },
    );
  }
}
