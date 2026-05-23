import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../campus_content.dart';
import '../controllers/app_controller.dart';
import '../models/listing.dart';
import 'listing_form_screen.dart';

class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final user = controller.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Cart'),
        actions: [
          if (user != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: Text(
                  user.displayName,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ),
          IconButton(
            tooltip: 'Sign out',
            onPressed: controller.isBusy
                ? null
                : () => context.read<AppController>().signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          if (controller.usingDemoBackend)
            const _StatusStrip(icon: Icons.cloud_off, text: 'Demo backend'),
          if (controller.errorMessage != null)
            _InlineError(message: controller.errorMessage!),
          const _CampusHero(),
          _CategoryFilters(controller: controller),
          Expanded(
            child: controller.listings.isEmpty
                ? const _EmptyMarketplace()
                : ListView.builder(
                    itemCount: controller.listings.length,
                    itemBuilder: (context, index) {
                      final listing = controller.listings[index];
                      return ListingCard(
                        listing: listing,
                        canManage: listing.ownerId == user?.id,
                        onEdit: () => _openListingForm(context, listing),
                        onDelete: () => _confirmDelete(context, listing),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('addListingButton'),
        onPressed: controller.isBusy
            ? null
            : () => _openListingForm(context, null),
        icon: const Icon(Icons.add),
        label: const Text('Listing'),
      ),
    );
  }

  static Future<void> _openListingForm(BuildContext context, Listing? listing) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ListingFormScreen(listing: listing)),
    );
  }

  static Future<void> _confirmDelete(
    BuildContext context,
    Listing listing,
  ) async {
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
      await context.read<AppController>().deleteListing(listing.id);
    }
  }
}

class _CampusHero extends StatelessWidget {
  const _CampusHero();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      height: 146,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            CampusContent.campusHeroImageAsset,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                Container(color: theme.colorScheme.primaryContainer),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.08),
                  Colors.black.withValues(alpha: 0.62),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  CampusContent.campusName,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  CampusContent.campusTagline,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryFilters extends StatelessWidget {
  const _CategoryFilters({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final category = controller.filterOptions[index];
          return FilterChip(
            label: Text(category),
            selected: category == controller.categoryFilter,
            onSelected: (_) => controller.setCategoryFilter(category),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemCount: controller.filterOptions.length,
      ),
    );
  }
}

class ListingCard extends StatelessWidget {
  const ListingCard({
    super.key,
    required this.listing,
    required this.canManage,
    required this.onEdit,
    required this.onDelete,
  });

  final Listing listing;
  final bool canManage;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = NumberFormat.simpleCurrency(name: 'AUD');
    final date = DateFormat('d MMM').format(listing.updatedAt);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              clipBehavior: Clip.antiAlias,
              child: _ListingThumbnail(
                imagePath: listing.imagePath,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          listing.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        listing.price == 0
                            ? 'Free'
                            : currency.format(listing.price),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    listing.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _MetaChip(icon: Icons.category, label: listing.category),
                      _MetaChip(icon: Icons.verified, label: listing.condition),
                      _MetaChip(icon: Icons.schedule, label: date),
                      if (listing.location != null)
                        _MetaChip(
                          icon: Icons.place,
                          label: listing.location!.label,
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${listing.ownerName}  ·  ${listing.contactEmail}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (canManage)
              PopupMenuButton<_ListingAction>(
                tooltip: 'Listing actions',
                onSelected: (action) {
                  switch (action) {
                    case _ListingAction.edit:
                      onEdit();
                    case _ListingAction.delete:
                      onDelete();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: _ListingAction.edit,
                    child: ListTile(
                      leading: Icon(Icons.edit),
                      title: Text('Edit'),
                    ),
                  ),
                  PopupMenuItem(
                    value: _ListingAction.delete,
                    child: ListTile(
                      leading: Icon(Icons.delete),
                      title: Text('Delete'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _ListingThumbnail extends StatelessWidget {
  const _ListingThumbnail({required this.imagePath, required this.color});

  final String? imagePath;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final path = imagePath;
    final uri = path == null ? null : Uri.tryParse(path);
    if (path != null && path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            Icon(Icons.photo, color: color),
      );
    }

    if (uri != null && (uri.scheme == 'https' || uri.scheme == 'http')) {
      return Image.network(
        path!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            Icon(Icons.photo, color: color),
      );
    }

    return Icon(path == null ? Icons.sell : Icons.photo, color: color);
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MaterialBanner(
      backgroundColor: theme.colorScheme.errorContainer,
      content: Text(
        message,
        style: TextStyle(color: theme.colorScheme.onErrorContainer),
      ),
      actions: [
        TextButton(
          onPressed: context.read<AppController>().clearError,
          child: const Text('Dismiss'),
        ),
      ],
    );
  }
}

class _StatusStrip extends StatelessWidget {
  const _StatusStrip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: theme.colorScheme.secondaryContainer,
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.onSecondaryContainer),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(color: theme.colorScheme.onSecondaryContainer),
          ),
        ],
      ),
    );
  }
}

class _EmptyMarketplace extends StatelessWidget {
  const _EmptyMarketplace();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 52,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text('No listings yet', style: theme.textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

enum _ListingAction { edit, delete }
