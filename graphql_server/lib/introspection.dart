import 'package:collection/collection.dart' show IterableExtension;
import 'package:recase/recase.dart';
import 'package:graphql_schema2/graphql_schema2.dart';

final GraphQLEnumType<String> _typeKindType =
    enumTypeFromStrings('__TypeKind', [
  'SCALAR',
  'OBJECT',
  'INTERFACE',
  'UNION',
  'ENUM',
  'INPUT_OBJECT',
  'LIST',
  'NON_NULL'
]);

GraphQLObjectType _createTypeType() {
  var enumValueType = _reflectEnumValueType();
  var fieldType = _reflectFields()!;
  var inputValueType = _reflectInputValueType();

  return GraphQLDynamicObjectType('__Type', fields: [
    GraphQLObjectField(
      'name',
      graphQLString,
      resolve: (type, _) => (type as GraphQLBaseType).name,
    ),
    GraphQLObjectField(
      'description',
      graphQLString,
      resolve: (type, _) {
        final t = type as GraphQLBaseType;
        return t.description ?? t.descriptionThunk?.call();
      },
    ),
    GraphQLObjectField(
      'kind',
      _typeKindType,
      resolve: (type, _) {
        var t = type as GraphQLType;

        if (t is GraphQLEnumType) {
          return 'ENUM';
        } else if (t is GraphQLScalarType) {
          return 'SCALAR';
        } else if (t is GraphQLInputObjectType) {
          return 'INPUT_OBJECT';
        } else if (t is GraphQLObjectType) {
          return t.isInterface ? 'INTERFACE' : 'OBJECT';
        } else if (t is GraphQLListType) {
          return 'LIST';
        } else if (t is GraphQLNonNullableType) {
          return 'NON_NULL';
        } else if (t is GraphQLUnionType) {
          return 'UNION';
        } else {
          throw UnsupportedError('Cannot get the kind of $t.');
        }
      },
    ),
    GraphQLObjectField(
      'fields',
      listOf(fieldType),
      inputs: [
        GraphQLFieldInput(
          'includeDeprecated',
          graphQLBoolean,
          defaultValue: false,
        ),
      ],
      resolve: (type, args) {
        if (type is GraphQLObjectType) {
          return type.fields
              .where((f) => !f.isDeprecated || args['includeDeprecated'] == true)
              .toList();
        }
        return null;
      },
    ),
    GraphQLObjectField(
      'enumValues',
      listOf(enumValueType.nonNullable()),
      inputs: [
        GraphQLFieldInput(
          'includeDeprecated',
          graphQLBoolean,
          defaultValue: false,
        ),
      ],
      resolve: (obj, args) {
        if (obj is GraphQLEnumType) {
          return obj.values
              .where((f) => !f.isDeprecated || args['includeDeprecated'] == true)
              .toList();
        }
        return null;
      },
    ),
    GraphQLObjectField(
      'inputFields',
      listOf(inputValueType.nonNullable()),
      resolve: (obj, _) {
        if (obj is GraphQLInputObjectType) {
          return obj.inputFields.toList();
        }
        return null;
      },
    ),
  ]);
}

GraphQLObjectType? _fieldType;

GraphQLObjectType? _reflectFields() {
  _fieldType ??= _createFieldType();

  return _fieldType;
}

GraphQLObjectType _createFieldType() {
  var inputValueType = _reflectInputValueType();

  return GraphQLDynamicObjectType('__Field', fields: [
    GraphQLObjectField(
      'name',
      graphQLString,
      resolve: (f, _) => (f as GraphQLObjectField).name,
    ),
    GraphQLObjectField(
      'description',
      graphQLString,
      resolve: (f, _) {
        final o = f as GraphQLObjectField;
        return o.description ?? o.descriptionThunk?.call() ?? '';
      },
    ),
    GraphQLObjectField(
      'isDeprecated',
      graphQLBoolean,
      resolve: (f, _) => (f as GraphQLObjectField).isDeprecated,
    ),
    GraphQLObjectField(
      'deprecationReason',
      graphQLString,
      resolve: (f, _) => (f as GraphQLObjectField).deprecationReason ?? '',
    ),
    GraphQLObjectField(
      'args',
      listOf(inputValueType.nonNullable()).nonNullable(),
      resolve: (f, _) => (f as GraphQLObjectField).inputs,
    ),
  ]);
}

