import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:senzsafe/src/services/auth_service.dart';
import '../services/api_service.dart';
import '../widgets/sidebar_drawer.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({Key? key}) : super(key: key);

  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  List<Map<String, dynamic>> roles = [];
  List<Map<String, dynamic>> branches = [];
  List<Map<String, dynamic>> users = [];

  int? selectedRoleId;
  int? selectedBranchId;
  bool isBranchDropdownVisible = false;
  bool isLoadingRoles = true;
  bool isLoadingBranches = false;
  bool isLoadingUsers = false;

  @override
  void initState() {
    super.initState();
    fetchRoles();
  }

  Future<void> fetchRoles() async {
    setState(() => isLoadingRoles = true);
    try {
      final userDetails = await AuthService.getUserDetails();
      final response = await ApiService.get('/api/admin/users/roles?=${userDetails['roleId']}');
      setState(() {
        roles = List<Map<String, dynamic>>.from(response['data']);
      });
    } catch (e) {
      print('Error fetching roles: $e');
    } finally {
      setState(() => isLoadingRoles = false);
    }
  }

  Future<void> fetchBranches() async {
    setState(() => isLoadingBranches = true);
    try {
      final userDetails = await AuthService.getUserDetails();
      final response = await ApiService.get('/api/sensor-mapping/branches-list/${userDetails['companyId']}');
      setState(() {
        branches = List<Map<String, dynamic>>.from(response['data']);
      });
    } catch (e) {
      print('Error fetching branches: $e');
    } finally {
      setState(() => isLoadingBranches = false);
    }
  }

  Future<void> fetchUsers({required int roleId, int? branchId}) async {
    setState(() => isLoadingUsers = true);
    try {
      String endpoint = '/api/admin/users/list?role=$roleId';
      if (branchId != null) {
        endpoint += '&branch=$branchId';
      }
      final response = await ApiService.get(endpoint);
      setState(() {
        users = List<Map<String, dynamic>>.from(response['data']);
      });
    } catch (e) {
      print('Error fetching users: $e');
    } finally {
      setState(() => isLoadingUsers = false);
    }
  }

  void showUserDetailsModal(Map<String, dynamic> user) {
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
                user['name'] ?? "",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text("Email: ${user['email'] ?? "N/A"}"),
              const SizedBox(height: 4),
              Text("Mobile: ${user['mobile_no'] ?? "N/A"}"),
              const SizedBox(height: 4),
              Text("Role: ${user['role'] ?? "N/A"}"),
              const SizedBox(height: 4),
              Text("Company: ${user['company_name'] ?? "N/A"}"),
              if (user['branch_name'] != null)
                const SizedBox(height: 4),
              if (user['branch_name'] != null)
                Text("Branch: ${user['branch_name']}"),
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
        title: const Text("Users"),
      ),
      drawer: const SidebarDrawer(currentRoute: "/users"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select Role",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            isLoadingRoles
                ? const CircularProgressIndicator()
                : DropdownSearch<Map<String, dynamic>>(
              items: roles,
              dropdownDecoratorProps: const DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Select a role",
                ),
              ),
              itemAsString: (role) => role['name'],
              onChanged: (role) async {
                if (role != null) {
                  setState(() {
                    selectedRoleId = role['id'];
                    isBranchDropdownVisible =
                        role['name'].contains("Branch");
                    users = [];
                    branches = [];
                  });
                  if (isBranchDropdownVisible) {
                    await fetchBranches();
                  }
                  await fetchUsers(roleId: role['id']);
                }
              },
            ),
            if (isBranchDropdownVisible) ...[
              const SizedBox(height: 16),
              const Text(
                "Select Branch",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              isLoadingBranches
                  ? const CircularProgressIndicator()
                  : DropdownSearch<Map<String, dynamic>>(
                items: branches,
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Select a branch",
                  ),
                ),
                itemAsString: (branch) => branch['name'],
                onChanged: (branch) async {
                  if (branch != null) {
                    setState(() {
                      selectedBranchId = branch['id'];
                    });
                    await fetchUsers(
                      roleId: selectedRoleId!,
                      branchId: branch['id'],
                    );
                  }
                },
              ),
            ],
            const SizedBox(height: 16),
            if (users.isNotEmpty) ...[
              const Text(
                "Users",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
            ],
            // if ((selectedRoleId != null || selectedBranchId != null) && users.isEmpty && !isLoadingUsers)
            //   const Text("No users available."),
            isLoadingUsers
                ? const CircularProgressIndicator()
                : users.isEmpty
                ? const SizedBox.shrink()
                : Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Card(
                    child: ListTile(
                      title: Text(user['name'] ?? ""),
                      subtitle: Text(user['email'] ?? ""),
                      trailing: Text(user['role'] ?? ""),
                      onTap: () => showUserDetailsModal(user),
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
