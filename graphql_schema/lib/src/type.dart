part of graphql_schema.src.schema;

/// Strictly dictates the structure of some input data in a GraphQL query.
///
/// GraphQL's rigid type system is primarily implemented in Dart using classes that extend from [GraphQLType].
///
/// A [GraphQLType] represents values of type [Value] as values of type [Serialized]; for example, a
/// [GraphQLType] that serializes objects into `String`s.
abstract class GraphQLType<Value, Serialized> implements GraphQLBaseType {
  const GraphQLType();

  /// The name of this type.
  String? get name;

  /// A description of this type, which, while optional, can be very useful in tools like GraphiQL.
  String? get description;

  /// Optional lazy localizable description (i18n) — see [GraphQLBaseType.descriptionThunk].
  /// Concrete default `null`; subclasses that carry a model description (object
  /// types, input object types, enum types) override it with a `const` tear-off.
  @override
  String Function()? get descriptionThunk => null;

  /// Serializes an arbitrary input value.
  Serialized serialize(Value value);

  /// Deserializes a serialized value.
  Value deserialize(Serialized serialized);

  dynamic sanitize(dynamic value) => value;

  /// Attempts to cast a dynamic [value] into a [Serialized] instance.
  Serialized? convert(value) => value as Serialized?;

  /// Performs type coercion against an [input] value, and returns a list of errors if the validation was unsuccessful.
  ValidationResult validate(String key, covariant dynamic input);

  /// Creates a non-nullable type that represents this type, and enforces that a field of this type is present in input data.
  GraphQLType<Value, Serialized> nonNullable();

  /// Turns this type into one suitable for being provided as an input to a [GraphQLObjectField].
  GraphQLType<Value, Serialized> coerceToInputObject();

  @override
  String toString() => name!;

  GraphQLListType<GraphQLType<Value, Serialized>, Value, Serialized> list() =>
      GraphQLListType<GraphQLType<Value, Serialized>, Value, Serialized>(this);
}

/// Shorthand to create a [GraphQLListType].
GraphQLListType<OfType, Value, Serialized>
    listOf<OfType extends GraphQLType<Value, Serialized>, Value, Serialized>(
            OfType innerType) =>
        GraphQLListType(innerType);

typedef GraphList<OfType extends GraphQLType<Value, Serialized>, Value,
        Serialized>
    = GraphQLListType<OfType, Value, Serialized>;

/// A special [GraphQLType] that indicates that input vales should be a list of another type, [ofType].
class GraphQLListType<OfType extends GraphQLType<Value, Serialized>, Value,
        Serialized> extends GraphQLType<List<Value>, List<Serialized>>
    with
        _NonNullableMixin<List<Value>, List<Serialized>>,
        GraphQLDelegatedType<OfType, Value, Serialized> {
  @override
  final OfType ofType;

  const GraphQLListType(this.ofType);

  @override
  List<Serialized>? convert(value) {
    if (value is Iterable) {
      return value.cast<Serialized>().toList();
    } else {
      return super.convert(value);
    }
  }

  @override
  String? get name => null;

  @override
  String get description =>
      'A list of items of type ${ofType.name ?? '(${ofType.description}).'}';

  @override
  ValidationResult<List<Serialized>> validate(String key, List input) {
    if (input is! List) {
      return ValidationResult._failure(['Expected "$key" to be a list.']);
    }

    var out = <Serialized>[];
    var errors = <String>[];

    for (var i = 0; i < input.length; i++) {
      var k = '"$key" at index $i';
      var v = input[i];
      var result = ofType.validate(k, v);
      if (!result.successful) {
        errors.addAll(result.errors);
      } else {
        out.add(v);
      }
    }

    if (errors.isNotEmpty) return ValidationResult._failure(errors);
    return ValidationResult._ok(out);
  }

  @override
  List<Value> deserialize(List serialized) {
    return serialized
        .map<Value>((v) => ofType.deserialize(v as Serialized))
        .toList();
  }

  @override
  List<Serialized> serialize(List<Value> value) {
    return value.map<Serialized>(ofType.serialize).toList();
  }

  @override
  String toString() => '[$ofType]';

  @override
  bool operator ==(other) => other is GraphQLListType && other.ofType == ofType;

  @override
  GraphQLType<List<Value>, List<Serialized>> coerceToInputObject() =>
      GraphQLListType<GraphQLType<Value, Serialized>, Value, Serialized>(
          ofType.coerceToInputObject());
}

class GraphQLFixedLengthListType<OfType extends GraphQLType<Value, Serialized>,
    Value, Serialized> extends GraphQLListType<OfType, Value, Serialized> {
  const GraphQLFixedLengthListType(super.ofType, this.length);

  final int length;

  @override
  ValidationResult<List<Serialized>> validate(String key, List input) {
    final ret = super.validate(key, input);

    if (ret.successful && input.length != length) {
      return ValidationResult._failure(['Expected "$key" to be a list of length $length.']);
    }

    return ret;
  }
}

mixin _NonNullableMixin<Value, Serialized>
    implements GraphQLType<Value, Serialized> {
  @override
  GraphQLType<Value, Serialized> nonNullable() =>
      GraphQLNonNullableType<GraphQLType<Value, Serialized>, Value, Serialized>(
          this);
}

mixin GraphQLDelegatedType<
    OfType extends GraphQLType<Value, Serialized>, Value, Serialized> {
  OfType get ofType;
}

typedef GraphNonNull<OfType extends GraphQLType<Value, Serialized>, Value,
        Serialized>
    = GraphQLNonNullableType<OfType, Value, Serialized>;

/// A special [GraphQLType] that indicates that input values should both be non-null, and be valid when asserted against another type, named [ofType].
class GraphQLNonNullableType<OfType extends GraphQLType<Value, Serialized>,
        Value, Serialized> extends GraphQLType<Value, Serialized>
    with GraphQLDelegatedType<OfType, Value, Serialized> {
  @override
  final OfType ofType;

  const GraphQLNonNullableType(this.ofType);

  @override
  String? get name => null; //innerType.name;

  @override
  String get description =>
      'A non-nullable binding to ${ofType.name ?? '(${ofType.description}).'}';

  @override
  GraphQLType<Value, Serialized> nonNullable() {
    throw UnsupportedError('Cannot call nonNullable() on a non-nullable type.');
  }

  @override
  ValidationResult validate(String key, dynamic input) {
    if (input == null) {
      return ValidationResult._failure(
          ['Expected "$key" to be a non-null value.']);
    }
    return ofType.validate(key, input);
  }

  @override
  Value deserialize(covariant dynamic serialized) {
    return ofType.deserialize(ofType.convert(serialized) as Serialized);
  }

  @override
  Serialized serialize(Value value) {
    return ofType.serialize(value);
  }

  @override
  String toString() {
    return '$ofType!';
  }

  @override
  bool operator ==(other) =>
      other is GraphQLNonNullableType && other.ofType == ofType;

  @override
  GraphQLType<Value, Serialized> coerceToInputObject() {
    return ofType.coerceToInputObject().nonNullable();
  }
}