GraphQLObjectType? _inputValueType;

T? _fetchFromInputValue<T>(x, T Function(GraphQLFieldInput) ifInput,
    T Function(GraphQLInputObjectField) ifObjectField) {
  if (x is GraphQLFieldInput) {
    return ifInput(x);
  } else if (x is GraphQLInputObjectField) {
    return ifObjectField(x);
  } else {
    return null;
  }
}

dynamic _def(dynamic f, dynamic Function(dynamic) serializer) {
  final val = f.defaultValue;

  if (val != null) {
    return serializer(val)?.toString();
  }

  return null;
}

GraphQLObjectType _reflectInputValueType() {
  return _inputValueType ??= GraphQLDynamicObjectType('__InputValue', fields: [
    GraphQLObjectField(
      'name',
      graphQLString.nonNullable(),
      resolve: (obj, _) =>
          _fetchFromInputValue(obj, (f) => f.name, (f) => f.name)!,
    ),
    GraphQLObjectField(
      'description',
      graphQLString,
      resolve: (obj, _) => _fetchFromInputValue(
          obj,
          (f) => f.description ?? f.descriptionThunk?.call() ?? '',
          (f) => f.description ?? f.descriptionThunk?.call() ?? '')!,
    ),
    GraphQLObjectField(
      'defaultValue',
      graphQLString,
      resolve: (obj, _) => _fetchFromInputValue(obj,
          (f) => _def(f, f.type.serialize), (f) => _def(f, f.type.serialize)),
    ),
  ]);
}

GraphQLObjectType? _directiveType;

final GraphQLEnumType<String> _directiveLocationType = enumTypeFromStrings(
    '__DirectiveLocation',
    DirectiveLocation.values
        .map((v) => v.name.snakeCase.toUpperCase())
        .toList());

GraphQLObjectType _reflectDirectiveType() {
  var inputValueType = _reflectInputValueType();

  return _directiveType ??= GraphQLDynamicObjectType('__Directive', fields: [
    GraphQLObjectField(
      'name',
      graphQLString.nonNullable(),
      resolve: (obj, _) => (obj as GraphQLDirectiveType).name,
    ),
    GraphQLObjectField(
      'description',
      graphQLString,
      resolve: (obj, _) {
        final d = obj as GraphQLDirectiveType;
        return d.description ?? d.descriptionThunk?.call() ?? '';
      },
    ),
    GraphQLObjectField(
      'locations',
      listOf(_directiveLocationType.nonNullable()).nonNullable(),
      resolve: (obj, _) => (obj as GraphQLDirectiveType)
          .locations
          .map((v) => v.name.snakeCase.toUpperCase())
          .toList(),
    ),
    GraphQLObjectField(
      'args',
      listOf(inputValueType.nonNullable()).nonNullable(),
      resolve: (obj, _) => (obj as GraphQLDirectiveType).inputFields.toList(),
    ),
  ]);
}

GraphQLObjectType? _enumValueType;

GraphQLObjectType _reflectEnumValueType() {
  return _enumValueType ??= GraphQLDynamicObjectType(
    '__EnumValue',
    fields: [
      GraphQLObjectField(
        'name',
        graphQLString.nonNullable(),
        resolve: (obj, _) => (obj as GraphQLEnumValue).name,
      ),
      GraphQLObjectField(
        'description',
        graphQLString,
        resolve: (obj, _) {
          final v = obj as GraphQLEnumValue;
          return v.description ?? v.descriptionThunk?.call() ?? '';
        },
      ),
      GraphQLObjectField(
        'isDeprecated',
        graphQLBoolean.nonNullable(),
        resolve: (obj, _) => (obj as GraphQLEnumValue).isDeprecated,
      ),
      GraphQLObjectField(
        'deprecationReason',
        graphQLString,
        resolve: (obj, _) => (obj as GraphQLEnumValue).deprecationReason ?? '',
      ),
    ],
  );
}

