import 'package:graphql_schema2/graphql_schema2.dart';
import 'package:graphql_server2/graphql_server2.dart';
import 'package:test/test.dart';

void main() {
  test('single element', () async {
    var todoType = GraphQLDynamicObjectType('todo', fields: [
      GraphQLObjectField(
        'text',
        graphQLString,
        resolve: (Object? obj, args) => (obj as Todo).text,
      ),
      GraphQLObjectField(
        'completed',
        graphQLBoolean,
        resolve: (Object? obj, args) => (obj as Todo).completed,
      ),
    ]);

    var schema = graphQLSchema(
      queryType: GraphQLDynamicObjectType('api', fields: [
        GraphQLObjectField<dynamic, dynamic>(
          'todos',
          listOf(todoType),
          resolve: (_, __) => [
            Todo(
              text: 'Clean your room!',
              completed: false,
            )
          ],
        ),
      ]),
    );

    var graphql = GraphQL(schema);
    var result = await graphql.parseAndExecute('{ todos { text } }');

    print(result);
    expect(result, {
      'todos': [
        {'text': 'Clean your room!'}
      ]
    });
  });
}

class Todo {
  final String? text;
  final bool? completed;

  Todo({this.text, this.completed});
}
