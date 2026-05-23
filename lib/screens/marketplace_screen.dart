import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../campus_content.dart';
import '../controllers/app_controller.dart';
import '../models/listing.dart';
import '../widgets/listing_image.dart';
import 'listing_detail_screen.dart';
import 'listing_form_screen.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  int _selectedIndex = 0;

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
            _StatusStrip(
              icon: Icons.cloud_off,
              text: controller.startupNotice ?? 'Demo backend',
            ),
          if (controller.errorMessage != null)
            _InlineError(message: controller.errorMessage!),
          const _CampusHero(),
          _MarketplaceControls(controller: controller),
          Expanded(child: _ListingTabBody(index: _selectedIndex)),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: 'Market',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border),
            selectedIcon: Icon(Icons.bookmark),
            label: 'Saved',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Mine',
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
}

class _CampusHero extends StatelessWidget {
  const _CampusHero();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      height: 150,
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
                  Colors.black.withValues(alpha: 0.12),
                  Colors.black.withValues(alpha: 0.70),
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

class _MarketplaceControls extends StatelessWidget {
  const _MarketplaceControls({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            key: const Key('listingSearchField'),
            onChanged: controller.setSearchQuery,
            decoration: const InputDecoration(
              hintText: 'Search textbooks, chargers, services...',
              prefixIcon: Icon(Icons.search),
              isDense: true,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _MetricChip(
                icon: Icons.inventory_2,
                label: '${controller.totalListingCount} listings',
              ),
              const SizedBox(width: 8),
              _MetricChip(
                icon: Icons.bookmark,
                label: '${controller.savedListingCount} saved',
              ),
              const SizedBox(width: 8),
              _MetricChip(
                icon: Icons.person,
                label: '${controller.ownListingCount} mine',
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 42,
            child: ListView.separated(
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
          ),
        ],
      ),
    );
  }
}

class _ListingTabBody extends StatelessWidget {
  const _ListingTabBody({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final listings = switch (index) {
      0 => controller.listings,
      1 => controller.savedListings,
      _ => controller.myListings,
    };

    if (controller.isLoadingListings) {
      return const Center(child: CircularProgressIndicator());
    }

    if (listings.isEmpty) {
      return _EmptyMarketplace(index: index);
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 96),
      itemCount: listings.length,
      itemBuilder: (context, index) {
        final listing = listings[index];
        return ListingCard(
          listing: listing,
          canManage: listing.ownerId == controller.user?.id,
          saved: controller.isSaved(listing.id),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ListingDetailScreen(listing: listing),
            ),
          ),
          onToggleSaved: () => controller.toggleSaved(listing.id),
          onEdit: () => _openListingForm(context, listing),
          onDelete: () => _confirmDelete(context, listing),
        );
      },
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
      final messenger = ScaffoldMessenger.of(context);
      final success = await context.read<AppController>().deleteListing(
        listing.id,
      );
      if (success) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Listing deleted')),
        );
      }
    }
  }
}

class ListingCard extends StatelessWidget {
  const ListingCard({
    super.key,
    required this.listing,
    required this.canManage,
    required this.saved,
    required this.onTap,
    required this.onToggleSaved,
    required this.onEdit,
    required this.onDelete,
  });

  final Listing listing;
  final bool canManage;
  final bool saved;
  final VoidCallback onTap;
  final VoidCallback onToggleSaved;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = NumberFormat.simpleCurrency(name: 'AUD');
    final date = DateFormat('d MMM').format(listing.updatedAt);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 82,
                  height: 82,
                  child: ColoredBox(
                    color: theme.colorScheme.primaryContainer,
                    child: ListingImage(
                      imagePath: listing.imagePath,
                      fallbackIcon: Icons.sell,
                      fit: BoxFit.contain,
                    ),
                  ),
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
                        const SizedBox(width: 8),
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
                        _MetaChip(
                          icon: Icons.category,
                          label: listing.category,
                        ),
                        _MetaChip(
                          icon: Icons.verified,
                          label: listing.condition,
                        ),
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
              Column(
                children: [
                  IconButton(
                    tooltip: saved ? 'Unsave listing' : 'Save listing',
                    onPressed: onToggleSaved,
                    icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border),
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
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
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
  const _EmptyMarketplace({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = switch (index) {
      1 => 'No saved listings',
      2 => 'No listings from you yet',
      _ => 'No listings match',
    };
    final icon = switch (index) {
      1 => Icons.bookmark_border,
      2 => Icons.person_outline,
      _ => Icons.inventory_2_outlined,
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 120;
        return Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(compact ? 8 : 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: compact ? 28 : 52,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                SizedBox(height: compact ? 6 : 12),
                Text(title, style: theme.textTheme.titleMedium),
              ],
            ),
          ),
        );
      },
    );
  }
}

enum _ListingAction { edit, delete }
