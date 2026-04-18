import 'package:flutter/material.dart';

class HostGame extends StatefulWidget {
  const HostGame({super.key});

  @override
  State<HostGame> createState() => _HostGameState();
}

class _HostGameState extends State<HostGame> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Host Game')),
      body: const Center(child: Text('Host Game')),
    );
  }
}
