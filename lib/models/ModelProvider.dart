import 'package:amplify_core/amplify_core.dart';
import 'Saving.dart';

export 'Saving.dart';

class ModelProvider implements ModelProviderInterface {
  @override
  String version = "e9f5bf0edc223c0b029a738c8c205566";
  @override
  List<ModelSchema> modelSchemas = [Saving.schema];
  @override
  List<ModelSchema> customTypeSchemas = [];
  static final ModelProvider _instance = ModelProvider();

  static ModelProvider get instance => _instance;

  @override
  ModelType getModelTypeByModelName(String modelName) {
    switch (modelName) {
      case "Saving":
        return Saving.classType;
      default:
        throw Exception("Failed to find model in model provider for model name: $modelName");
    }
  }
}
