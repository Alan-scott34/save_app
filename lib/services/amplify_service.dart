import 'package:flutter/foundation.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:save_app/models/ModelProvider.dart';

/// Simple helper to configure Amplify + DataStore
class AmplifyService {
  AmplifyService._privateConstructor();
  static final AmplifyService instance = AmplifyService._privateConstructor();
  bool _configured = false;

  Future<void> configure() async {
    if (_configured) return;
    try {
      // Add DataStore plugin with our generated models
      final datastorePlugin = AmplifyDataStore(modelProvider: ModelProvider.instance);
      await Amplify.addPlugin(datastorePlugin);

      // Normally we would call Amplify.configure(amplifyconfig) here,
      // but since we don't have an AWS backend configured yet (no amplifyconfiguration.dart),
      // we can pass a minimal dummy config just for DataStore to run locally.
      const dummyConfig = '''{
        "UserAgent": "aws-amplify-cli/2.0",
        "Version": "1.0"
      }''';
      
      await Amplify.configure(dummyConfig);

      _configured = true;
      if (kDebugMode) {
        safePrint('Amplify DataStore configured locally');
      }
    } on AmplifyAlreadyConfiguredException catch (_) {
      _configured = true;
    } catch (e) {
      safePrint('Amplify Configuration Error: $e');
      rethrow;
    }
  }
}
