import 'package:flutter/material.dart';

class PermissinScreen extends StatelessWidget {
  const PermissinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Text(
            // ignore: lines_longer_than_80_chars
            'Включите поверх других приложений чтобы будильник работал корректно',
          ),
          ElevatedButton(
            onPressed: () async {
              //   final bool? res =
              //       await FlutterOverlayWindow.requestPermission();
              //   log("status: $res");
            },
            child: const Text('Открыть настройки'),
          ),
          const Text('Также надо выключить оптимизацию этого приложения '),
        ],
      ),
    );
  }
}
