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

    expect(result, {
      'todos': [
        {'text': 'Clean your room!'}
      ]
    });
  });

  test('operationName picks the operation of a document with several',
      () async {
    var schema = graphQLSchema(
      queryType: GraphQLDynamicObjectType('api', fields: [
        GraphQLObjectField('one', graphQLInt, resolve: (_, __) => 1),
        GraphQLObjectField('two', graphQLInt, resolve: (_, __) => 2),
      ]),
    );

    var result = await GraphQL(schema).parseAndExecute(
      'query First { one } query Second { two }',
      operationName: 'Second',
    );

    expect(result, {'two': 2});
  });

  test('a document with several operations and no operationName is refused',
      () {
    var schema = graphQLSchema(
      queryType: GraphQLDynamicObjectType('api', fields: [
        GraphQLObjectField('one', graphQLInt, resolve: (_, __) => 1),
      ]),
    );

    expect(
      () => GraphQL(schema)
          .parseAndExecute('query First { one } query Second { one }'),
      throwsA(isA<GraphQLException>().having(
        (e) => e.errors.single.message,
        'message',
        'This document defines 2 operations; send operationName to choose '
            'the one to run.',
      )),
    );
  });
}

class Todo {
  final String? text;
  final bool? completed;

  Todo({this.text, this.completed});
}
