import 'dart:async';
import 'package:graphql_schema2/graphql_schema2.dart';
import 'package:graphql_server2/graphql_server2.dart';
import 'package:test/test.dart';

void main() {
  var episodes = [
    {'name': 'The Phantom Menace'},
    {'name': 'Attack of the Clones'},
    {'name': 'Attack of the Clones'}
  ];
  var episodesAsData = episodes.map((ep) {
    return {
      'data': {'prequels': ep}
    };
  });

  Stream<Map<String, dynamic>> resolveEpisodes(_, __) =>
      Stream.fromIterable(episodes)
          .map((ep) => {'prequels': ep, 'not_selected': 1337});

  var episodeType = GraphQLDynamicObjectType('Episode', fields: [
    GraphQLObjectField('name', graphQLString.nonNullable()),
    GraphQLObjectField('not_selected', graphQLInt),
  ]);

  var schema = graphQLSchema(
    queryType: GraphQLDynamicObjectType('TestQuery', fields: [
      GraphQLObjectField('episodes', graphQLInt,
          resolve: (_, __) => episodes.length),
    ]),
    subscriptionType: GraphQLDynamicObjectType('TestSubscription', fields: [
      GraphQLObjectField<dynamic, dynamic>('prequels', episodeType,
          resolve: resolveEpisodes),
    ]),
  );

  var graphQL = GraphQL(schema);

  test('subscribe with selection', () async {
    var stream = await graphQL.parseAndExecute('''
    subscription {
      prequels {
        name
      }
    }
    ''') as Stream<Map<String, dynamic>>;

    var asList = await stream.toList();
    expect(asList, episodesAsData);
  });
}
