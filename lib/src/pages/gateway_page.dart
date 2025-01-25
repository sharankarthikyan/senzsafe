import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/sidebar_drawer.dart';

class GatewayPage extends StatefulWidget {
  const GatewayPage({Key? key}) : super(key: key);

  @override
  _GatewayPageState createState() => _GatewayPageState();
}

class _GatewayPageState extends State<GatewayPage> {
  List<Map<String, dynamic>> gateways = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchGateways();
  }

  Future<void> fetchGateways() async {
    setState(() => isLoading = true);
    try {
      final response = await ApiService.get('/api/gateway/list');
      setState(() {
        gateways = List<Map<String, dynamic>>.from(response['data']);
      });
    } catch (e) {
      print('Error fetching gateways: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void showGatewayDetailsModal(Map<String, dynamic> gateway) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                gateway['gateway_name'] ?? "",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text("Brand: ${gateway['brand_name'] ?? "N/A"}"),
              const SizedBox(height: 4),
              Text("Model: ${gateway['model_name'] ?? "N/A"}"),
              const SizedBox(height: 4),
              Text("Serial Number: ${gateway['serial_number'] ?? "N/A"}"),
              const SizedBox(height: 4),
              Text("MAC Address: ${gateway['mac_address'] ?? "N/A"}"),
              const SizedBox(height: 4),
              Text("Branch: ${gateway['branch_name'] ?? "N/A"}"),
              const SizedBox(height: 4),
              Text("Company: ${gateway['company_name'] ?? "N/A"}"),
              const SizedBox(height: 4),
              Text("Notify Seconds: ${gateway['notify_seconds'] ?? "N/A"}"),
              const SizedBox(height: 4),
              Text("Inactive Frequency: ${gateway['inactive_status_frequency_seconds'] ?? "N/A"}"),
              const SizedBox(height: 4),
              Text("Created At: ${gateway['created_at'] ?? "N/A"}"),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Close"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gateways"),
      ),
      drawer: const SidebarDrawer(currentRoute: "/gateway"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // const Text(
            //   "Gateways",
            //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            // ),
            const SizedBox(height: 8),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : gateways.isEmpty
                ? const Text("No gateways available.")
                : Expanded(
              child: ListView.builder(
                itemCount: gateways.length,
                itemBuilder: (context, index) {
                  final gateway = gateways[index];
                  return Card(
                    child: ListTile(
                      title: Text(gateway['gateway_name'] ?? ""),
                      subtitle: Text("Serial: ${gateway['serial_number'] ?? "N/A"}"),
                      // trailing: const Icon(Icons.more_vert),
                      onTap: () => showGatewayDetailsModal(gateway),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
