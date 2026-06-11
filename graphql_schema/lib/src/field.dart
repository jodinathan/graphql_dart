part of graphql_schema.src.schema;

/// Typedef for a function that resolves the value of a [GraphQLObjectField], whether asynchronously or not.
typedef GraphQLFieldResolver<Value, Serialized> = FutureOr<Value> Function(
    Serialized serialized, Map<String, dynamic> argumentValues);

const graphQLStringPair = GraphQLStringPairType();

abstract interface class GraphQLBaseType {
  const GraphQLBaseType();

  String? get name;
  String? get description;
}

/// A field on a [GraphQLObjectType].
///
/// It can have input values and additional documentation, and explicitly declares it shape
/// within the schema.
class GraphQLObjectField<Value, Serialized> implements GraphQLBaseType {
  /// The list of input values this field accepts, if any.
  final List<GraphQLInputObjectField> inputs;

  /// The name of this field in serialized input.
  final String name;

  /// A function used to evaluate the value of this field, with respect to an arbitrary Dart value.
  final GraphQLFieldResolver<Value, Serialized>? resolve;

  /// The [GraphQLType] associated with values that this field's [resolve] callback returns.
  final GraphQLType<Value, Serialized> type;

  /// An optional description of this field; useful for tools like GraphiQL.
  final String? description;

  /// The reason that this field, if it is deprecated, was deprecated.
  final String? deprecationReason;

  const GraphQLObjectField(this.name, this.type,
      {this.inputs = const <GraphQLFieldInput>[],
      this.resolve,
      this.deprecationReason,
      this.description});

  /// Returns `true` if this field has a [deprecationReason].
  bool get isDeprecated => deprecationReason?.isNotEmpty == true;

  FutureOr<Serialized> serialize(Value value) {
    return type.serialize(value);
  }

  FutureOr<Value>? deserialize(Serialized serialized,
      [Map<String, dynamic> argumentValues = const <String, dynamic>{}]) {
    if (resolve != null) return resolve!(serialized, argumentValues);
    return type.deserialize(serialized);
  }

  @override
  bool operator ==(other) =>
      other is GraphQLObjectField &&
      other.name == name &&
      other.deprecationReason == deprecationReason &&
      other.type == type &&
      other.resolve == resolve &&
      const ListEquality<GraphQLInputObjectField>()
          .equals(other.inputs, inputs);

  GraphQLObjectField<Value, Serialized> copyWith(
          {String? name, GraphQLType<Value, Serialized>? type}) =>
      GraphQLObjectField<Value, Serialized>(
          name ?? this.name, type ?? this.type,
          inputs: inputs,
          resolve: resolve,
          description: description,
          deprecationReason: deprecationReason);
}
