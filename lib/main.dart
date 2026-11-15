import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/firebase/firebase_initializer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeCogniCareFirebase();
  runApp(const CogniCareApp());
}