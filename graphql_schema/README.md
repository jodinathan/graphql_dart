# GraphQL Schema 2

![Pub Version (including pre-releases)](https://img.shields.io/pub/v/graphql_schema2?include_prereleases)
[![Null Safety](https://img.shields.io/badge/null-safety-brightgreen)](https://dart.dev/null-safety)
[![Gitter](https://img.shields.io/gitter/room/nwjs/nw.js.svg)](https://gitter.im/angel_dart/discussion)
[![License](https://img.shields.io/github/license/dukefirehawk/graphql_dart)](https://github.com/dukefirehawk/graphql_dart/blob/master/graphql_schema/LICENSE)

An implementation of GraphQL's type system in Dart. Supports any platform where Dart runs. The decisions made in the design of this library were done to make the experience as similar to the JavaScript reference implementation as possible, and to also correctly implement the official specification.

Contains functionality to build *all* GraphQL types:

* `String`
* `Int`
* `Float`
* `Boolean`
* `GraphQLObjectType`
* `GraphQLUnionType`
* `GraphQLEnumType`
* `GraphQLInputObjectType`
* `Date` - ISO-8601 Date string, deserializes to a Dart `DateTime` object

Of course, for a full description of GraphQL's type system, see the official [GraphQL Specification](https://spec.graphql.org/). Mostly analogous to [graphql-js](https://graphql.org/graphql-js/type/); many names are verbatim.

## Usage

It's easy to define a schema with the [helper functions](#helpers):

```dart
final GraphQLSchema todoSchema = graphQLSchema(
  queryType: GraphQLDynamicObjectType('Todo', fields: [
    GraphQLObjectField('text', graphQLString.nonNullable()),
    GraphQLObjectField('created_at', graphQLDate),
  ]),
);
```

All GraphQL types are generic, in order to leverage Dart's strong typing support.

## Serialization

GraphQL types can `serialize` and `deserialize` input data. The exact implementation of this depends on the type.

```dart
var iso8601String = graphQLDate.serialize(DateTime.now());
var date = graphQLDate.deserialize(iso8601String);
print(date.millisecondsSinceEpoch);
```

## Validation

GraphQL types can `validate` input data.

```dart
var validation = myType.validate('@root', {...});

if (validation.successful) {
  doSomething(validation.value);
} else {
  print(validation.errors);
}
```

## Helpers

* `graphQLSchema` - Create a `GraphQLSchema`
* `listOf` - Create a `GraphQLListType` with the provided `innerType`
* `inputObjectType` - Creates a `GraphQLInputObjectType`
* `inputField` - Creates a field for a `GraphQLInputObjectType`

Object types and their fields are declared with constructors:
`GraphQLDynamicObjectType(name, fields: [...])` and
`GraphQLObjectField(name, type, inputs: [...], resolve: ...)`.

## Types

All of the GraphQL scalar types are built in, as well as a `Date` type:

* `graphQLString`
* `graphQLId`
* `graphQLBoolean`
* `graphQLInt`
* `graphQLFloat`
* `graphQLDate`

## Non-Nullable Types

You can easily make a type non-nullable by calling its `nonNullable` method.

## List Types

Support for list types is also included. Use the `listOf` helper for convenience.

```dart
/// A non-nullable list of non-nullable integers
listOf(graphQLInt.nonNullable()).nonNullable();
```

### Input values and parameters

Take the following GraphQL query:

```graphql
{
   anime {
     characters(title: "Hunter x Hunter") {
        name
        age
     }
   }
}
```

And subsequently, its schema:

```graphql
type AnimeQuery {
  characters($title: String!): [Character!]
}

type Character {
  name: String
  age: Int
}
```

The field `characters` accepts a parameter, `title`. To reproduce this in `package:graphql_schema2`, use `GraphQLFieldInput`:

```dart
final characterType = GraphQLDynamicObjectType('Character', fields: [
  GraphQLObjectField('name', graphQLString),
  GraphQLObjectField('age', graphQLInt),
]);

final queryType = GraphQLDynamicObjectType('AnimeQuery', fields: [
  GraphQLObjectField(
    'characters',
    listOf(characterType.nonNullable()),
    inputs: [GraphQLFieldInput('title', graphQLString.nonNullable())],
  ),
]);
```

In the majority of cases where you use GraphQL, you will be delegate the actual fetching of data to a database object, or some asynchronous resolver function.

`package:graphql_schema2` includes this functionality in the `resolve` property, which is passed a context object and a `Map<String, dynamic>` of arguments.

A hypothetical example of the above might be:

```dart
final charactersField = GraphQLObjectField(
  'characters',
  graphQLString,
  resolve: (_, args) async {
    return await myDatabase.findCharacters(args['title']);
  },
);
```
