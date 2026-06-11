part of graphql_schema.src.schema;

/// An input to a GraphQL field. This is analogous to a function parameter in Dart.
class GraphQLFieldInput<Value, Serialized>
    extends GraphQLInputObjectField<Value, Serialized> {
  static bool _isInputTypeOrScalar(GraphQLType type) {
    if (type is GraphQLInputObjectType) {
      return true;
    } else if (type is GraphQLUnionType) {
      return type.possibleTypes.every(_isInputTypeOrScalar);
    } else if (type is GraphQLObjectType) {
      return false;
    } else if (type is GraphQLNonNullableType) {
      return _isInputTypeOrScalar(type.ofType);
    } else if (type is GraphQLListType) {
      return _isInputTypeOrScalar(type.ofType);
    } else {
      return true;
    }
  }

  const GraphQLFieldInput(String name, GraphQLType<Value, Serialized> type,
      {Value? defaultValue, bool defaultsToNull = false, String? description})
      : assert(type is! GraphQLObjectType && type is! GraphQLUnionType
      && type is! GraphQLDelegatedType<GraphQLObjectType, dynamic, Map<String, dynamic>>,
            'All inputs to a GraphQL field must either be scalar types, or explicitly marked as INPUT_OBJECT. Call `GraphQLObjectType.asInputObject()` on any object types you are passing as inputs to a field.'),
        super(name, type,
            defaultValue: defaultValue,
            description: description,
            defaultsToNull: defaultsToNull);

  @override
  bool operator ==(other) =>
      other is GraphQLFieldInput &&
      other.name == name &&
      other.type == type &&
      other.defaultValue == other.defaultValue &&
      other.defaultsToNull == defaultsToNull &&
      other.description == description;
}
