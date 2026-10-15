import 'package:graphql_schema2/graphql_schema2.dart';
import 'package:test/test.dart';

void main() {
  var typeType = enumTypeFromStrings('Type', [
    'FIRE',
    'WATER',
    'GRASS',
  ]);

  var pokemonType = GraphQLDynamicObjectType('Pokémon', fields: [
    GraphQLObjectField(
      'name',
      graphQLString.nonNullable(),
    ),
    GraphQLObjectField(
      'type',
      typeType,
    ),
  ]);

  var isValidPokemon = predicate(
      (dynamic x) =>
          pokemonType.validate('@root', x as Map<String, dynamic>).successful,
      'is a valid Pokémon');

  var throwsATypeError = throwsA(
      predicate((dynamic x) => x is TypeError, 'is a type or cast error'));

  test('object accepts valid input', () {
    expect({'name': 'Charmander', 'type': 'FIRE'}, isValidPokemon);
  });

  test('mismatched scalar type', () {
    expect(() => pokemonType.validate('@root', {'name': 24}), throwsATypeError);
  });

  test('empty passed for non-nullable', () {
    expect(<String, dynamic>{}, isNot(isValidPokemon));
  });

  test('null passed for non-nullable', () {
    expect({'name': null}, isNot(isValidPokemon));
  });

  test('rejects extraneous fields', () {
    expect({'name': 'Vulpix', 'foo': 'bar'}, isNot(isValidPokemon));
  });

  test('enum accepts valid value', () {
    expect(typeType.validate('@root', 'FIRE').successful, true);
  });

  test('enum rejects invalid value', () {
    expect(typeType.validate('@root', 'POISON').successful, false);
  });

  group('union type', () {
    var digimonType = GraphQLDynamicObjectType(
      'Digimon',
      fields: [
        GraphQLObjectField('size', graphQLFloat.nonNullable()),
      ],
    );

    var u = GraphQLUnionType('Monster', [pokemonType, digimonType]);

    test('any of its types returns valid', () {
      expect(u.validate('@root', {'size': 32.0}).successful, true);
      expect(
          u.validate(
              '@root', {'name': 'Charmander', 'type': 'FIRE'}).successful,
          true);
    });
  });

  group('input object', () {
    var type = inputObjectType(
      'Foo',
      inputFields: [
        inputField('bar', graphQLString.nonNullable()),
        inputField('baz', graphQLFloat.nonNullable()),
      ],
    );

    test('accept valid input', () {
      expect(type.validate('@root', {'bar': 'a', 'baz': 2.0}).value,
          {'bar': 'a', 'baz': 2.0});
    });

    test('error on missing non-null fields', () {
      expect(type.validate('@root', {'bar': 'a'}).successful, false);
    });

    test('error on unrecognized fields', () {
      expect(
          type.validate(
              '@root', {'bar': 'a', 'baz': 2.0, 'franken': 'stein'}).successful,
          false);
    });
  });

  group('null in nullable positions', () {
    var item = inputObjectType(
      'Item',
      inputFields: [inputField('name', graphQLString.nonNullable())],
    );

    test('a nullable list item may be null', () {
      var result = GraphQLListType(graphQLString).validate('xs', ['a', null]);
      expect(result.successful, true);
      expect(result.value, ['a', null]);
    });

    test('a nullable input object item may be null', () {
      var result = GraphQLListType(item).validate('items', [
        {'name': 'a'},
        null,
      ]);
      expect(result.successful, true);
    });

    test('a non-null list item may not be null', () {
      var result = GraphQLListType(graphQLString.nonNullable())
          .validate('xs', ['a', null]);
      expect(result.successful, false);
    });

    test('a non-null input object item may not be null', () {
      var result =
          GraphQLListType(item.nonNullable()).validate('items', [null]);
      expect(result.successful, false);
    });

    test('a nullable list field of an object may be null', () {
      var type = GraphQLDynamicObjectType('Bag', fields: [
        GraphQLObjectField('xs', GraphQLListType(graphQLString)),
      ]);
      var result = type.validate('@root', {'xs': null});
      expect(result.successful, true);
      expect(result.value, {'xs': null});
    });

    test('a non-null field of an object may not be null', () {
      var type = GraphQLDynamicObjectType('Bag', fields: [
        GraphQLObjectField('xs', GraphQLListType(graphQLString).nonNullable()),
      ]);
      expect(type.validate('@root', {'xs': null}).successful, false);
    });
  });
}
