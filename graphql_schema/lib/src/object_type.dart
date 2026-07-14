part of graphql_schema.src.schema;

typedef StringPair = ({String key, String value});

mixin GraphQLFixedType<T, V> on GraphQLObjectType<T, V> {}

class GraphQLStringPairType extends GraphQLObjectType<StringPair, String>
    with GraphQLFixedType {
  const GraphQLStringPairType(
      {super.description,
      super.polymorphicName,
      super.possibleTypes = const []})
      : super(
          'StringPair',
          isInterface: false,
        );

  @override
  final List<GraphQLObjectField> fields = const [
    GraphQLObjectField(
      'key',
      graphQLString,
    ),
    GraphQLObjectField('value', graphQLString),
  ];

  @override
  GraphQLType<StringPair, Map<String, String>> coerceToInputObject() {
    return GraphQLInputStringPairType('${name}Input', description: description);
  }

  @override
  Map<String, String> serialize(StringPair value) {
    //print('SERIALIZE!! $value');
    return {'key': value.key, 'value': value.value};
  }

  @override
  StringPair deserialize(Map<String, String> serialized) {
    //print('DESERIALIZE!! $serialized');
    final errKey = serialized.keys.firstWhereOrNull(
        (k) => fields.firstWhereOrNull((f) => f.name == k) == null);

    if (errKey != null) {
      throw UnsupportedError('Unexpected field "$errKey" encountered in map.');
    }

    return (
      key: serialized['key'] as String,
      value: serialized['value'] as String
    );
  }
}

class GraphQLInputStringPairType
    extends GraphQLInputObjectType<StringPair, String> {
  const GraphQLInputStringPairType(super.name,
      {super.description, this.inputFields = const []});

  @override
  final Iterable<GraphQLInputObjectField> inputFields;

  @override
  Map<String, String> serialize(StringPair pair) {
    return {'key': pair.key, 'value': pair.value};
  }

  @override
  StringPair deserialize(Map<String, String> serialized) {
    final errKey = serialized.keys.firstWhereOrNull(
        (k) => inputFields.firstWhereOrNull((f) => f.name == k) == null);

    if (errKey != null) {
      throw UnsupportedError('Unexpected field "$errKey" encountered in map.');
    }

    return (
      key: serialized['key'] as String,
      value: serialized['value'] as String
    );
  }
}

class GraphQLDynamicObjectType
    extends GraphQLObjectType<Map<String, dynamic>, dynamic> {
  const GraphQLDynamicObjectType(super.name,
      {this.fields = const [],
      super.description,
      super.isInterface = false,
      super.polymorphicName,
      super.possibleTypes = const [],
      super.findTypeFromResult});

  @override
  final List<GraphQLObjectField> fields;

  @override
  GraphQLType<Map<String, dynamic>, Map<String, dynamic>>
      coerceToInputObject() {
    return toInputObject('${name}Input',
        description: description, descriptionThunk: descriptionThunk);
  }

  @override
  Map<String, dynamic> serialize(Map value) {
    return value.keys.fold<Map<String, dynamic>>({}, (out, k) {
      var field = fields.firstWhereOrNull((f) => f.name == k);
      if (field == null) {
        throw UnsupportedError(
            'Cannot serialize field "$k", which was not defined in the schema.');
      }
      return out..[k.toString()] = field.serialize(value[k]);
    });
  }

  @override
  Map<String, dynamic> deserialize(Map serialized) {
    return serialized.keys.fold<Map<String, dynamic>>({}, (out, k) {
      var field = fields.firstWhereOrNull((f) => f.name == k);
      if (field == null) {
        throw UnsupportedError(
            'Unexpected field "$k" encountered in map. Allowed on $this: ${fields.map((f) => f.name).join(', ')}');
      }
      return out
        ..[k.toString()] = field.deserialize(field.type.convert(serialized[k]));
    });
  }
}

