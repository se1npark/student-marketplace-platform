import 'package:flutter/material.dart';

import 'app.dart';
import 'bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dependencies = await buildDependencies();
  runApp(CampusCartApp(dependencies: dependencies));
}
