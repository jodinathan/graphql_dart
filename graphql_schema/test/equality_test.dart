import 'package:graphql_schema2/graphql_schema2.dart';
import 'package:test/test.dart';

/// Note: this doesn't test the built-in scalar types, which are `const` and therefore use identity equality.
void main() {
  group('equality', () {
    test('enums', () {
      expect(enumTypeFromStrings('A', ['B', 'C']),
          enumTypeFromStrings('A', ['B', 'C']));
      expect(enumTypeFromStrings('A', ['B', 'C']),
          isNot(enumTypeFromStrings('B', ['B', 'C'])));
    });

    test('objects', () {
      expect(
        GraphQLDynamicObjectType('B', fields: [
          GraphQLObjectField('b', graphQLString.nonNullable()),
        ]),
        GraphQLDynamicObjectType('B', fields: [
          GraphQLObjectField('b', graphQLString.nonNullable()),
        ]),
      );

      expect(
        GraphQLDynamicObjectType('B', fields: [
          GraphQLObjectField('b', graphQLString.nonNullable()),
        ]),
        isNot(GraphQLDynamicObjectType('BD', fields: [
          GraphQLObjectField('b', graphQLString.nonNullable()),
        ])),
      );

      expect(
        GraphQLDynamicObjectType('B', fields: [
          GraphQLObjectField('b', graphQLString.nonNullable()),
        ]),
        isNot(GraphQLDynamicObjectType('B', fields: [
          GraphQLObjectField('ba', graphQLString.nonNullable()),
        ])),
      );

      expect(
        GraphQLDynamicObjectType('B', fields: [
          GraphQLObjectField('b', graphQLString.nonNullable()),
        ]),
        isNot(GraphQLDynamicObjectType('B', fields: [
          GraphQLObjectField('a', graphQLFloat.nonNullable()),
        ])),
      );
    });

    test('input type', () {
      expect(
        inputObjectType('A', inputFields: [
          inputField('a', graphQLString.nonNullable()),
        ]),
        inputObjectType('A', inputFields: [
          inputField('a', graphQLString.nonNullable()),
        ]),
      );

      expect(
        inputObjectType('A', inputFields: [
          inputField('a', graphQLString.nonNullable()),
        ]),
        isNot(inputObjectType('AB', inputFields: [
          inputField('a', graphQLString.nonNullable()),
        ])),
      );

      expect(
        inputObjectType('A', inputFields: [
          inputField('a', graphQLString.nonNullable()),
        ]),
        isNot(inputObjectType('A', inputFields: [
          inputField('b', graphQLFloat.nonNullable()),
        ])),
      );
    });

    test('field input', () {
      expect(
        GraphQLFieldInput('limit', graphQLInt, defaultValue: 10),
        GraphQLFieldInput('limit', graphQLInt, defaultValue: 10),
      );

      expect(
        GraphQLFieldInput('limit', graphQLInt, defaultValue: 10),
        isNot(GraphQLFieldInput('limit', graphQLInt, defaultValue: 20)),
      );
    });

    test('union type', () {
      expect(
        GraphQLUnionType('A', [
          GraphQLDynamicObjectType('B', fields: [
            GraphQLObjectField('b', graphQLString.nonNullable()),
          ]),
          GraphQLDynamicObjectType('C', fields: [
            GraphQLObjectField('c', graphQLString.nonNullable()),
          ]),
        ]),
        GraphQLUnionType('A', [
          GraphQLDynamicObjectType('B', fields: [
            GraphQLObjectField('b', graphQLString.nonNullable()),
          ]),
          GraphQLDynamicObjectType('C', fields: [
            GraphQLObjectField('c', graphQLString.nonNullable()),
          ]),
        ]),
      );

      expect(
        GraphQLUnionType('A', [
          GraphQLDynamicObjectType('B', fields: [
            GraphQLObjectField('b', graphQLString.nonNullable()),
          ]),
          GraphQLDynamicObjectType('C', fields: [
            GraphQLObjectField('c', graphQLString.nonNullable()),
          ]),
        ]),
        isNot(GraphQLUnionType('AA', [
          GraphQLDynamicObjectType('B', fields: [
            GraphQLObjectField('b', graphQLString.nonNullable()),
          ]),
          GraphQLDynamicObjectType('C', fields: [
            GraphQLObjectField('c', graphQLString.nonNullable()),
          ]),
        ])),
      );

      expect(
        GraphQLUnionType('A', [
          GraphQLDynamicObjectType('BB', fields: [
            GraphQLObjectField('b', graphQLString.nonNullable()),
          ]),
          GraphQLDynamicObjectType('C', fields: [
            GraphQLObjectField('c', graphQLString.nonNullable()),
          ]),
        ]),
        isNot(GraphQLUnionType('AA', [
          GraphQLDynamicObjectType('BDD', fields: [
            GraphQLObjectField('b', graphQLString.nonNullable()),
          ]),
          GraphQLDynamicObjectType('C', fields: [
            GraphQLObjectField('c', graphQLString.nonNullable()),
          ]),
        ])),
      );
    });
  });
}
