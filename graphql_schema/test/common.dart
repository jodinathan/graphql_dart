import 'package:graphql_schema2/graphql_schema2.dart';

final GraphQLObjectType pokemonType =
    GraphQLDynamicObjectType('Pokemon', fields: [
  GraphQLObjectField('species', graphQLString),
  GraphQLObjectField('catch_date', graphQLDate)
]);

final GraphQLObjectType trainerType = GraphQLDynamicObjectType('Trainer',
    fields: [GraphQLObjectField('name', graphQLString)]);

final GraphQLObjectType pokemonRegionType =
    GraphQLDynamicObjectType('PokemonRegion', fields: [
  GraphQLObjectField('trainer', trainerType),
  GraphQLObjectField('pokemon_species', listOf(pokemonType))
]);
