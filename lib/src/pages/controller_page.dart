import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/sidebar_drawer.dart';

class ControllerPage extends StatefulWidget {
  const ControllerPage({Key? key}) : super(key: key);

  @override
  _ControllerPageState createState() => _ControllerPageState();
}

class _ControllerPageState extends State<ControllerPage> {
  List<Map<String, dynamic>> controllers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchControllers();
  }

  Future<void> fetchControllers() async {
    setState(() => isLoading = true);
    try {
      final response = await ApiService.get('/api/controllers/list');
      setState(() {
        controllers = List<Map<String, dynamic>>.from(response['data']);
      });
    } catch (e) {
      print('Error fetching controllers: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void showControllerDetailsModal(Map<String, dynamic> controller) {
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
                controller['name'] ?? "",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text("Code: ${controller['code'] ?? "N/A"}"),
              const SizedBox(height: 4),
              Text("Branch: ${controller['branch_name'] ?? "N/A"}"),
              const SizedBox(height: 4),
              Text("Location: ${controller['location_name'] ?? "N/A"}"),
              const SizedBox(height: 4),
              Text("Gateway: ${controller['gateway_name'] ?? "N/A"}"),
              const SizedBox(height: 4),
              Text("Created By: ${controller['created_by'] ?? "N/A"}"),
              const SizedBox(height: 4),
              Text("Created At: ${controller['created_at'] ?? "N/A"}"),
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
        title: const Text("Controllers"),
      ),
      drawer: const SidebarDrawer(currentRoute: "/controller"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            const SizedBox(height: 8),
            isLoading
              ? const Center(child: CircularProgressIndicator())
              : controllers.isEmpty
              ? const Center(child: Text("No controllers available."))
              : Expanded (child: ListView.builder(
                itemCount: controllers.length,
                itemBuilder: (context, index) {
                final controller = controllers[index];
                return Card(
                  child: ListTile(
                  title: Text(controller['name'] ?? ""),
                  subtitle: Text("Branch: ${controller['branch_name'] ?? "N/A"}"),
                  trailing: Text("Code: ${controller['code']}"),
                  onTap: () => showControllerDetailsModal(controller),
                ),
              );
            },
            )
          ),
        ])
      ),
    );
  }
}
