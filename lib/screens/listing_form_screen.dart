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

  static const _campusPickupSpots = <ListingLocation>[
    ListingLocation(
      latitude: -33.7756,
      longitude: 151.1126,
      label: '1 Central Courtyard',
    ),
    ListingLocation(
      latitude: -33.7756,
      longitude: 151.1126,
      label: 'MQ Library',
    ),
    ListingLocation(
      latitude: -33.7756,
      longitude: 151.1126,
      label: 'Metro side entrance',
    ),
  ];

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
                  for (final spot in _campusPickupSpots)
                    ChoiceChip(
                      label: Text(spot.label),
                      selected: _location?.label == spot.label,
                      onSelected: (_) => setState(() => _location = spot),
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
                    label: Text(
                      _location == null ? 'Location' : _location!.label,
                    ),
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
