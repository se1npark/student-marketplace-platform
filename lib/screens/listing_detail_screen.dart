import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

import '../controllers/app_controller.dart';
import '../models/listing.dart';
import '../widgets/listing_image.dart';
import 'listing_form_screen.dart';

class ListingDetailScreen extends StatelessWidget {
  const ListingDetailScreen({super.key, required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final canManage = listing.ownerId == controller.user?.id;
    final saved = controller.isSaved(listing.id);
    final theme = Theme.of(context);
    final currency = NumberFormat.simpleCurrency(name: 'AUD');
    final sellerEmail = listing.contactEmail.trim();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Listing details'),
        actions: [
          IconButton(
            tooltip: saved ? 'Unsave listing' : 'Save listing',
            onPressed: () => controller.toggleSaved(listing.id),
            icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border),
          ),
          if (canManage)
            PopupMenuButton<_DetailAction>(
              tooltip: 'Listing actions',
              onSelected: (action) {
                switch (action) {
                  case _DetailAction.edit:
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => ListingFormScreen(listing: listing),
                      ),
                    );
                  case _DetailAction.delete:
                    _confirmDelete(context, listing);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: _DetailAction.edit,
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Edit'),
                  ),
                ),
                PopupMenuItem(
                  value: _DetailAction.delete,
                  child: ListTile(
                    leading: Icon(Icons.delete),
                    title: Text('Delete'),
                  ),
                ),
              ],
            ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          AspectRatio(
            aspectRatio: 16 / 10,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
              ),
              child: ListingImage(
                imagePath: listing.imagePath,
                fallbackIcon: Icons.sell,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        listing.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      listing.price == 0
                          ? 'Free'
                          : currency.format(listing.price),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _DetailChip(icon: Icons.category, label: listing.category),
                    _DetailChip(icon: Icons.verified, label: listing.condition),
                    if (listing.location != null)
                      _DetailChip(
                        icon: Icons.place,
                        label: listing.location!.label,
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Text('Description', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(listing.description, style: theme.textTheme.bodyLarge),
                const SizedBox(height: 20),
                Text('Seller', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      listing.ownerName.isEmpty ? '?' : listing.ownerName[0],
                    ),
                  ),
                  title: Text(listing.ownerName),
                  subtitle: Text(listing.contactEmail),
                ),
                if (sellerEmail.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      key: const Key('contactSellerButton'),
                      onPressed: () => _contactSeller(context, sellerEmail),
                      icon: const Icon(Icons.mail_outline),
                      label: const Text('Contact seller'),
                    ),
                  ),
                ],
                if (listing.location != null) ...[
                  const SizedBox(height: 12),
                  Text('Pickup point', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.location_on),
                    title: Text(listing.location!.label),
                    subtitle: Text(
                      '${listing.location!.latitude.toStringAsFixed(4)}, '
                      '${listing.location!.longitude.toStringAsFixed(4)}',
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _contactSeller(BuildContext context, String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No email app found — seller: $email')),
      );
    }
  }

  Future<void> _confirmDelete(BuildContext context, Listing listing) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete listing?'),
        content: Text(listing.title),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(Icons.delete),
            label: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final messenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);
      final success = await context.read<AppController>().deleteListing(
        listing.id,
      );
      if (success) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Listing deleted')),
        );
        navigator.pop();
      }
    }
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      backgroundColor: theme.colorScheme.secondaryContainer,
      side: BorderSide.none,
    );
  }
}

enum _DetailAction { edit, delete }
