import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:senzsafe/src/widgets/closeable_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/socket_service.dart';
import '../services/api_service.dart';
import '../widgets/info_card.dart';
import '../widgets/status_card.dart';
import '../widgets/sensor_types_card.dart';
import '../widgets/sidebar_drawer.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String dashboardEndpoint = '${ApiService.baseUrl}/dashboard';
  String abnormalSensorNotifierEndpoint = '${ApiService.baseUrl}/abnormal-sensor-notifier';
  late Future<List<String>> branches;
  Map<String, dynamic> dashboardData = {};
  List<Marker> branchMarkers = [];
  bool isLoadingDashboard = true; // State to track loading for dashboardData
  List<Map<String, dynamic>> activeAlerts = [];
  Set<int> dismissedAlertIds = {};


  @override
  void initState() {
    super.initState();
    branches = fetchBranches();
    connectToSocket();
    connectToAbnormalSensorNotifier();
    loadDismissedAlerts(); // Load dismissed alerts
  }


  @override
  void dispose() {
    final socketService = SocketService();
    socketService.disconnectAll();
    super.dispose();
  }

  /// Fetch the list of branches
  Future<List<String>> fetchBranches() async {
    try {
      final userDetails = await AuthService.getUserDetails();
      final companyId = userDetails['companyId']!;
      final response = await ApiService.get('/api/admin/dashboard/branch/list/$companyId');
      return List<String>.from(response['data'].map((branch) => branch['name']));
    } catch (e) {
      throw Exception('Failed to fetch branches: $e');
    }
  }

  /// Establish a socket connection
  void connectToSocket() async {
    final socketService = SocketService();
    final userDetails = await AuthService.getUserDetails();
    final roleId = int.parse(userDetails['roleId']!);
    final companyId = int.parse(userDetails['companyId']!);

    socketService.connect(dashboardEndpoint);

    // Emit `getDashboardData`
    socketService.emit(dashboardEndpoint, "getDashboardData", {
      "roleId": roleId,
      "companyId": companyId,
    });

    // Listen for `dashboardData`
    socketService.on(dashboardEndpoint, "dashboardData", (data) {
      setState(() {
        dashboardData = data['data'];

        // Parse branchDetails and create markers
        if (dashboardData.containsKey('branchDetails') &&
            (dashboardData['branchDetails'] as List).isNotEmpty) {
          branchMarkers = (dashboardData['branchDetails'] as List).map((branch) {
            return Marker(
              point: LatLng(
                double.parse(branch['latitude']),
                double.parse(branch['longitude']),
              ),
              builder: (context) => Tooltip(
                message: branch['name'],
                child: const Icon(
                  Icons.location_on,
                  size: 30,
                  color: Colors.red,
                ),
              ),
            );
          }).toList();
        }
        isLoadingDashboard = false; // Data has been loaded
      });
    });
  }

  void connectToAbnormalSensorNotifier() async {
    final socketService = SocketService();
    final userDetails = await AuthService.getUserDetails();
    final companyId = int.parse(userDetails['companyId']!);

    // Connect to abnormal sensor notifier endpoint
    socketService.connect(abnormalSensorNotifierEndpoint);

    // Emit `setAlertCriteria`
    socketService.emit(abnormalSensorNotifierEndpoint, 'setAlertCriteria', {'companyId': companyId});

    // Listen for `alertData` events
    socketService.on(abnormalSensorNotifierEndpoint, 'alertData', (data) {
      if (data['status'] == true && data['data'] is List) {
        final alerts = data['data'] as List;

        setState(() {
          // Filter out dismissed alerts
          activeAlerts = alerts
              .where((alert) => !dismissedAlertIds.contains(alert['sensor_code'].hashCode))
              .cast<Map<String, dynamic>>()
              .toList();
        });
      }
    });
  }

  Future<void> saveDismissedAlerts() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('dismissedAlertIds',
        dismissedAlertIds.map((id) => id.toString()).toList());
  }

  Future<void> loadDismissedAlerts() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIds = prefs.getStringList('dismissedAlertIds') ?? [];
    dismissedAlertIds = savedIds.map((id) => int.parse(id)).toSet();
  }

  Widget buildAlerts() {
    if (activeAlerts.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Alerts",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
        ),
        const SizedBox(height: 8),
        ...activeAlerts.map((alert) {
          return ClosableAlert(
            title: alert['sensor_name'] ?? 'Unknown Sensor',
            subtitle:
            '${alert['location_name']} (${alert['sensor_type']}) - ${alert['message'] ?? ''}',
            onClose: () {
              setState(() {
                dismissedAlertIds.add(alert['sensor_code'].hashCode);
                activeAlerts.remove(alert);
              });
              saveDismissedAlerts(); // Save dismissed alert persistently
            },
          );
        }).toList(),
      ],
    );
  }

  /// Skeleton loader widget
  Widget buildSkeletonLoader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 20,
          width: 150,
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Row(
          children: List.generate(3, (index) {
            return Container(
              height: 100,
              width: 100,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        Container(
          height: 20,
          width: 150,
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: const SidebarDrawer(currentRoute: "/dashboard"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isLoadingDashboard
              ? buildSkeletonLoader() // Show skeleton loader while loading
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildAlerts(),
              const Text(
                "Select Branch",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              FutureBuilder<List<String>>(
                future: branches,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text("No branches available");
                  } else {
                    return DropdownSearch<String>(
                      items: snapshot.data!,
                      dropdownDecoratorProps: const DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Select a branch",
                        ),
                      ),
                      onChanged: (value) {
                        print("Selected branch: $value");
                      },
                    );
                  }
                },
              ),
              const SizedBox(height: 16),

              // Horizontally scrollable InfoCards
              const Text(
                "Information",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    InfoCard(
                      title: "Total Branches",
                      value: dashboardData['branchCount']?.toString() ?? "0",
                      icon: Icons.device_hub,
                      color: 0xFF26A69A,
                    ),
                    const SizedBox(width: 12),
                    InfoCard(
                      title: "Total Locations",
                      value: dashboardData['locationCount']?.toString() ?? "0",
                      icon: Icons.location_on,
                      color: 0xFF8E44AD,
                    ),
                    const SizedBox(width: 12),
                    InfoCard(
                      title: "Sensor Types",
                      value: dashboardData['sensorTypeCount']?.toString() ?? "0",
                      icon: Icons.thermostat,
                      color: 0xFFEB5757,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Status Cards
              StatusCard(
                title: "Controllers",
                totalAvailable: dashboardData['controllerTotalCount']?.toString() ?? "0",
                connectionStatusTotal: dashboardData['controllerTotalCount']?.toString() ?? "0",
                connectionStatusNormal: dashboardData['controllerActiveCount']?.toString() ?? "0",
                connectionStatusAbnormal: dashboardData['controllerInactiveCount']?.toString() ?? "0",
              ),
              StatusCard(
                title: "Panels",
                totalAvailable: dashboardData['panelTotalCount']?.toString() ?? "0",
                connectionStatusTotal: dashboardData['panelTotalCount']?.toString() ?? "0",
                connectionStatusNormal: dashboardData['panelActiveCount']?.toString() ?? "0",
                connectionStatusAbnormal: dashboardData['panelInactiveCount']?.toString() ?? "0",
              ),
              StatusCard(
                title: "Sensors",
                totalAvailable: dashboardData['sensorTotalCount']?.toString() ?? "0",
                connectionStatusTotal: dashboardData['sensorTotalCount']?.toString() ?? "0",
                connectionStatusNormal: dashboardData['sensorActiveCount']?.toString() ?? "0",
                connectionStatusAbnormal: dashboardData['sensorInactiveCount']?.toString() ?? "0",
              ),
              StatusCard(
                title: "Gateways",
                totalAvailable: dashboardData['gatewayTotalCount']?.toString() ?? "0",
                connectionStatusTotal: dashboardData['gatewayTotalCount']?.toString() ?? "0",
                connectionStatusNormal: dashboardData['gatewayActiveCount']?.toString() ?? "0",
                connectionStatusAbnormal: dashboardData['gatewayInactiveCount']?.toString() ?? "0",
              ),
              const SizedBox(height: 16),

              // Render SensorTypes only if sensorCountByType is present and non-empty
              if (dashboardData['sensorCountByType'] != null &&
                  (dashboardData['sensorCountByType'] as List).isNotEmpty)
                SensorTypes(sensorCountByType: dashboardData['sensorCountByType']),

              const SizedBox(height: 16),

              // Render Map only if branchDetails is present and non-empty
              if (dashboardData['branchDetails'] != null &&
                  (dashboardData['branchDetails'] as List).isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Branch Map",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 300,
                      child: FlutterMap(
                        options: MapOptions(
                          center: LatLng(13.1144, 80.1660), // Default center
                          zoom: 5.0,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                            "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                            subdomains: ['a', 'b', 'c'],
                          ),
                          MarkerLayer(markers: branchMarkers),
                        ],
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