class CollectTypes {
  Set<GraphQLType?> traversedTypes = {};

  Set<GraphQLType?> get types => traversedTypes;

  final Map<GraphQLType, Set<GraphQLType>> interfaces = {};

  CollectTypes(GraphQLSchema schema, List<GraphQLType?> specifiedTypes) {
    final data = <GraphQLType?>{}
      ..add(schema.queryType)
      ..addAll(specifiedTypes);

    if (schema.mutationType != null) {
      data.add(schema.mutationType);
    }

    if (schema.subscriptionType != null) {
      data.add(schema.subscriptionType);
    }

    data.forEach(_fetchAllTypesFromType);

    for (final sub in interfaces.keys) {
      final parents = interfaces[sub]!;
      var search = parents;

      while (search.isNotEmpty) {
        final grands = {for (final parent in search) ...?interfaces[parent]};

        parents.addAll(grands);
        search = grands;
      }
    }
  }

  CollectTypes.fromRootObject(GraphQLObjectType type) {
    _fetchAllTypesFromObject(type);
  }

  void _fetchAllTypesFromObject(GraphQLObjectType objectType) {
    if (traversedTypes.contains(objectType)) {
      return;
    }

    traversedTypes.add(objectType);

    for (var field in objectType.fields) {
      if (field.type is GraphQLObjectType) {
        _fetchAllTypesFromObject(field.type as GraphQLObjectType);
      } else if (field.type is GraphQLInputObjectType) {
        for (var v in (field.type as GraphQLInputObjectType).inputFields) {
          _fetchAllTypesFromType(v.type);
        }
      } else {
        _fetchAllTypesFromType(field.type);
      }

      for (var input in field.inputs) {
        _fetchAllTypesFromType(input.type);
      }
    }

    for (var i in objectType.possibleTypes) {
      (interfaces[i] ??= {}).add(objectType);
      _fetchAllTypesFromObject(i);
    }
  }

  void _fetchAllTypesFromType(GraphQLType? type) {
    if (traversedTypes.contains(type)) {
      return;
    }

    /*
     * Unwrap generics
     */
    if (type is GraphQLNonNullableType) {
      return _fetchAllTypesFromType(type.ofType);
    }
    if (type is GraphQLListType) {
      return _fetchAllTypesFromType(type.ofType);
    }

    /*
     * Handle simple types
     */
    if (type is GraphQLEnumType) {
      traversedTypes.add(type);
      return;
    }
    if (type is GraphQLUnionType) {
      traversedTypes.add(type);
      for (var t in type.possibleTypes) {
        _fetchAllTypesFromType(t);
      }
      return;
    }
    if (type is GraphQLInputObjectType) {
      traversedTypes.add(type);
      for (var v in type.inputFields) {
        _fetchAllTypesFromType(v.type);
      }
      return;
    }

    /*
     * defer to object type traverser
     */
    if (type is GraphQLObjectType) {
      return _fetchAllTypesFromObject(type);
    }

    return;
  }

