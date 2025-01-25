import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/sidebar_drawer.dart';

class LoopsPage extends StatefulWidget {
  const LoopsPage({Key? key}) : super(key: key);

  @override
  _LoopsPageState createState() => _LoopsPageState();
}

class _LoopsPageState extends State<LoopsPage> {
  List<Map<String, dynamic>> loops = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchLoops();
  }

  Future<void> fetchLoops() async {
    setState(() => isLoading = true);
    try {
      final response = await ApiService.get('/api/admin/loops/list');
      setState(() {
        loops = List<Map<String, dynamic>>.from(response['data']);
      });
    } catch (e) {
      print('Error fetching loops: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void showLoopDetailsModal(Map<String, dynamic> loop) {
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
                loop['name'] ?? "",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text("Panel: ${loop['panel_name'] ?? "N/A"}"),
              const SizedBox(height: 4),
              Text("Created By: ${loop['created_by'] ?? "N/A"}"),
              const SizedBox(height: 4),
              Text("Created At: ${loop['created_at'] ?? "N/A"}"),
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
        title: const Text("Loops"),
      ),
      drawer: const SidebarDrawer(currentRoute: "/loops"),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 8),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : loops.isEmpty
                    ? const Center(child: Text("No loops available."))
                    : Expanded(
                        child: ListView.builder(
                          itemCount: loops.length,
                          itemBuilder: (context, index) {
                            final loop = loops[index];
                            return Card(
                              child: ListTile(
                                title: Text(loop['name'] ?? ""),
                                subtitle: Text(
                                    "Panel: ${loop['panel_name'] ?? "N/A"}"),
                                // trailing: const Icon(Icons.more_vert),
                                onTap: () => showLoopDetailsModal(loop),
                              ),
                            );
                          },
                        ),
                      )
          ])),
    );
  }
}
