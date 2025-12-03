import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import 'market_list_page.dart';

class FleetManagementPage extends StatefulWidget {
  const FleetManagementPage({super.key});

  @override
  State<FleetManagementPage> createState() => _FleetManagementPageState();
}

class _FleetManagementPageState extends State<FleetManagementPage>
    with SingleTickerProviderStateMixin {
  static final Uri _vehicleGraphQlEndpoint = Uri.parse(
    'https://example.com/graphql', // Replace with your backend GraphQL endpoint.
  );
  late TabController _tabController;
  late List<Vehicle> _vehicles;
  bool _loadingVehicles = false;
  String? _vehicleLoadError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _vehicles = mockVehicles();
    _refreshVehicles();
  }

  Future<void> _refreshVehicles() async {
    setState(() {
      _loadingVehicles = true;
      _vehicleLoadError = null;
    });

    try {
      final fetched = await fetchVehiclesFromServer(
        endpoint: _vehicleGraphQlEndpoint,
      );
      if (!mounted) return;
      setState(() {
        _vehicles = fetched;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _vehicleLoadError = error.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _loadingVehicles = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Keep tabs flush with the outer app bar by rendering them inside the body.
          Material(
            color: Theme.of(context).colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(icon: Icon(Icons.directions_car), text: 'Vehicles'),
                Tab(icon: Icon(Icons.person), text: 'Drivers'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _VehiclesTab(
                  vehicles: _vehicles,
                  isLoading: _loadingVehicles,
                  errorMessage: _vehicleLoadError,
                  onRefresh: _refreshVehicles,
                ),
                _DriversTab(vehicles: _vehicles),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Vehicles Tab
class _VehiclesTab extends StatefulWidget {
  const _VehiclesTab({
    required this.vehicles,
    required this.isLoading,
    required this.onRefresh,
    this.errorMessage,
  });

  final List<Vehicle> vehicles;
  final bool isLoading;
  final String? errorMessage;
  final Future<void> Function()? onRefresh;

  @override
  State<_VehiclesTab> createState() => _VehiclesTabState();
}

class _VehiclesTabState extends State<_VehiclesTab> {
  Future<void> _showVehicleDetailsSheet(Vehicle vehicle) {
    final driverController = TextEditingController(text: vehicle.driver);
    final noteController = TextEditingController(
      text: vehicle.note.isEmpty ? '' : vehicle.note,
    );
    bool isEditing = false;

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            void toggleEdit() {
              if (isEditing) {
                FocusScope.of(sheetContext).unfocus();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${vehicle.id} updated')),
                );
              }
              setSheetState(() {
                isEditing = !isEditing;
              });
            }

            return _FleetDetailCard(
              onClose: () => Navigator.of(sheetContext).pop(),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                vehicle.id,
                                style: Theme.of(sheetContext)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Status: ${vehicle.status[0].toUpperCase()}${vehicle.status.substring(1)}',
                                style: TextStyle(
                                  color: _statusColor(vehicle.status),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text("Plate: ${vehicle.plate}"),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _statusColor(
                          vehicle.status,
                        ).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.ev_station, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            '${vehicle.fuelEfficiency.toStringAsFixed(1)} km/l',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: SizedBox(
                        height: 220,
                        child: _FleetMapView(
                          vehicles: [vehicle],
                          focusVehicleId: vehicle.id,
                          interactive: false,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _EditableFleetField(
                      label: 'Driver',
                      controller: driverController,
                      readOnly: !isEditing,
                    ),
                    const SizedBox(height: 12),
                    _EditableFleetField(
                      label: 'Note',
                      controller: noteController,
                      readOnly: !isEditing,
                      minLines: 3,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: toggleEdit,
                            icon: Icon(
                              isEditing ? Icons.check : Icons.edit_outlined,
                            ),
                            label: Text(isEditing ? 'Save' : 'Edit'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () async {
                              Navigator.of(sheetContext).pop();
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => MarketListPage(
                                    vehicleId: vehicle.id,
                                    driverName: vehicle.driver,
                                  ),
                                ),
                              );
                              if (!mounted) return;
                              _showVehicleDetailsSheet(vehicle);
                            },
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: const Color(0xFF6750A4),
                            ),
                            child: const Text('Market Lists'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddVehicleDialog() {
    final vehicleIdController = TextEditingController();
    final driverController = TextEditingController();
    String selectedStatus = 'moving';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.add_circle, color: Color(0xFF2196F3)),
                  SizedBox(width: 8),
                  Text('Add New Vehicle'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: vehicleIdController,
                      decoration: const InputDecoration(
                        labelText: 'Vehicle ID',
                        hintText: 'e.g., V-101',
                        prefixIcon: Icon(Icons.tag),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: driverController,
                      decoration: const InputDecoration(
                        labelText: 'Driver Name',
                        hintText: 'e.g., John Doe',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        prefixIcon: Icon(Icons.info),
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'moving',
                          child: Text('Moving'),
                        ),
                        DropdownMenuItem(value: 'idle', child: Text('Idle')),
                        DropdownMenuItem(
                          value: 'stopped',
                          child: Text('Stopped'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            selectedStatus = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (vehicleIdController.text.isNotEmpty &&
                        driverController.text.isNotEmpty) {
                      // TODO: Add vehicle to database/state management
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Vehicle ${vehicleIdController.text} added successfully!',
                          ),
                          backgroundColor: const Color(0xFF4CAF50),
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Add Vehicle'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vehicles = widget.vehicles;
    final errorMessage = widget.errorMessage;

    return Column(
      children: [
        if (widget.isLoading) const LinearProgressIndicator(minHeight: 2),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${vehicles.length} Vehicles',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              FilledButton.icon(
                onPressed: _showAddVehicleDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add Vehicle'),
              ),
            ],
          ),
        ),
        if (errorMessage != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Material(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.errorContainer,
              child: ListTile(
                leading: const Icon(Icons.warning_amber_rounded),
                title: const Text('Unable to refresh vehicles'),
                subtitle: Text(
                  errorMessage,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: TextButton(
                  onPressed: widget.onRefresh == null
                      ? null
                      : () {
                          widget.onRefresh!.call();
                        },
                  child: const Text('Retry'),
                ),
              ),
            ),
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: widget.onRefresh ?? () async {},
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: vehicles.length,
              itemBuilder: (context, index) {
                final vehicle = vehicles[index];
                final isActive = vehicle.status == 'moving';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    onTap: () => _showVehicleDetailsSheet(vehicle),
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                            : vehicle.status == 'idle'
                            ? const Color(0xFFFF9800).withValues(alpha: 0.1)
                            : const Color(0xFFF44336).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.directions_car,
                        size: 32,
                        color: isActive
                            ? const Color(0xFF4CAF50)
                            : vehicle.status == 'idle'
                            ? const Color(0xFFFF9800)
                            : const Color(0xFFF44336),
                      ),
                    ),
                    title: Text(
                      vehicle.id,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.person,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(vehicle.driver),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.speed,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text('${vehicle.speedKph.toStringAsFixed(0)} km/h'),
                          ],
                        ),
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                            : vehicle.status == 'idle'
                            ? const Color(0xFFFF9800).withValues(alpha: 0.1)
                            : const Color(0xFFF44336).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? const Color(0xFF4CAF50)
                                  : vehicle.status == 'idle'
                                  ? const Color(0xFFFF9800)
                                  : const Color(0xFFF44336),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            vehicle.status.toUpperCase(),
                            style: TextStyle(
                              color: isActive
                                  ? const Color(0xFF4CAF50)
                                  : vehicle.status == 'idle'
                                  ? const Color(0xFFFF9800)
                                  : const Color(0xFFF44336),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// Drivers Tab
class _DriversTab extends StatefulWidget {
  const _DriversTab({required this.vehicles});

  final List<Vehicle> vehicles;

  @override
  State<_DriversTab> createState() => _DriversTabState();
}

class _DriversTabState extends State<_DriversTab> {
  late List<String> _driverNames;
  late Map<String, List<Vehicle>> _vehiclesByDriver;

  @override
  void initState() {
    super.initState();
    _prepareDriverData();
  }

  @override
  void didUpdateWidget(covariant _DriversTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.vehicles, widget.vehicles)) {
      _prepareDriverData();
    }
  }

  void _prepareDriverData() {
    final map = <String, List<Vehicle>>{};
    for (final vehicle in widget.vehicles) {
      map.putIfAbsent(vehicle.driver, () => <Vehicle>[]).add(vehicle);
    }
    _vehiclesByDriver = map;
    _driverNames = map.keys.toList()..sort();
  }

  Future<void> _showDriverDetailsSheet(
    String driverName,
    List<Vehicle> driverVehicles,
    int activeVehicles,
  ) {
    final isActive = activeVehicles > 0;
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final scheme = theme.colorScheme;
        final assignedTileColor = scheme.surfaceContainerHighest.withValues(
          alpha: theme.brightness == Brightness.dark ? 0.55 : 0.9,
        );
        final assignedSubtitleColor = scheme.onSurfaceVariant.withValues(
          alpha: 0.8,
        );
        return _FleetDetailCard(
          onClose: () => Navigator.of(sheetContext).pop(),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 34,
                      backgroundColor: const Color(
                        0xFF2196F3,
                      ).withValues(alpha: 0.1),
                      child: Text(
                        driverName.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2196F3),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            driverName,
                            style: Theme.of(sheetContext)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.circle,
                                size: 10,
                                color: isActive
                                    ? const Color(0xFF4CAF50)
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isActive ? 'Active' : 'Inactive',
                                style: TextStyle(
                                  color: isActive
                                      ? const Color(0xFF4CAF50)
                                      : Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('${driverVehicles.length} vehicle(s)'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: SizedBox(
                    height: 200,
                    child: _FleetMapView(
                      vehicles: driverVehicles,
                      focusVehicleId: driverVehicles.isNotEmpty
                          ? driverVehicles.first.id
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildFleetDetailField(
                  sheetContext,
                  'Phone',
                  '+1 234 567 8900',
                ),
                const SizedBox(height: 12),
                _buildFleetDetailField(
                  sheetContext,
                  'License',
                  'DL-${driverName.substring(0, 3).toUpperCase()}123',
                ),
                const SizedBox(height: 12),
                _buildFleetDetailField(
                  sheetContext,
                  'Active Trips',
                  isActive ? '$activeVehicles ongoing' : 'None',
                ),
                const SizedBox(height: 20),
                Text(
                  'Assigned Vehicles',
                  style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...driverVehicles.map(
                  (vehicle) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: assignedTileColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.directions_car,
                          color: vehicle.status == 'moving'
                              ? const Color(0xFF4CAF50)
                              : vehicle.status == 'idle'
                              ? const Color(0xFFFF9800)
                              : const Color(0xFFF44336),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                vehicle.id,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${vehicle.speedKph.toStringAsFixed(0)} km/h',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: assignedSubtitleColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                (vehicle.status == 'moving'
                                        ? const Color(0xFF4CAF50)
                                        : vehicle.status == 'idle'
                                        ? const Color(0xFFFF9800)
                                        : const Color(0xFFF44336))
                                    .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            vehicle.status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: vehicle.status == 'moving'
                                  ? const Color(0xFF4CAF50)
                                  : vehicle.status == 'idle'
                                  ? const Color(0xFFFF9800)
                                  : const Color(0xFFF44336),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _showDriverEditDialog(sheetContext, driverName),
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.phone),
                        label: const Text('Contact'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: const Color(0xFF6750A4),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showDriverEditDialog(
    BuildContext baseContext,
    String driverName,
  ) {
    final nameController = TextEditingController(text: driverName);
    final phoneController = TextEditingController(text: '+1 234 567 8900');
    final licenseController = TextEditingController(
      text: 'DL-${driverName.substring(0, 3).toUpperCase()}123',
    );

    return showDialog(
      context: baseContext,
      builder: (dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.person_pin_circle, color: Color(0xFF6750A4)),
              const SizedBox(width: 8),
              Text('Edit $driverName'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Driver name',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone number',
                    prefixIcon: Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: licenseController,
                  decoration: const InputDecoration(
                    labelText: 'License number',
                    prefixIcon: Icon(Icons.badge_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${nameController.text} saved')),
                );
              },
              child: const Text('Save changes'),
            ),
          ],
        );
      },
    );
  }

  void _showAddDriverDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final licenseController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.add_circle, color: Color(0xFF2196F3)),
              SizedBox(width: 8),
              Text('Add New Driver'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Driver Name',
                    hintText: 'e.g., John Doe',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    hintText: 'e.g., +1 234 567 8900',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: licenseController,
                  decoration: const InputDecoration(
                    labelText: 'License Number',
                    hintText: 'e.g., DL-123456',
                    prefixIcon: Icon(Icons.card_membership),
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  // TODO: Add driver to database/state management
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Driver ${nameController.text} added successfully!',
                      ),
                      backgroundColor: const Color(0xFF4CAF50),
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Add Driver'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final drivers = _driverNames;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${drivers.length} Drivers',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              FilledButton.icon(
                onPressed: _showAddDriverDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add Driver'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: drivers.length,
            itemBuilder: (context, index) {
              final driverName = drivers[index];
              final List<Vehicle> driverVehicles =
                  _vehiclesByDriver[driverName] ?? const <Vehicle>[];
              final activeVehicles = driverVehicles
                  .where((v) => v.status == 'moving')
                  .length;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  onTap: () => _showDriverDetailsSheet(
                    driverName,
                    driverVehicles,
                    activeVehicles,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(
                      0xFF2196F3,
                    ).withValues(alpha: 0.1),
                    child: Text(
                      driverName.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2196F3),
                      ),
                    ),
                  ),
                  title: Text(
                    driverName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.directions_car,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text('${driverVehicles.length} vehicle(s)'),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 10,
                            color: activeVehicles > 0
                                ? const Color(0xFF4CAF50)
                                : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            activeVehicles > 0 ? 'Active' : 'Inactive',
                            style: TextStyle(
                              color: activeVehicles > 0
                                  ? const Color(0xFF4CAF50)
                                  : Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {
                      // TODO: Show options menu
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

Color _statusColor(String status) {
  switch (status) {
    case 'moving':
      return const Color(0xFF4CAF50);
    case 'idle':
      return const Color(0xFFFF9800);
    default:
      return const Color(0xFFF44336);
  }
}

class _FleetMapView extends StatelessWidget {
  final List<Vehicle> vehicles;
  final String? focusVehicleId;
  final bool interactive;

  const _FleetMapView({
    required this.vehicles,
    this.focusVehicleId,
    this.interactive = true,
  });

  @override
  Widget build(BuildContext context) {
    if (vehicles.isEmpty) {
      return Container(
        color: Colors.grey[200],
        alignment: Alignment.center,
        child: const Text('No vehicle data'),
      );
    }

    final focusVehicle = focusVehicleId != null
        ? vehicles.firstWhere(
            (v) => v.id == focusVehicleId,
            orElse: () => vehicles.first,
          )
        : vehicles.first;
    final center = LatLng(focusVehicle.lat, focusVehicle.lng);

    final flags = interactive
        ? InteractiveFlag.drag |
              InteractiveFlag.pinchZoom |
              InteractiveFlag.doubleTapZoom |
              InteractiveFlag.flingAnimation
        : InteractiveFlag.none;

    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: 13,
        interactionOptions: InteractionOptions(flags: flags),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.revnotwo',
        ),
        MarkerLayer(
          markers: [
            for (final vehicle in vehicles)
              Marker(
                width: 44,
                height: 44,
                point: LatLng(vehicle.lat, vehicle.lng),
                child: _FleetMarker(
                  color: _statusColor(vehicle.status),
                  isPrimary: vehicle.id == focusVehicle.id,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _FleetMarker extends StatelessWidget {
  final Color color;
  final bool isPrimary;

  const _FleetMarker({required this.color, required this.isPrimary});

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.location_on,
      color: isPrimary ? color : color.withValues(alpha: 0.6),
      size: isPrimary ? 38 : 28,
    );
  }
}

class _EditableFleetField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool readOnly;
  final int minLines;
  final int maxLines;

  const _EditableFleetField({
    required this.label,
    required this.controller,
    required this.readOnly,
    this.minLines = 1,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.35)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: readOnly,
          minLines: minLines,
          maxLines: maxLines,
          keyboardType: maxLines > 1
              ? TextInputType.multiline
              : TextInputType.text,
          decoration: InputDecoration(
            filled: true,
            fillColor: readOnly
                ? scheme.surfaceContainerHighest.withValues(alpha: 0.4)
                : scheme.surface,
            border: border,
            enabledBorder: border,
            focusedBorder: border.copyWith(
              borderSide: BorderSide(color: scheme.primary),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}

class _FleetDetailCard extends StatelessWidget {
  final Widget child;
  final VoidCallback onClose;

  const _FleetDetailCard({required this.child, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.fromLTRB(16, 0, 16, bottomInset + 16),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Material(
          color: scheme.surface,
          elevation: 24,
          shadowColor: Colors.black.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(32),
          clipBehavior: Clip.antiAlias,
          child: SafeArea(
            top: false,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
                  child: child,
                ),
                Positioned(
                  top: 12,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: scheme.outline.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: onClose,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildFleetDetailField(
  BuildContext context,
  String label,
  String value,
) {
  final theme = Theme.of(context);
  final scheme = theme.colorScheme;
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(18),
    borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.35)),
  );

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: scheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 6),
      InputDecorator(
        decoration: InputDecoration(
          filled: true,
          fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
          border: border,
          enabledBorder: border,
          focusedBorder: border,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        child: Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  );
}
