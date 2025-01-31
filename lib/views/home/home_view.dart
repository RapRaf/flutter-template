import 'package:flutter/material.dart';
import 'package:flutter_template/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: IconButton(
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false)
                  .showSnackBar('Snackbar works');
            },
            icon: const Icon(Icons.logout)));
  }
}
