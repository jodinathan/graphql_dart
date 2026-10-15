part of graphql_schema.src.schema;

typedef GraphObject = GraphQLObjectType;

/// Shorthand for generating a [GraphQLInputObjectType].
GraphQLInputObjectType inputObjectType(String name,
    {String? description,
    Iterable<GraphQLInputObjectField> inputFields = const []}) {
  return GraphQLInputDynamicObjectType(name,
      description: description, inputFields: inputFields);
}

/// Shorthand for generating a [GraphQLInputObjectField].
GraphQLInputObjectField<T, Serialized> inputField<T, Serialized>(
    String name, GraphQLType<T, Serialized> type,
    {String? description, T? defaultValue}) {
  return GraphQLInputObjectField(name, type,
      description: description, defaultValue: defaultValue);
}
