import 'package:graphql_schema2/graphql_schema2.dart';
import 'package:graphql_server2/graphql_server2.dart';
import 'package:test/test.dart';

void main() {
  var innerInput = inputObjectType('InnerInput',
      inputFields: [inputField('text', graphQLString.nonNullable())]);

  var probeInput = inputObjectType('ProbeInput', inputFields: [
    inputField('text', graphQLString),
    inputField('inner', innerInput),
  ]);

  var level = enumType('Level', {'LOW': 1, 'HIGH': 2});

  var rankInput = inputObjectType('RankInput',
      inputFields: [inputField('level', level.nonNullable())]);

  var created = 0;

  var schema = graphQLSchema(
    queryType: GraphQLDynamicObjectType('Query', fields: [
      GraphQLObjectField(
        'echo',
        graphQLString,
        inputs: [GraphQLFieldInput('probe', probeInput.nonNullable())],
        resolve: (_, args) {
          var probe = args['probe'] as Map<String, dynamic>;
          var inner = probe['inner'] as Map<String, dynamic>?;
          return inner?['text'] ?? probe['text'];
        },
      ),
      GraphQLObjectField(
        'rank',
        graphQLInt,
        inputs: [GraphQLFieldInput('level', level.nonNullable())],
        resolve: (_, args) => args['level'] as int,
      ),
      GraphQLObjectField(
        'rankOf',
        graphQLInt,
        inputs: [GraphQLFieldInput('of', rankInput.nonNullable())],
        resolve: (_, args) => args['of']['level'] as int,
      ),
    ]),
    mutationType: GraphQLDynamicObjectType('Mutation', fields: [
      GraphQLObjectField(
        'create',
        GraphQLDynamicObjectType('Created',
            fields: [GraphQLObjectField('id', graphQLInt)]),
        resolve: (_, __) => {'id': ++created},
      ),
      GraphQLObjectField(
        'tag',
        graphQLString,
        inputs: [
          GraphQLFieldInput('id', graphQLInt.nonNullable()),
          GraphQLFieldInput('probe', probeInput.nonNullable()),
        ],
        resolve: (_, args) {
          var probe = args['probe'] as Map<String, dynamic>;
          return '${args['id']}:${probe['text']}';
        },
      ),
    ]),
    directiveTypes: [
      GraphQLDirectiveType('jsonpath',
          inputFields: [inputField('path', graphQLString.nonNullable())],
          locations: {DirectiveLocation.variableDefinition}),
    ],
  );

  var graphQL = GraphQL(schema);

  test('an input object variable reaches the resolver', () async {
    var result = await graphQL.parseAndExecute(
      r'query ($probe: ProbeInput!) { echo(probe: $probe) }',
      variableValues: {
        'probe': {'text': 'hello'}
      },
    );

    expect(result, {'echo': 'hello'});
  });

  test('a nested input object variable reaches the resolver', () async {
    var result = await graphQL.parseAndExecute(
      r'query ($probe: ProbeInput!) { echo(probe: $probe) }',
      variableValues: {
        'probe': {
          'inner': {'text': 'deep'}
        }
      },
    );

    expect(result, {'echo': 'deep'});
  });

  test('an enum variable is converted once, like the literal', () async {
    var literal = await graphQL.parseAndExecute('{ rank(level: HIGH) }');
    var variable = await graphQL.parseAndExecute(
      r'query ($level: Level!) { rank(level: $level) }',
      variableValues: {'level': 'HIGH'},
    );

    expect(literal, {'rank': 2});
    expect(variable, literal);
  });

  test('an enum inside an input object variable is converted once', () async {
    var literal =
        await graphQL.parseAndExecute('{ rankOf(of: {level: HIGH}) }');
    var variable = await graphQL.parseAndExecute(
      r'query ($of: RankInput!) { rankOf(of: $of) }',
      variableValues: {
        'of': {'level': 'HIGH'}
      },
    );

    expect(literal, {'rankOf': 2});
    expect(variable, literal);
  });

  test('a variable inside an input object literal is converted once', () async {
    var result = await graphQL.parseAndExecute(
      r'query ($level: Level!) { rankOf(of: {level: $level}) }',
      variableValues: {'level': 'HIGH'},
    );

    expect(result, {'rankOf': 2});
  });

  test('a @jsonpath variable is filled beside an input object variable',
      () async {
    var result = await graphQL.parseAndExecute(
      r'''
      mutation ($id: Int! @jsonpath(path: "$.create.id"), $probe: ProbeInput!) {
        create { id }
        tag(id: $id, probe: $probe)
      }
      ''',
      variableValues: {
        'probe': {'text': 'hello'}
      },
    );

    expect(result, {
      'create': {'id': created},
      'tag': '$created:hello',
    });
  });
}
