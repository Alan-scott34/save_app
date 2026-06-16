import 'package:flutter/foundation.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:save_app/models/ModelProvider.dart';
import 'package:save_app/models/Saving.dart';

/// Simple helper to configure Amplify + DataStore
class AmplifyService {
  AmplifyService._privateConstructor();
  static final AmplifyService instance = AmplifyService._privateConstructor();
  bool _configured = false;

  Future<void> configure() async {
    if (_configured) return;
    try {
      // Add DataStore plugin with our generated models
      final datastorePlugin = AmplifyDataStore(
        modelProvider: ModelProvider.instance,
      );
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

  // --- CRUD Operations for Saving model ---

  /// Save a new saving record or update an existing one
  Future<void> saveSaving(Saving saving) async {
    try {
      await Amplify.DataStore.save(saving);
    } catch (e) {
      safePrint('Error saving record: $e');
      rethrow;
    }
  }

  /// Query saving records with optional search and type filtering
  Future<List<Saving>> getSavings({String? query, String? type}) async {
    try {
      QueryPredicate? filter;
      if (query != null && query.isNotEmpty) {
        filter = Saving.TITLE.contains(query);
      }
      if (type != null && type != 'All') {
        final typeFilter = Saving.TYPE.eq(type);
        filter = filter == null ? typeFilter : filter.and(typeFilter);
      }
      return await Amplify.DataStore.query(Saving.classType, where: filter);
    } catch (e) {
      safePrint('Error querying records: $e');
      return [];
    }
  }

  /// Observe changes to the Savings records in real-time
  Stream<QuerySnapshot<Saving>> observeSavings() {
    return Amplify.DataStore.observeQuery(Saving.classType);
  }

  /// Delete a saving record
  Future<void> deleteSaving(Saving saving) async {
    try {
      await Amplify.DataStore.delete(saving);
    } catch (e) {
      safePrint('Error deleting record: $e');
      rethrow;
    }
  }
}
