part of graphql_schema.src.schema;

/// An input to a GraphQL field. This is analogous to a function parameter in Dart.
class GraphQLFieldInput<Value, Serialized>
    extends GraphQLInputObjectField<Value, Serialized> {
  const GraphQLFieldInput(String name, GraphQLType<Value, Serialized> type,
      {Value? defaultValue,
      bool defaultsToNull = false,
      String? description,
      String Function()? descriptionThunk})
      : assert(
            type is! GraphQLObjectType &&
                type is! GraphQLUnionType &&
                type is! GraphQLDelegatedType<GraphQLObjectType, dynamic,
                    Map<String, dynamic>>,
            'All inputs to a GraphQL field must either be scalar types, or explicitly marked as INPUT_OBJECT. Call `coerceToInputObject()` on any object types you are passing as inputs to a field.'),
        super(name, type,
            defaultValue: defaultValue,
            description: description,
            descriptionThunk: descriptionThunk,
            defaultsToNull: defaultsToNull);

  @override
  bool operator ==(other) =>
      other is GraphQLFieldInput &&
      other.name == name &&
      other.type == type &&
      other.defaultValue == defaultValue &&
      other.defaultsToNull == defaultsToNull &&
      other.description == description;
}