/// A [GraphQLType] that specifies the shape of structured data, with multiple fields that can be resolved independently of one another.
abstract class GraphQLObjectType<T, V> extends GraphQLType<T, Map<String, V>>
    with _NonNullableMixin<T, Map<String, V>> {
  /// The name of this type.
  @override
  final String name;

  final String? polymorphicName;

  /// An optional description of this type; useful for tools like GraphiQL.
  @override
  final String? description;

  /// Optional lazy localizable description (i18n) — see [GraphQLBaseType.descriptionThunk].
  @override
  final String Function()? descriptionThunk;

  /// The list of fields that an object of this type is expected to have.
  List<GraphQLObjectField> get fields;

  /// `true` if this type should be treated as an *interface*, which child types can [inheritFrom].
  ///
  /// In GraphQL, the parent class is *aware* of all the [possibleTypes] that can implement it.
  final bool isInterface;

  //final List<GraphQLObjectType> interfaces;

  final List<GraphQLObjectType> possibleTypes;

  final GraphQLObjectType? Function(Map<String, V> result)? findTypeFromResult;

  const GraphQLObjectType(this.name,
      {this.description,
      this.descriptionThunk,
      this.isInterface = false,
      this.polymorphicName,
      this.possibleTypes = const [],
      this.findTypeFromResult});

  /// Converts [this] into a [GraphQLInputObjectType].
  GraphQLInputDynamicObjectType toInputObject(String name,
      {String? description, String Function()? descriptionThunk}) {
    return GraphQLInputDynamicObjectType(name,
        description: description ?? this.description,
        descriptionThunk: descriptionThunk ?? this.descriptionThunk,
        inputFields: fields.map((f) => GraphQLInputObjectField(
            f.name, f.type.coerceToInputObject(),
            description: f.description,
            descriptionThunk: f.descriptionThunk)));
  }

  /// Declares that this type inherits from another parent type.
  ///
  /// This also has the side effect of notifying the parent that this type is its descendant.
  // void inheritFrom(GraphQLObjectType other) {
  //   if (!_interfaces.contains(other)) {
  //     _interfaces.add(other);
  //     other._possibleTypes.add(this);
  //     other._interfaces.forEach(inheritFrom);
  //   }
  // }

  GraphQLObjectType findBetterType(String key, Map input) {
    if (isInterface) {
      for (var type in possibleTypes) {
        var result = type.validate(key, input);
        if (result.successful) {
          return type;
        }
      }
    }

    return this;
  }

  @override
  ValidationResult<Map<String, dynamic>> validate(String key, Object? input) {
    if (input is! Map) {
      return ValidationResult._failure(['Expected "$key" to be a Map.']);
    }

    if (isInterface) {
      var errors = <String>[];

      for (var type in possibleTypes) {
        var result = type.validate(key, input);
        if (result.successful) {
          return result;
        } else {
          errors.addAll(result.errors);
        }
      }

      return ValidationResult<Map<String, dynamic>>._failure(errors);
    }

    var out = {};
    var errors = <String>[];

    for (var field in fields) {
      if (field.type is GraphQLNonNullableType) {
        if (!input.containsKey(field.name) || input[field.name] == null) {
          errors.add(
              'Field "${field.name}, of type ${field.type} cannot be null."');
        }
      }
    }

    for (var k in input.keys) {
      var field = fields.firstWhereOrNull((f) => f.name == k);

      if (field == null) {
        errors.add(
            'Unexpected field "$k" encountered in $key. Accepted values on type $name: ${fields.map((f) => f.name).toList()}');
      } else {
        var v = input[k];
        final converted = field.type.convert(v);
        var result = field.type.validate(k.toString(), converted);

        if (!result.successful) {
          errors.addAll(result.errors.map((s) => '$key: $s'));
        } else {
          out[k] = v;
        }
      }
    }

    if (errors.isNotEmpty) {
      return ValidationResult._failure(errors);
    } else {
      return ValidationResult._ok(_foldToStringDynamic(out));
    }
  }

  /// Returns `true` if this type, or any of its parents, is a direct descendant of another given [type].
  // bool isImplementationOf(GraphQLObjectType type) {
  //   if (type == this) {
  //     return true;
  //   } else if (interfaces.contains(type)) {
  //     return true;
  //   } else if (interfaces.isNotEmpty) {
  //     return interfaces.any((t) => t.isImplementationOf(type));
  //   } else {
  //     return false;
  //   }
  // }

  @override
  bool operator ==(other) {
    return other is GraphQLObjectType &&
        other.name == name &&
        other.description == description &&
        other.isInterface == isInterface &&
        const ListEquality<GraphQLObjectField>().equals(other.fields, fields)
//        const ListEquality<GraphQLObjectType>() Removed, as it causes a stack overflow :(
//            .equals(other.interfaces, interfaces) &&
        &&
        const ListEquality<GraphQLObjectType>()
            .equals(other.possibleTypes, possibleTypes);
  }
}

Map<String, dynamic> _foldToStringDynamic(Map map) {
  return map.keys.fold<Map<String, dynamic>>(
      <String, dynamic>{}, (out, k) => out..[k.toString()] = map[k]);
}

enum DirectiveLocation {
  query,
  mutation,
  subscription,
  field,
  fragmentDefinition,
  fragmentSpread,
  inlineFragment,
  variableDefinition
}

class GraphQLDirectiveType extends GraphQLInputDynamicObjectType {
  const GraphQLDirectiveType(String name,
      {String? description,
      required this.locations,
      Iterable<GraphQLInputObjectField> inputFields = const []})
      : super(name, description: description, inputFields: inputFields);

  final Set<DirectiveLocation> locations;
}

