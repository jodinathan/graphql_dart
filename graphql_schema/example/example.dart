import 'package:graphql_schema2/graphql_schema2.dart';

final GraphQLSchema todoSchema = GraphQLSchema(
  queryType: GraphQLDynamicObjectType('Todo', fields: [
    GraphQLObjectField(
      'text',
      graphQLString.nonNullable(),
      resolve: resolveToNull,
    ),
    GraphQLObjectField(
      'created_at',
      graphQLDate,
      resolve: resolveToNull,
    ),
  ]),
);

void main() {
  var validation = todoSchema.queryType!.validate(
    '@root',
    {
      'foo': 'bar',
      'text': null,
      'created_at': DateTime.now(),
    },
  );

  if (validation.successful) {
    print('This is valid data!!!');
  } else {
    print('Invalid data.');
    for (var error in validation.errors) {
      print('  * $error');
    }
  }

  print(todoSchema.queryType!.serialize({
    'text': 'Clean your room!',
    'created_at': DateTime.now().subtract(Duration(days: 10))
  }));
}
