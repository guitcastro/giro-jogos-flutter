import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../services/auth_service.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Backoffice'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // if (authService.isAuthenticated)
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // await authService.signOut();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Admin Dashboard',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // if (authService.isAuthenticated) ...[
            const Text(
              'Welcome, Admin', // ${authService.currentUser?.email ?? 'Admin'}',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            _buildAdminCard(
              context,
              'Manage Games',
              Icons.sports_esports,
              () {},
            ),
            const SizedBox(height: 10),
            _buildAdminCard(
              context,
              'Manage Users',
              Icons.people,
              () {},
            ),
            const SizedBox(height: 10),
            _buildAdminCard(
              context,
              'Analytics',
              Icons.analytics,
              () {},
            ),
            // ] else ...[
            //   const Text(
            //     'Please sign in to access the admin panel',
            //     style: TextStyle(fontSize: 16),
            //   ),
            //   const SizedBox(height: 20),
            //   ElevatedButton(
            //     onPressed: () {
            //       // Navigate to login screen
            //     },
            //     child: const Text('Sign In'),
            //   ),
            // ],
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 40),
        title: Text(title, style: const TextStyle(fontSize: 18)),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
