part of graphql_schema.src.schema;

/// Shorthand for building a [GraphQLEnumType].
GraphQLEnumType enumType<Value>(String name, Map<String, Value> values,
    {String? description}) {
  final len = values.keys.length;

  return GraphQLEnumType<Value>(
      name,
      [
        for (var i = 0; i < len; i++)
          GraphQLEnumValue(
              values.keys.elementAt(i), values.values.elementAt(i)),
      ],
      description: description);
}

/// Shorthand for building a [GraphQLEnumType] where all the possible values
/// are mapped to Dart strings.
GraphQLEnumType<String> enumTypeFromStrings(String name, List<String> values,
    {String? description}) {
  return GraphQLEnumType<String>(
      name, values.map((s) => GraphQLEnumValue(s, s)).toList(),
      description: description);
}

/// A [GraphQLType] with only a predetermined number of possible values.
///
/// Though these are serialized as strings, they carry special meaning with a type system.
class GraphQLEnumType<Value> extends GraphQLScalarType<Value, String>
    with _NonNullableMixin<Value, String> {
  /// The name of this enum type.
  @override
  final String name;

  /// The defined set of possible values for this type.
  ///
  /// No other values will be accepted than the ones you define.
  final List<GraphQLEnumValue<Value>> values;

  /// A description of this enum type, for tools like GraphiQL.
  @override
  final String? description;

  /// Optional lazy localizable description (i18n) — see [GraphQLBaseType.descriptionThunk].
  @override
  final String Function()? descriptionThunk;

  const GraphQLEnumType(this.name, this.values,
      {this.description, this.descriptionThunk});

  @override
  String serialize(dynamic value) => switch (value) {
    String() => value,
    Value() => values.firstWhere((v) => v.value == value).name,
    _ => value
  };

  @override
  String? convert(value) => switch (value) {
    String() => value,
    Value() => serialize(value),
    _ => value
  };

  @override
  Value deserialize(String serialized) {
    return values.firstWhere((v) => v.name == serialized).value;
  }

  @override
  ValidationResult validate(String key, dynamic input) {
    if (input is String || input is Enum) {
      if (input is String && !values.any((v) => v.name == input)) {
        return ValidationResult._failure(
            ['"$input" is not a valid String value for the enum "$name".']);
        //if (input == null) {
        //  return new ValidationResult<String>._failure(
        //      ['The enum "$name" does not accept null values.']);
        //}
      } else if (input is Enum && !values.any((v) => v.value == input)) {
        return ValidationResult._failure(
            ['"$input" is not a valid item value for the enum "$name".']);
      }
    } else if (input != null) {
      return ValidationResult._failure(
          ['"$input" is not a valid type value for the enum "$name".']);
    }

    return ValidationResult._ok(input);
  }

  @override
  bool operator ==(other) =>
      other is GraphQLEnumType &&
      other.name == name &&
      other.description == description &&
      const ListEquality<GraphQLEnumValue>().equals(other.values, values);

  @override
  GraphQLType<Value, String> coerceToInputObject() => this;
}

/// A known value of a [GraphQLEnumType].
///
/// In practice, you might not directly call this constructor very often.
class GraphQLEnumValue<Value> implements GraphQLBaseType {
  /// The name of this value.
  final String name;

  /// The Dart value associated with enum values bearing the given [name].
  final Value value;

  /// An optional description of this value; useful for tools like GraphiQL.
  final String? description;

  /// Optional lazy localizable description (i18n) — see [GraphQLBaseType.descriptionThunk].
  @override
  final String Function()? descriptionThunk;

  /// The reason, if any, that this value was deprecated, if it indeed is deprecated.
  final String? deprecationReason;

  const GraphQLEnumValue(this.name, this.value,
      {this.description, this.descriptionThunk, this.deprecationReason});

  /// Returns `true` if this value has a [deprecationReason].
  bool get isDeprecated => deprecationReason != null;

  @override
  bool operator ==(other) =>
      other is GraphQLEnumValue &&
      other.name == name &&
      other.value == value &&
      other.description == description &&
      other.deprecationReason == deprecationReason;
}
