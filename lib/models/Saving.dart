import 'package:amplify_core/amplify_core.dart';
import 'package:flutter/foundation.dart';

/// This is an auto generated class representing the Saving type in your schema.
@immutable
class Saving extends Model {
  static const classType = _SavingModelType();
  final String id;
  final String? _title;
  final double? _amount;
  final TemporalDateTime? _date;
  final String? _category;
  final String? _note;
  final TemporalDateTime? _createdAt;
  final TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;

  @override
  String getId() {
    return id;
  }

  String get title {
    try {
      return _title!;
    } catch(e) {
      throw AmplifyCodeGenModelException(
          AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }

  double get amount {
    try {
      return _amount!;
    } catch(e) {
      throw AmplifyCodeGenModelException(
          AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }

  TemporalDateTime get date {
    try {
      return _date!;
    } catch(e) {
      throw AmplifyCodeGenModelException(
          AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }

  String? get category {
    return _category;
  }

  String? get note {
    return _note;
  }

  TemporalDateTime? get createdAt {
    return _createdAt;
  }

  TemporalDateTime? get updatedAt {
    return _updatedAt;
  }

  const Saving._internal({required this.id, required title, required amount, required date, category, note, createdAt, updatedAt}): _title = title, _amount = amount, _date = date, _category = category, _note = note, _createdAt = createdAt, _updatedAt = updatedAt;

  factory Saving({String? id, required String title, required double amount, required TemporalDateTime date, String? category, String? note}) {
    return Saving._internal(
      id: id ?? UUID.getUUID(),
      title: title,
      amount: amount,
      date: date,
      category: category,
      note: note);
  }

  bool equals(Object other) {
    return this == other;
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Saving &&
      id == other.id &&
      _title == other._title &&
      _amount == other._amount &&
      _date == other._date &&
      _category == other._category &&
      _note == other._note;
  }

  @override
  int get hashCode => toString().hashCode;

  @override
  String toString() {
    var buffer = StringBuffer();

    buffer.write("Saving {");
    buffer.write("id=" "$id, ");
    buffer.write("title=" "$_title" ", ");
    buffer.write("amount=${_amount != null ? _amount.toString() : "null"}, ");
    buffer.write("date=${_date != null ? _date.format() : "null"}, ");
    buffer.write("category=" "$_category" ", ");
    buffer.write("note=" "$_note" ", ");
    buffer.write("createdAt=${_createdAt != null ? _createdAt.format() : "null"}, ");
    buffer.write("updatedAt=${_updatedAt != null ? _updatedAt.format() : "null"}");
    buffer.write("}");

    return buffer.toString();
  }

  Saving copyWith({String? id, String? title, double? amount, TemporalDateTime? date, String? category, String? note}) {
    return Saving._internal(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      note: note ?? this.note);
  }

  Saving.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      _title = json['title'],
      _amount = (json['amount'] as num?)?.toDouble(),
      _date = json['date'] != null ? TemporalDateTime.fromString(json['date']) : null,
      _category = json['category'],
      _note = json['note'],
      _createdAt = json['createdAt'] != null ? TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? TemporalDateTime.fromString(json['updatedAt']) : null;

  @override
  Map<String, dynamic> toJson() => {
    'id': id, 'title': _title, 'amount': _amount, 'date': _date?.format(), 'category': _category, 'note': _note, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };

  @override
  Map<String, Object?> toMap() => {
    'id': id, 'title': _title, 'amount': _amount, 'date': _date, 'category': _category, 'note': _note, 'createdAt': _createdAt, 'updatedAt': _updatedAt
  };

  static final QueryField ID = QueryField(fieldName: "id");
  static final QueryField TITLE = QueryField(fieldName: "title");
  static final QueryField AMOUNT = QueryField(fieldName: "amount");
  static final QueryField DATE = QueryField(fieldName: "date");
  static final QueryField CATEGORY = QueryField(fieldName: "category");
  static final QueryField NOTE = QueryField(fieldName: "note");
  static var schema = Model.defineSchema(define: (ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "Saving";
    modelSchemaDefinition.pluralName = "Savings";

    modelSchemaDefinition.addField(ModelFieldDefinition.id());

    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: Saving.TITLE,
      isRequired: true,
      ofType: ModelFieldType(ModelFieldTypeEnum.string)
    ));

    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: Saving.AMOUNT,
      isRequired: true,
      ofType: ModelFieldType(ModelFieldTypeEnum.double)
    ));

    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: Saving.DATE,
      isRequired: true,
      ofType: ModelFieldType(ModelFieldTypeEnum.dateTime)
    ));

    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: Saving.CATEGORY,
      isRequired: false,
      ofType: ModelFieldType(ModelFieldTypeEnum.string)
    ));

    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: Saving.NOTE,
      isRequired: false,
      ofType: ModelFieldType(ModelFieldTypeEnum.string)
    ));

    modelSchemaDefinition.addField(ModelFieldDefinition.nonQueryField(
      fieldName: 'createdAt',
      isRequired: false,
      isReadOnly: true,
      ofType: ModelFieldType(ModelFieldTypeEnum.dateTime)
    ));

    modelSchemaDefinition.addField(ModelFieldDefinition.nonQueryField(
      fieldName: 'updatedAt',
      isRequired: false,
      isReadOnly: true,
      ofType: ModelFieldType(ModelFieldTypeEnum.dateTime)
    ));
  });
}

class _SavingModelType extends ModelType<Saving> {
  const _SavingModelType();

  @override
  Saving fromJson(Map<String, dynamic> jsonData) {
    return Saving.fromJson(jsonData);
  }

  @override
  String modelName() {
    return 'Saving';
  }
}