  /// Performs introspection over a GraphQL [schema], and returns a one, containing
  /// introspective information.
  ///
  /// [allTypes] should contain all types, not directly defined in the schema, that you
  /// would like to have introspection available for.
  GraphQLSchema reflectSchema(
      GraphQLSchema schema, List<GraphQLType?> allTypes) {
    var typeType = _reflectSchemaTypes()!;
    var directiveType = _reflectDirectiveType();

    Set<GraphQLType?>? allTypeSet;

    var schemaType = GraphQLDynamicObjectType('__Schema', fields: [
      GraphQLObjectField(
        'types',
        listOf(typeType),
        resolve: (_, __) => (allTypeSet ??= allTypes.toSet()).toList(),
      ),
      GraphQLObjectField(
        'queryType',
        typeType,
        resolve: (_, __) => schema.queryType,
      ),
      GraphQLObjectField(
        'mutationType',
        typeType,
        resolve: (_, __) => schema.mutationType,
      ),
      GraphQLObjectField(
        'subscriptionType',
        typeType,
        resolve: (_, __) => schema.subscriptionType,
      ),
      GraphQLObjectField(
        'directives',
        listOf(directiveType),
        resolve: (_, __) =>
            schema.directiveTypes?.toList() ??
            [], // TODO: Actually fetch directives
      ),
    ]);

    allTypes.addAll([
      graphQLBoolean,
      graphQLString,
      graphQLId,
      graphQLDate,
      graphQLFloat,
      graphQLInt,
      directiveType,
      typeType,
      schemaType,
      _typeKindType,
      _directiveLocationType,
      _reflectFields(),
      _reflectInputValueType(),
      _reflectEnumValueType(),
    ]);

    var fields = <GraphQLObjectField>[
      GraphQLObjectField(
        '__schema',
        schemaType,
        resolve: (_, __) => schemaType,
      ),
      GraphQLObjectField(
        '__type',
        typeType,
        inputs: [GraphQLFieldInput('name', graphQLString.nonNullable())],
        resolve: (_, args) {
          var name = args['name'] as String?;
          return allTypes.firstWhere((t) => t!.name == name,
              orElse: () => throw GraphQLException.fromMessage(
                  'No type named "$name" exists.'));
        },
      ),
    ];

    fields.addAll(schema.queryType!.fields);

    return GraphQLSchema(
      queryType:
          GraphQLDynamicObjectType(schema.queryType!.name, fields: fields),
      mutationType: schema.mutationType,
      subscriptionType: schema.subscriptionType,
    );
  }

  GraphQLObjectType? _typeType;

  GraphQLObjectType? _reflectSchemaTypes() {
    if (_typeType == null) {
      _typeType = _createTypeType();
      _typeType!.fields.add(
        GraphQLObjectField(
          'ofType',
          _reflectSchemaTypes()!,
          resolve: (type, _) {
            if (type is GraphQLListType) {
              return type.ofType;
            } else if (type is GraphQLNonNullableType) {
              return type.ofType;
            }
            return null;
          },
        ),
      );

      _typeType!.fields.add(
        GraphQLObjectField(
          'interfaces',
          listOf(_reflectSchemaTypes()!.nonNullable()),
          resolve: (type, _) {
            if (type is GraphQLObjectType) {
              return interfaces[type] == null
                  ? const []
                  : (interfaces[type] as Iterable).toList();
            } else {
              return <GraphQLType>[];
            }
          },
        ),
      );

      _typeType!.fields.add(
        GraphQLObjectField(
          'possibleTypes',
          listOf(_reflectSchemaTypes()!.nonNullable()),
          resolve: (type, _) {
            if (type case GraphQLObjectType type when type.isInterface) {
              return type.possibleTypes;
            } else if (type case GraphQLUnionType type) {
              return type.possibleTypes;
            } else {
              return null;
            }
          },
        ),
      );

      var fieldType = _reflectFields()!;
      var inputValueType = _reflectInputValueType();
      var typeField =
          fieldType.fields.firstWhereOrNull((f) => f.name == 'type');

      if (typeField == null) {
        fieldType.fields.add(
          GraphQLObjectField(
            'type',
            _reflectSchemaTypes()!,
            resolve: (f, _) => (f as GraphQLObjectField).type,
          ),
        );
      }

      typeField =
          inputValueType.fields.firstWhereOrNull((f) => f.name == 'type');

      if (typeField == null) {
        inputValueType.fields.add(
          GraphQLObjectField(
            'type',
            _reflectSchemaTypes()!,
            resolve: (f, _) =>
                _fetchFromInputValue(f, (f) => f.type, (f) => f.type),
          ),
        );
      }
    }

    return _typeType;
  }

  bool isImplementationOf(GraphQLObjectType type, GraphQLObjectType other) {
    if (type == other) {
      return true;
    } else {
      final myInterfaces = interfaces[other];

      if (myInterfaces != null) {
        return myInterfaces.contains(type) ||
            myInterfaces.any((other) =>
                other is GraphQLObjectType && isImplementationOf(type, other));
      }
    }

    return false;
  }
}
