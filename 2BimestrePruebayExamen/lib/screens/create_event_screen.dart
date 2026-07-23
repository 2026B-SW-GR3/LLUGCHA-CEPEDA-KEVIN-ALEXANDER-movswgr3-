import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';
import '../models/meetup_event.dart';

class CreateEventScreen extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;

  const CreateEventScreen({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
  });

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _locationNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _uuid = const Uuid();
  final MapController _mapController = MapController();

  String _selectedDiscipline = 'Running';
  DateTime _selectedDate = DateTime.now().add(const Duration(hours: 1));
  TimeOfDay _selectedTime = TimeOfDay(
    hour: DateTime.now().add(const Duration(hours: 1)).hour,
    minute: DateTime.now().add(const Duration(hours: 1)).minute,
  );
  LatLng? _selectedPoint;
  bool _showMap = false;

  final List<String> _disciplines = ['Running', 'Calistenia', 'Gimnasio'];

  @override
  void initState() {
    super.initState();
    _selectedPoint = (widget.initialLatitude != null &&
        widget.initialLongitude != null)
        ? LatLng(widget.initialLatitude!, widget.initialLongitude!)
        : null;
    if (_selectedPoint == null) {
      _getCurrentLocation();
    } else {
      _mapController.move(_selectedPoint!, 15.0);
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _selectedPoint = LatLng(position.latitude, position.longitude);
        _mapController.move(_selectedPoint!, 15.0);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.location_off, color: Colors.white),
                SizedBox(width: 8),
                Text('No se pudo obtener la ubicación'),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    setState(() {
      _selectedPoint = point;
    });
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          ),
          child: child!,
        );
      },
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          ),
          child: child!,
        );
      },
    );
    if (time != null) setState(() => _selectedTime = time);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPoint == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona un punto en el mapa'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final dateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final event = MeetupEvent(
      id: _uuid.v4(),
      discipline: _selectedDiscipline,
      dateTime: dateTime,
      latitude: _selectedPoint!.latitude,
      longitude: _selectedPoint!.longitude,
      locationName: _locationNameController.text.isNotEmpty
          ? _locationNameController.text
          : 'Ubicación seleccionada',
      description: _descriptionController.text.isNotEmpty
          ? _descriptionController.text
          : null,
    );

    Navigator.of(context).pop(event);
  }

  @override
  void dispose() {
    _locationNameController.dispose();
    _descriptionController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Widget _buildDisciplineSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Disciplina',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _disciplines.map((discipline) {
            final isSelected = _selectedDiscipline == discipline;
            final color = _disciplineColor(discipline);
            return GestureDetector(
              onTap: () => setState(() => _selectedDiscipline = discipline),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withAlpha(40)
                      : Theme.of(context).colorScheme.surface,
                  border: Border.all(
                    color: isSelected ? color : Colors.grey.shade400,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withAlpha(60),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : [],
                ),
                child: Column(
                  children: [
                    Icon(
                      _disciplineIcon(discipline),
                      color: isSelected ? color : Colors.grey.shade500,
                      size: 28,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      discipline,
                      style: TextStyle(
                        color: isSelected ? color : Colors.grey.shade600,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fecha y Hora',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today, size: 20),
                label: Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickTime,
                icon: const Icon(Icons.access_time, size: 20),
                label: Text(
                  _selectedTime.format(context),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Punto de Encuentro',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        if (_selectedPoint != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${_selectedPoint!.latitude.toStringAsFixed(6)}, '
                    '${_selectedPoint!.longitude.toStringAsFixed(6)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                TextButton.icon(
                  onPressed: _getCurrentLocation,
                  icon: const Icon(Icons.my_location, size: 18),
                  label: const Text('Usar mi ubicación'),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        SizedBox(
          height: _showMap ? 240 : 56,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                if (_showMap)
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _selectedPoint ??
                          const LatLng(-0.22985, -78.52495),
                      initialZoom: 15.0,
                      onTap: _onMapTap,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName:
                            'com.example.finalexamenyproyecto',
                      ),
                      if (_selectedPoint != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _selectedPoint!,
                              width: 60,
                              height: 60,
                              child: Icon(
                                Icons.location_on,
                                color: _disciplineColor(_selectedDiscipline),
                                size: 48,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  right: 8,
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _showMap = !_showMap);
                        if (!_showMap && _selectedPoint != null) {
                          _mapController.move(_selectedPoint!, 15.0);
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primaryContainer,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _showMap
                                  ? Icons.visibility_off
                                  : Icons.map,
                              size: 18,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _showMap
                                  ? 'Ocultar mapa'
                                  : 'Seleccionar en el mapa',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  IconData _disciplineIcon(String discipline) {
    switch (discipline.toLowerCase()) {
      case 'running':
        return Icons.directions_run;
      case 'calistenia':
        return Icons.fitness_center;
      case 'gimnasio':
        return Icons.sports_gymnastics;
      default:
        return Icons.sports;
    }
  }

  Color _disciplineColor(String discipline) {
    switch (discipline.toLowerCase()) {
      case 'running':
        return Colors.orange;
      case 'calistenia':
        return Colors.blue;
      case 'gimnasio':
        return Colors.purple;
      default:
        return Colors.teal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Quedada'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDisciplineSelector(),
              const SizedBox(height: 24),
              _buildDateTimeSelector(),
              const SizedBox(height: 24),
              _buildLocationSection(),
              const SizedBox(height: 24),
              TextFormField(
                controller: _locationNameController,
                decoration: InputDecoration(
                  labelText: 'Nombre del lugar (opcional)',
                  hintText: 'Ej: Parque Central, Gym Power, etc.',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  prefixIcon:
                      const Icon(Icons.place, color: Colors.green),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Descripción (opcional)',
                  hintText: 'Cuéntanos un poco sobre la quedada...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  prefixIcon:
                      const Icon(Icons.description, color: Colors.green),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.send, size: 20),
                label: const Text(
                  'Crear Quedada y Enviar a App 2',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
