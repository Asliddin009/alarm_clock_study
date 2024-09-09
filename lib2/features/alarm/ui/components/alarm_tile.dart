import 'package:flutter/material.dart';

class AlarmTile extends StatelessWidget {
  const AlarmTile({required this.time, required this.isEnabled, super.key});
  final String time;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Colors.grey,
      title: Row(
        children: [
          Text(time),
          const SizedBox(width: 5),
          Chip(
            padding: EdgeInsets.zero,
            label: Text(
              'dsadas',
              style: TextStyle(
                color: isEnabled ? Colors.black : Colors.white,
                fontSize: 10,
              ),
            ),
            backgroundColor: isEnabled ? Colors.greenAccent : Colors.redAccent,
          ),
        ],
      ),
      trailing: IconButton(
        onPressed: () async {
          // await AlarmService.instance.deleteAlarm(alarm.id!);
          // reloadAlarms();
        },
        icon: const Icon(Icons.delete, color: Colors.red),
      ),
    );
  }
}