class GraphQLInputDynamicObjectType
    extends GraphQLInputObjectType<Map<String, dynamic>, dynamic> {
  const GraphQLInputDynamicObjectType(super.name,
      {super.description, super.descriptionThunk, this.inputFields = const []});

  @override
  final Iterable<GraphQLInputObjectField> inputFields;

  @override
  Map<String, dynamic> serialize(Map<String, dynamic> value) {
    return value.keys.fold<Map<String, dynamic>>({}, (out, k) {
      var field = inputFields.firstWhereOrNull((f) => f.name == k);
      if (field == null) {
        throw UnsupportedError(
            'Cannot serialize field "$k", which was not defined in the schema.');
      }
      return out..[k.toString()] = field.type.serialize(value[k]);
    });
  }

  @override
  Map<String, dynamic> deserialize(Map<String, dynamic> serialized) {
    return serialized.keys.fold<Map<String, dynamic>>({}, (out, k) {
      var field = inputFields.firstWhereOrNull((f) => f.name == k);
      if (field == null) {
        throw UnsupportedError('Unexpected field "$k" encountered in map.');
      }
      var sval = serialized[k];

      if (sval != null) {
        sval = field.type.deserialize(sval);
      }

      return out..[k.toString()] = sval;
    });
  }
}

/// A special [GraphQLType] that specifies the shape of an object that can only be used as an input to a [GraphQLField].
///
/// GraphQL input object types are different from regular [GraphQLObjectType]s in that they do not support resolution,
/// and are overall more limiter in utility, because their only purpose is to reduce the number of parameters to a given field,
/// and to potentially reuse an input structure across multiple fields in the hierarchy.
abstract class GraphQLInputObjectType<T, V>
    extends GraphQLType<T, Map<String, V>>
    with _NonNullableMixin<T, Map<String, V>> {
  /// The name of this type.
  @override
  final String name;

  /// An optional type of this type, which is useful for tools like GraphiQL.
  @override
  final String? description;

  /// Optional lazy localizable description (i18n) — see [GraphQLBaseType.descriptionThunk].
  @override
  final String Function()? descriptionThunk;

  /// A list of the fields that an input object of this type is expected to have.
  Iterable<GraphQLInputObjectField> get inputFields;

  const GraphQLInputObjectType(this.name,
      {this.description, this.descriptionThunk});

  @override
  ValidationResult validate(String key, Map input) {
    var out = {};
    var errors = <String>[];

    for (var field in inputFields) {
      if (field.type is GraphQLNonNullableType) {
        if (!input.containsKey(field.name) || input[field.name] == null) {
          errors.add(
              'Field "${field.name}, of type ${field.type} cannot be null."');
        }
      }
    }

    for (var k in input.keys) {
      var field = inputFields.firstWhereOrNull((f) => f.name == k);

      if (field == null) {
        errors.add(
            'Unexpected field "$k" encountered in $key. Accepted values on type $name: ${inputFields.map((f) => f.name).toList()}');
      } else {
        final ov = input[k];
        final v = ov == null ? null : field.type.sanitize(ov);
        ValidationResult result;

        if (v == null ||
            (result = field.type.validate(k.toString(), v)).successful) {
          out[k] = v;
        } else {
          errors.addAll(result.errors.map((s) => '$key: $s'));
        }
      }
    }

    if (errors.isNotEmpty) {
      return ValidationResult._failure(errors);
    } else {
      return ValidationResult._ok(_foldToStringDynamic(out));
    }
  }

  @override
  bool operator ==(other) {
    return other is GraphQLInputObjectType &&
        other.name == name &&
        other.description == description &&
        const IterableEquality<GraphQLInputObjectField>()
            .equals(other.inputFields, inputFields);
  }

  @override
  GraphQLType<T, Map<String, V>> coerceToInputObject() => this;
}

/// A field expected within a [GraphQLInputObjectType].
class GraphQLInputObjectField<Value, Serialized> implements GraphQLBaseType {
  /// The name of this field.
  final String name;

  /// The type that a value for this field is validated against.
  final GraphQLType<Value, Serialized> type;

  /// A description of this field, which is useful for tools like GraphiQL.
  final String? description;

  /// Optional lazy localizable description (i18n) — see [GraphQLBaseType.descriptionThunk].
  @override
  final String Function()? descriptionThunk;

  /// An optional default value for this field in an input object.
  final Value? defaultValue;

  /// If [defaultValue] is `null`, and `null` is a valid value for this parameter, set this to `true`.
  final bool defaultsToNull;

  const GraphQLInputObjectField(this.name, this.type,
      {this.description,
      this.descriptionThunk,
      this.defaultValue,
      this.defaultsToNull = false});

  @override
  bool operator ==(other) =>
      other is GraphQLInputObjectField &&
      other.name == name &&
      other.type == type &&
      other.description == description &&
      other.defaultValue == defaultValue;
}
