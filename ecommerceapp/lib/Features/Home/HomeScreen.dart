// home screen for the app
import 'package:ecommerceapp/Features/auth/Presentation/cubits/authCubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(onPressed: () {
            context.read<AuthCubit>().logout();
          }, icon: Icon(Icons.logout)),
        ],
      ),
    );
  }
}