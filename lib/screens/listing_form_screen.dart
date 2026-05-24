import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/app_controller.dart';
import '../models/listing.dart';
import '../services/device_service.dart';
import '../widgets/listing_image.dart';

class ListingFormScreen extends StatefulWidget {
  const ListingFormScreen({super.key, this.listing});

  final Listing? listing;

  @override
  State<ListingFormScreen> createState() => _ListingFormScreenState();
}

class _ListingFormScreenState extends State<ListingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late String _category;
  late String _condition;
  ListingLocation? _location;
  String? _imagePath;
  PickedListingPhoto? _pickedPhoto;

  bool get _editing => widget.listing != null;

  static const _campusMapPlaces = <_CampusMapPlace>[
    _CampusMapPlace(
      location: ListingLocation(
        latitude: -33.77361443,
        longitude: 151.1128627,
        label: '1 Central Courtyard',
      ),
      type: 'Study space',
      icon: Icons.groups,
    ),
    _CampusMapPlace(
      location: ListingLocation(
        latitude: -33.775705,
        longitude: 151.1130991,
        label: 'MQ Library',
      ),
      type: 'Study space',
      icon: Icons.local_library,
    ),
    _CampusMapPlace(
      location: ListingLocation(
        latitude: -33.77680857,
        longitude: 151.1175848,
        label: 'Macquarie University Station',
      ),
      type: 'Transport',
      icon: Icons.train,
    ),
    _CampusMapPlace(
      location: ListingLocation(
        latitude: -33.774058,
        longitude: 151.112639,
        label: 'MUSE',
      ),
      type: 'Study space',
      icon: Icons.school,
    ),
    _CampusMapPlace(
      location: ListingLocation(
        latitude: -33.77426373,
        longitude: 151.1124473,
        label: "Wally's Coffee Cart",
      ),
      type: 'Food & drink',
      icon: Icons.local_cafe,
    ),
    _CampusMapPlace(
      location: ListingLocation(
        latitude: -33.772308,
        longitude: 151.110904,
        label: 'Sport & Aquatic Centre',
      ),
      type: 'Sports facility',
      icon: Icons.fitness_center,
    ),
    _CampusMapPlace(
      location: ListingLocation(
        latitude: -33.77311074,
        longitude: 151.1114156,
        label: 'Basketball Courts',
      ),
      type: 'Sports facility',
      icon: Icons.sports_basketball,
    ),
    _CampusMapPlace(
      location: ListingLocation(
        latitude: -33.7750461,
        longitude: 151.112583,
        label: 'Central BikeHub',
      ),
      type: 'Bike facility',
      icon: Icons.pedal_bike,
    ),
    _CampusMapPlace(
      location: ListingLocation(
        latitude: -33.77384218,
        longitude: 151.1154089,
        label: 'Eastern BikeHub',
      ),
      type: 'Bike facility',
      icon: Icons.pedal_bike,
    ),
    _CampusMapPlace(
      location: ListingLocation(
        latitude: -33.77403064,
        longitude: 151.1152081,
        label: 'Mason Theatre',
      ),
      type: 'Study space',
      icon: Icons.theaters,
    ),
    _CampusMapPlace(
      location: ListingLocation(
        latitude: -33.77478756,
        longitude: 151.1177421,
        label: '4 Research Park Drive',
      ),
      type: 'Study space',
      icon: Icons.business,
    ),
    _CampusMapPlace(
      location: ListingLocation(
        latitude: -33.7752438,
        longitude: 151.1061794,
        label: 'Campus Security',
      ),
      type: 'Security',
      icon: Icons.shield,
    ),
    _CampusMapPlace(
      location: ListingLocation(
        latitude: -33.771177,
        longitude: 151.108596,
        label: 'Macquarie University Village',
      ),
      type: 'Accommodation',
      icon: Icons.apartment,
    ),
    _CampusMapPlace(
      location: ListingLocation(
        latitude: -33.7734493,
        longitude: 151.1183316,
        label: 'MQ Health Clinic',
      ),
      type: 'Health',
      icon: Icons.local_hospital,
    ),
  ];

  static const _quickPickupLabels = <String>{
    '1 Central Courtyard',
    'MQ Library',
    'Macquarie University Station',
    'MUSE',
    "Wally's Coffee Cart",
  };

  @override
  void initState() {
    super.initState();
    final listing = widget.listing;
    _titleController = TextEditingController(text: listing?.title ?? '');
    _descriptionController = TextEditingController(
      text: listing?.description ?? '',
    );
    _priceController = TextEditingController(
      text: listing == null ? '' : listing.price.toStringAsFixed(2),
    );
    _category = listing?.category ?? listingCategories.first;
    _condition = listing?.condition ?? listingConditions[2];
    _location = listing?.location;
    _imagePath = listing?.imagePath;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();

    return Scaffold(
      appBar: AppBar(title: Text(_editing ? 'Edit listing' : 'New listing')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (controller.errorMessage != null)
                _FormError(message: controller.errorMessage!),
              _PhotoPreview(imagePath: _imagePath),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('listingTitleField'),
                controller: _titleController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  prefixIcon: Icon(Icons.sell),
                ),
                validator: (value) => value == null || value.trim().length < 3
                    ? 'Use at least 3 characters.'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('listingDescriptionField'),
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.notes),
                ),
                validator: (value) => value == null || value.trim().length < 8
                    ? 'Add a short description.'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('listingPriceField'),
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Price',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (value) {
                  final price = double.tryParse(value?.trim() ?? '');
                  if (price == null || price < 0) {
                    return 'Enter a valid price.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                key: const Key('listingCategoryField'),
                initialValue: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category),
                ),
                items: listingCategories
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _category = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                key: const Key('listingConditionField'),
                initialValue: _condition,
                decoration: const InputDecoration(
                  labelText: 'Condition',
                  prefixIcon: Icon(Icons.verified),
                ),
                items: listingConditions
                    .map(
                      (condition) => DropdownMenuItem(
                        value: condition,
                        child: Text(condition),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _condition = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Campus pickup',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final place in _campusMapPlaces.where(
                    (place) =>
                        _quickPickupLabels.contains(place.location.label),
                  ))
                    ChoiceChip(
                      label: Text(place.location.label),
                      selected: _sameLocation(_location, place.location),
                      onSelected: (_) =>
                          setState(() => _location = place.location),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    key: const Key('captureLocationButton'),
                    onPressed: controller.isBusy ? null : _captureLocation,
                    icon: const Icon(Icons.my_location),
                    label: const Text('Use my location'),
                  ),
                  OutlinedButton.icon(
                    key: const Key('campusMapPickerButton'),
                    onPressed: controller.isBusy ? null : _openCampusMapPicker,
                    icon: const Icon(Icons.map_outlined),
                    label: const Text('Campus map'),
                  ),
                  OutlinedButton.icon(
                    key: const Key('pickPhotoButton'),
                    onPressed: controller.isBusy ? null : _pickPhoto,
                    icon: const Icon(Icons.photo_library),
                    label: Text(
                      _imagePath == null ? 'Photo' : _fileName(_imagePath!),
                    ),
                  ),
                ],
              ),
              if (_location != null) ...[
                const SizedBox(height: 12),
                _SelectedPickup(location: _location!),
              ],
              const SizedBox(height: 24),
              FilledButton.icon(
                key: const Key('saveListingButton'),
                onPressed: controller.isBusy ? null : _save,
                icon: controller.isBusy
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(_editing ? 'Save changes' : 'Create listing'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _captureLocation() async {
    final location = await context.read<AppController>().captureLocation();
    if (location != null && mounted) {
      setState(() => _location = location);
    }
  }

  Future<void> _openCampusMapPicker() async {
    final location = await showModalBottomSheet<ListingLocation>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _CampusLocationPickerSheet(
        initialLocation: _location,
        places: _campusMapPlaces,
      ),
    );
    if (location != null && mounted) {
      setState(() => _location = location);
    }
  }

  Future<void> _pickPhoto() async {
    final photo = await context.read<AppController>().pickListingPhoto();
    if (photo != null && mounted) {
      setState(() {
        _pickedPhoto = photo;
        _imagePath = photo.path;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final controller = context.read<AppController>();
    var imagePath = _imagePath;
    final pickedPhoto = _pickedPhoto;
    if (pickedPhoto != null) {
      imagePath = await controller.uploadListingPhoto(pickedPhoto);
      if (imagePath == null) {
        return;
      }
    }

    final draft = ListingDraft(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _category,
      condition: _condition,
      price: double.parse(_priceController.text.trim()),
      location: _location,
      imagePath: imagePath,
    );

    final success = _editing
        ? await controller.updateListing(widget.listing!.id, draft)
        : await controller.createListing(draft);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_editing ? 'Listing updated' : 'Listing created'),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  String _fileName(String path) {
    final parts = path.split(RegExp(r'[/\\]'));
    return parts.isEmpty ? path : parts.last;
  }
}

class _CampusMapPlace {
  const _CampusMapPlace({
    required this.location,
    required this.type,
    required this.icon,
  });

  final ListingLocation location;
  final String type;
  final IconData icon;
}

class _SelectedPickup extends StatelessWidget {
  const _SelectedPickup({required this.location});

  final ListingLocation location;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(Icons.place, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location.label,
                  style: theme.textTheme.labelLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${location.latitude.toStringAsFixed(5)}, '
                  '${location.longitude.toStringAsFixed(5)}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CampusLocationPickerSheet extends StatefulWidget {
  const _CampusLocationPickerSheet({
    required this.initialLocation,
    required this.places,
  });

  final ListingLocation? initialLocation;
  final List<_CampusMapPlace> places;

  @override
  State<_CampusLocationPickerSheet> createState() =>
      _CampusLocationPickerSheetState();
}

class _CampusLocationPickerSheetState
    extends State<_CampusLocationPickerSheet> {
  final _searchController = TextEditingController();
  ListingLocation? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    super.dispose();
  }

  void _onSearchChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final height = MediaQuery.sizeOf(context).height * 0.86;
    final filteredPlaces = _filteredPlaces;

    return SafeArea(
      child: SizedBox(
        height: height,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Campus pickup map',
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  FilledButton(
                    key: const Key('confirmCampusMapLocationButton'),
                    onPressed: _selectedLocation == null
                        ? null
                        : () => Navigator.of(context).pop(_selectedLocation),
                    child: const Text('Use pin'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                key: const Key('campusMapSearchField'),
                controller: _searchController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  labelText: 'Search campus spots',
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AspectRatio(
                aspectRatio: 1.45,
                child: _CampusMap(
                  places: filteredPlaces,
                  selectedLocation: _selectedLocation,
                  onLocationSelected: (location) {
                    setState(() => _selectedLocation = location);
                  },
                ),
              ),
            ),
            if (_selectedLocation != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: _SelectedPickup(location: _selectedLocation!),
              ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                itemCount: filteredPlaces.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final place = filteredPlaces[index];
                  final selected = _sameLocation(
                    _selectedLocation,
                    place.location,
                  );
                  return ListTile(
                    key: Key('campusMapPlace_${place.location.label}'),
                    leading: Icon(place.icon),
                    title: Text(place.location.label),
                    subtitle: Text(place.type),
                    trailing: selected ? const Icon(Icons.check) : null,
                    selected: selected,
                    onTap: () {
                      setState(() => _selectedLocation = place.location);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_CampusMapPlace> get _filteredPlaces {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return widget.places;
    }
    return widget.places
        .where(
          (place) =>
              place.location.label.toLowerCase().contains(query) ||
              place.type.toLowerCase().contains(query),
        )
        .toList(growable: false);
  }
}

class _CampusMap extends StatelessWidget {
  const _CampusMap({
    required this.places,
    required this.selectedLocation,
    required this.onLocationSelected,
  });

  static const _minLatitude = -33.7790;
  static const _maxLatitude = -33.7690;
  static const _minLongitude = 151.1060;
  static const _maxLongitude = 151.1190;

  final List<_CampusMapPlace> places;
  final ListingLocation? selectedLocation;
  final ValueChanged<ListingLocation> onLocationSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return GestureDetector(
          key: const Key('campusMapCanvas'),
          onTapDown: (details) {
            final place = _nearestPlace(details.localPosition, size);
            onLocationSelected(
              place?.location ??
                  _locationFromOffset(details.localPosition, size),
            );
          },
          child: CustomPaint(
            painter: _CampusMapPainter(
              places: places,
              selectedLocation: selectedLocation,
              colorScheme: colorScheme,
            ),
            child: const SizedBox.expand(),
          ),
        );
      },
    );
  }

  _CampusMapPlace? _nearestPlace(Offset offset, Size size) {
    _CampusMapPlace? nearestPlace;
    var nearestDistance = 32.0;
    for (final place in places) {
      final position = _offsetForLocation(place.location, size);
      final distance = (position - offset).distance;
      if (distance < nearestDistance) {
        nearestDistance = distance;
        nearestPlace = place;
      }
    }
    return nearestPlace;
  }

  static Offset _offsetForLocation(ListingLocation location, Size size) {
    final x =
        ((location.longitude - _minLongitude) / (_maxLongitude - _minLongitude))
            .clamp(0.0, 1.0) *
        size.width;
    final y =
        ((_maxLatitude - location.latitude) / (_maxLatitude - _minLatitude))
            .clamp(0.0, 1.0) *
        size.height;
    return Offset(x, y);
  }

  static ListingLocation _locationFromOffset(Offset offset, Size size) {
    final normalizedX = (offset.dx / size.width).clamp(0.0, 1.0);
    final normalizedY = (offset.dy / size.height).clamp(0.0, 1.0);
    final latitude = _maxLatitude - normalizedY * (_maxLatitude - _minLatitude);
    final longitude =
        _minLongitude + normalizedX * (_maxLongitude - _minLongitude);
    return ListingLocation(
      latitude: latitude,
      longitude: longitude,
      label: 'Campus map pin',
    );
  }
}

class _CampusMapPainter extends CustomPainter {
  const _CampusMapPainter({
    required this.places,
    required this.selectedLocation,
    required this.colorScheme,
  });

  final List<_CampusMapPlace> places;
  final ListingLocation? selectedLocation;
  final ColorScheme colorScheme;

  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()..color = colorScheme.surfaceContainerHighest;
    final border = Paint()
      ..color = colorScheme.outlineVariant
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final bounds = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(8),
    );
    canvas.drawRRect(bounds, background);
    canvas.drawRRect(bounds, border);

    final campusPaint = Paint()..color = colorScheme.primaryContainer;
    final campusPath = Path()
      ..moveTo(size.width * 0.20, size.height * 0.12)
      ..lineTo(size.width * 0.82, size.height * 0.18)
      ..lineTo(size.width * 0.92, size.height * 0.72)
      ..lineTo(size.width * 0.35, size.height * 0.88)
      ..lineTo(size.width * 0.12, size.height * 0.56)
      ..close();
    canvas.drawPath(campusPath, campusPaint);

    final roadPaint = Paint()
      ..color = colorScheme.surface
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas
      ..drawLine(
        Offset(size.width * 0.12, size.height * 0.70),
        Offset(size.width * 0.90, size.height * 0.48),
        roadPaint,
      )
      ..drawLine(
        Offset(size.width * 0.28, size.height * 0.16),
        Offset(size.width * 0.70, size.height * 0.84),
        roadPaint,
      )
      ..drawLine(
        Offset(size.width * 0.08, size.height * 0.32),
        Offset(size.width * 0.92, size.height * 0.32),
        roadPaint,
      );

    _drawMapLabel(canvas, size, 'Culloden Rd', 0.10, 0.20);
    _drawMapLabel(canvas, size, 'Wallys Walk', 0.44, 0.37);
    _drawMapLabel(canvas, size, 'Library', 0.53, 0.68);
    _drawMapLabel(canvas, size, 'Station', 0.83, 0.82);

    for (final place in places) {
      _drawPlace(canvas, size, place);
    }
    final selected = selectedLocation;
    if (selected != null) {
      _drawSelectedPin(canvas, size, selected);
    }
  }

  void _drawMapLabel(
    Canvas canvas,
    Size size,
    String text,
    double x,
    double y,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, Offset(size.width * x, size.height * y));
  }

  void _drawPlace(Canvas canvas, Size size, _CampusMapPlace place) {
    final offset = _CampusMap._offsetForLocation(place.location, size);
    final selected = _sameLocation(selectedLocation, place.location);
    final fill = Paint()
      ..color = selected ? colorScheme.primary : colorScheme.surface;
    final outline = Paint()
      ..color = selected ? colorScheme.primary : colorScheme.outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = selected ? 3 : 1.4;
    canvas
      ..drawCircle(offset, selected ? 8 : 6, fill)
      ..drawCircle(offset, selected ? 8 : 6, outline);
  }

  void _drawSelectedPin(Canvas canvas, Size size, ListingLocation location) {
    final offset = _CampusMap._offsetForLocation(location, size);
    final pinPaint = Paint()..color = colorScheme.primary;
    final pinPath = Path()
      ..moveTo(offset.dx, offset.dy + 18)
      ..cubicTo(
        offset.dx - 14,
        offset.dy + 2,
        offset.dx - 12,
        offset.dy - 16,
        offset.dx,
        offset.dy - 16,
      )
      ..cubicTo(
        offset.dx + 12,
        offset.dy - 16,
        offset.dx + 14,
        offset.dy + 2,
        offset.dx,
        offset.dy + 18,
      )
      ..close();
    canvas.drawPath(pinPath, pinPaint);
    canvas.drawCircle(
      offset.translate(0, -4),
      4,
      Paint()..color = colorScheme.onPrimary,
    );
  }

  @override
  bool shouldRepaint(_CampusMapPainter oldDelegate) {
    return oldDelegate.places != places ||
        oldDelegate.selectedLocation != selectedLocation ||
        oldDelegate.colorScheme != colorScheme;
  }
}

bool _sameLocation(ListingLocation? a, ListingLocation? b) {
  if (a == null || b == null) {
    return false;
  }
  return a.label == b.label &&
      a.latitude == b.latitude &&
      a.longitude == b.longitude;
}

class _PhotoPreview extends StatelessWidget {
  const _PhotoPreview({required this.imagePath});

  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: AspectRatio(
        aspectRatio: 16 / 8,
        child: ColoredBox(
          color: theme.colorScheme.primaryContainer,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ListingImage(
                imagePath: imagePath,
                fallbackIcon: Icons.add_photo_alternate,
              ),
              if (imagePath == null)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    color: Colors.black.withValues(alpha: 0.45),
                    child: const Text(
                      'Optional listing photo',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
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

class _FormError extends StatelessWidget {
  const _FormError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.onErrorContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: theme.colorScheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}
