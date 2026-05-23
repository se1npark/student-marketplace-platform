import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/app_controller.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Sein Park');
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _registering = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.storefront,
                    size: 56,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Campus Cart',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Buy, sell, and swap around Wallumattagal Campus.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 28),
                  if (controller.usingDemoBackend)
                    _DemoBackendBanner(notice: controller.startupNotice),
                  if (controller.errorMessage != null)
                    _ErrorBanner(message: controller.errorMessage!),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SegmentedButton<bool>(
                          segments: const [
                            ButtonSegment(
                              value: false,
                              icon: Icon(Icons.login),
                              label: Text('Sign in'),
                            ),
                            ButtonSegment(
                              value: true,
                              icon: Icon(Icons.person_add),
                              label: Text('Register'),
                            ),
                          ],
                          selected: {_registering},
                          onSelectionChanged: (selection) {
                            setState(() => _registering = selection.first);
                          },
                        ),
                        const SizedBox(height: 16),
                        if (_registering)
                          TextFormField(
                            key: const Key('authNameField'),
                            controller: _nameController,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Name',
                              prefixIcon: Icon(Icons.badge),
                            ),
                            validator: (value) =>
                                value == null || value.trim().length < 2
                                ? 'Enter your name.'
                                : null,
                          ),
                        if (_registering) const SizedBox(height: 12),
                        TextFormField(
                          key: const Key('authEmailField'),
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.alternate_email),
                          ),
                          validator: (value) {
                            final email = value?.trim() ?? '';
                            if (!email.contains('@') || !email.contains('.')) {
                              return 'Enter a valid email.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          key: const Key('authPasswordField'),
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock),
                          ),
                          validator: (value) => (value ?? '').length < 8
                              ? 'Use at least 8 characters.'
                              : null,
                        ),
                        const SizedBox(height: 18),
                        FilledButton.icon(
                          key: const Key('authSubmitButton'),
                          onPressed: controller.isBusy ? null : _submit,
                          icon: controller.isBusy
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(
                                  _registering ? Icons.person_add : Icons.login,
                                ),
                          label: Text(
                            _registering ? 'Create account' : 'Sign in',
                          ),
                        ),
                        if (controller.usingDemoBackend) ...[
                          const SizedBox(height: 8),
                          TextButton.icon(
                            key: const Key('useDemoLoginButton'),
                            onPressed: controller.isBusy ? null : _useDemoLogin,
                            icon: const Icon(Icons.flash_on),
                            label: const Text('Use test login'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final controller = context.read<AppController>();
    if (_registering) {
      await controller.register(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );
    } else {
      await controller.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );
    }
  }

  Future<void> _useDemoLogin() async {
    _emailController.text = 'sein.park@student.mq.edu.au';
    _passwordController.text = 'CampusCart1!';
    await _submit();
  }
}

class _DemoBackendBanner extends StatelessWidget {
  const _DemoBackendBanner({this.notice});

  final String? notice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.info, color: theme.colorScheme.onSecondaryContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              notice ?? 'Demo backend active.',
              style: TextStyle(color: theme.colorScheme.onSecondaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

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
          IconButton(
            tooltip: 'Dismiss',
            onPressed: context.read<AppController>().clearError,
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}
