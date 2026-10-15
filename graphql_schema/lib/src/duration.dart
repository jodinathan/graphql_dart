part of graphql_schema.src.schema;

const graphQLDuration = GraphQLDurationType('Duration');

class GraphQLDurationType extends GraphQLObjectType<Duration, int> {
  const GraphQLDurationType(
    super.name, {
    super.description,
    super.isInterface = false,
    super.polymorphicName,
    super.possibleTypes = const [],
  });

  @override
  List<GraphQLObjectField> get fields => [
        GraphQLObjectField('inDays', graphQLInt),
        GraphQLObjectField('inHours', graphQLInt),
        GraphQLObjectField('inMinutes', graphQLInt),
        GraphQLObjectField('inSeconds', graphQLInt),
        GraphQLObjectField('inMilliseconds', graphQLInt),
        GraphQLObjectField('inMicroseconds', graphQLInt),
      ];

  @override
  Map<String, int> serialize(Duration value) {
    return {
      'inDays': value.inDays,
      'inHours': value.inHours,
      'inMinutes': value.inMinutes,
      'inSeconds': value.inSeconds,
      'inMilliseconds': value.inMilliseconds,
      'inMicroseconds': value.inMicroseconds,
    };
  }

  @override
  Duration deserialize(Map<String, int> serialized) {
    return Duration(microseconds: serialized['inMicroseconds'] ?? 0);
  }

  @override
  GraphQLType<Duration, Map<String, int>> coerceToInputObject() {
    return GraphQLDurationInputType('${name}Input');
  }
}

class GraphQLDurationInputType extends GraphQLInputObjectType<Duration, int> {
  const GraphQLDurationInputType(
    super.name, {
    super.description,
  });

  @override
  Iterable<GraphQLInputObjectField> get inputFields => [
        GraphQLInputObjectField('days', graphQLInt),
        GraphQLInputObjectField('hours', graphQLInt),
        GraphQLInputObjectField('minutes', graphQLInt),
        GraphQLInputObjectField('seconds', graphQLInt),
        GraphQLInputObjectField('milliseconds', graphQLInt),
        GraphQLInputObjectField('microseconds', graphQLInt),
      ];

  @override
  Map<String, int> serialize(Duration value) {
    return {
      'days': value.inDays,
      'hours': value.inHours % 24,
      'minutes': value.inMinutes % 60,
      'seconds': value.inSeconds % 60,
      'milliseconds': value.inMilliseconds % 1000,
      'microseconds': value.inMicroseconds % 1000,
    };
  }

  @override
  Duration deserialize(Map<String, int> serialized) {
    return Duration(
      days: serialized['days'] ?? 0,
      hours: serialized['hours'] ?? 0,
      minutes: serialized['minutes'] ?? 0,
      seconds: serialized['seconds'] ?? 0,
      milliseconds: serialized['milliseconds'] ?? 0,
      microseconds: serialized['microseconds'] ?? 0,
    );
  }
}
