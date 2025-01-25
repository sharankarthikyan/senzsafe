import 'package:flutter/material.dart';

class SensorTypes extends StatelessWidget {
  final List<dynamic>? sensorCountByType;

  const SensorTypes({Key? key, this.sensorCountByType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Sensor Types",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            itemCount: sensorCountByType?.length ?? 0,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              final sensor = sensorCountByType![index];
              return SensorCard(
                icon: _getSensorIcon(sensor['type']),
                label: sensor['type'] ?? "Unknown",
                count: sensor['count'] ?? 0,
                iconColor: _getSensorColor(sensor['type']),
              );
            },
          ),
        ],
      ),
    );
  }

  IconData _getSensorIcon(String type) {
    switch (type) {
      case "Gas Detectors":
        return Icons.air;
      case "Fire":
        return Icons.local_fire_department;
      case "Smoke":
        return Icons.cloud;
      case "Sprinklers":
        return Icons.shower;
      default:
        return Icons.device_unknown;
    }
  }

  Color _getSensorColor(String type) {
    switch (type) {
      case "Gas Detectors":
        return Colors.blue;
      case "Fire":
        return Colors.red;
      case "Smoke":
        return Colors.grey;
      case "Sprinklers":
        return Colors.blueAccent;
      default:
        return Colors.black;
    }
  }
}

class SensorCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color iconColor;

  const SensorCard({
    required this.icon,
    required this.label,
    required this.count,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 36,
            color: iconColor,
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 4),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}