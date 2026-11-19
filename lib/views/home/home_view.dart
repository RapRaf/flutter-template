import 'package:flutter/material.dart';
import 'package:flutter_template/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IconButton(
        tooltip: 'Show snackbar',
        onPressed: () {
          context.read<AuthProvider>().showSnackBar('Snackbar works');
        },
        icon: const Icon(Icons.notifications),
      ),
    );
  }
}
