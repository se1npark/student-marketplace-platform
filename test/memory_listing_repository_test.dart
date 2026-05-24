import 'package:campus_cart/models/campus_user.dart';
import 'package:campus_cart/models/listing.dart';
import 'package:campus_cart/repositories/listing_repository.dart';
import 'package:campus_cart/repositories/memory_listing_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('updateListing throws ListingException when listing does not exist', () {
    final repository = MemoryListingRepository();

    const draft = ListingDraft(
      title: 'Ghost listing',
      description: 'This listing does not exist.',
      category: 'Other',
      condition: 'Good',
      price: 0,
    );

    expect(
      () => repository.updateListing(id: 'nonexistent-id', draft: draft),
      throwsA(isA<ListingException>()),
    );
  });

  test(
    'memory listing repository supports create, update, and delete',
    () async {
      final repository = MemoryListingRepository();
      final events = <List<Listing>>[];
      final subscription = repository.watchListings().listen(events.add);
      await pumpEventQueue();

      const owner = CampusUser(
        id: 'student-1',
        email: 'student@mq.edu.au',
        displayName: 'Student Seller',
      );

      const firstDraft = ListingDraft(
        title: 'Lab coat',
        description: 'Clean coat for science labs.',
        category: 'Other',
        condition: 'Good',
        price: 12,
      );

      await repository.addListing(draft: firstDraft, owner: owner);
      await pumpEventQueue();

      expect(events.last, hasLength(1));
      expect(events.last.single.title, 'Lab coat');

      final id = events.last.single.id;
      const updatedDraft = ListingDraft(
        title: 'Lab coat bundle',
        description: 'Coat plus safety glasses.',
        category: 'Other',
        condition: 'Like new',
        price: 16,
      );

      await repository.updateListing(id: id, draft: updatedDraft);
      await pumpEventQueue();

      expect(events.last.single.title, 'Lab coat bundle');
      expect(events.last.single.price, 16);

      await repository.deleteListing(id);
      await pumpEventQueue();

      expect(events.last, isEmpty);
      await subscription.cancel();
    },
  );
}
