import 'package:campus_cart/repositories/auth_repository.dart';
import 'package:campus_cart/repositories/memory_auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('demo user can sign in and sign out', () async {
    final repository = MemoryAuthRepository.withDemoUser();
    final authEvents = <String?>[];
    final subscription = repository.authStateChanges().listen(
      (user) => authEvents.add(user?.email),
    );
    await pumpEventQueue();

    await repository.signIn(
      email: 'sein.park@students.mq.edu.au',
      password: 'CampusCart1!',
    );
    await pumpEventQueue();

    expect(repository.currentUser?.displayName, 'Sein Park');
    expect(authEvents.last, 'sein.park@students.mq.edu.au');

    await repository.signOut();
    await pumpEventQueue();

    expect(repository.currentUser, isNull);
    expect(authEvents.last, isNull);
    await subscription.cancel();
  });

  test('register rejects duplicate accounts and weak passwords', () async {
    final repository = MemoryAuthRepository.withDemoUser();

    expect(
      () => repository.register(
        name: 'Sein Again',
        email: 'sein.park@students.mq.edu.au',
        password: 'CampusCart1!',
      ),
      throwsA(isA<AuthException>()),
    );

    expect(
      () => repository.register(
        name: 'Priya Singh',
        email: 'priya@student.mq.edu.au',
        password: 'short',
      ),
      throwsA(isA<AuthException>()),
    );
  });

  test('password reset validates registered demo email', () async {
    final repository = MemoryAuthRepository.withDemoUser();

    await expectLater(
      repository.resetPassword('sein.park@students.mq.edu.au'),
      completes,
    );

    await expectLater(
      repository.resetPassword('missing@student.mq.edu.au'),
      throwsA(isA<AuthException>()),
    );
  });
}
