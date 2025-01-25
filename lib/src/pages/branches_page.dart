import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../widgets/sidebar_drawer.dart';

class BranchesPage extends StatefulWidget {
  const BranchesPage({Key? key}) : super(key: key);

  @override
  _BranchesPageState createState() => _BranchesPageState();
}

class _BranchesPageState extends State<BranchesPage> {
  List<Map<String, dynamic>> branches = [];
  bool isLoadingBranches = true;

  @override
  void initState() {
    super.initState();
    fetchBranches();
  }

  Future<void> fetchBranches() async {
    setState(() => isLoadingBranches = true);
    try {
      final userDetails = await AuthService.getUserDetails();
      final response = await ApiService.post(
        '/api/branches/list',
        {"company_id": int.parse(userDetails['companyId']!)},
      );
      setState(() {
        branches = List<Map<String, dynamic>>.from(response['data']);
      });
    } catch (e) {
      print('Error fetching branches: $e');
    } finally {
      setState(() => isLoadingBranches = false);
    }
  }

  void showBranchDetailsModal(Map<String, dynamic> branch) {
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
                branch['name'] ?? "",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text("Address: ${branch['address'] ?? "N/A"}"),
              const SizedBox(height: 4),
              Text("Contact Person: ${branch['contact_person_name'] ?? "N/A"}"),
              const SizedBox(height: 4),
              Text("Contact Mobile: ${branch['contact_person_mobile_no'] ?? "N/A"}"),
              const SizedBox(height: 4),
              Text("Created At: ${branch['created_at'] ?? "N/A"}"),
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
        title: const Text("Branches"),
      ),
      drawer: const SidebarDrawer(currentRoute: "/branches"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // const Text(
            //   "Branches",
            //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            // ),
            const SizedBox(height: 8),
            isLoadingBranches
                ? const Center(child: CircularProgressIndicator())
                : branches.isEmpty
                ? const Text("No branches available.")
                : Expanded(
              child: ListView.builder(
                itemCount: branches.length,
                itemBuilder: (context, index) {
                  final branch = branches[index];
                  return Card(
                    child: ListTile(
                      title: Text(branch['name'] ?? ""),
                      subtitle: Text(branch['address'] ?? ""),
                      // trailing: const Icon(Icons.more_vert),
                      onTap: () => showBranchDetailsModal(branch),
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
