part of graphql_schema.src.schema;

typedef Pair<N extends num> = Map<String, N>;

const graphQLFloatPoint =
    GraphQLPointObjectType<double>('FloatPoint', axisType: GraphQLFloatType());

const graphQLFloatMapPoint = GraphQLMapPointObjectType<double>('FloatMapPoint',
    axisType: GraphQLFloatType());

mixin GraphQLPointObject<N extends num> {
  String get xAxis;
  String get yAxis;

  Map<String, N>? convert(value) => switch (value) {
        Map<String, N>() => value,
        Map() => value.cast<String, N>(),
        _ => value
      };

  Map<String, N> serialize(dynamic value) => switch (value) {
        Map<String, N>() => value,
        Map() => value.cast<String, N>(),
        Point<N>() => {xAxis: value.x, yAxis: value.y},
        _ => value
      };

  Point<N> deserialize(Map<String, N> serialized) {
    return Point<N>(
        (serialized[xAxis] ?? 0) as N, (serialized[xAxis] ?? 0) as N);
  }
}

mixin GraphQLMapPointObject<N extends num> {
  String get xAxis;
  String get yAxis;

  Map<String, N>? convert(value) => switch (value) {
        Map<String, N>() => value,
        Map() => value.cast<String, N>(),
        _ => value
      };

  Map<String, N> serialize(Map<String, N> value) {
    return value;
  }

  Map<String, N> deserialize(Map<String, N> serialized) {
    return serialized;
  }
}

class GraphQLPointObjectType<N extends num>
    extends GraphQLObjectType<Point<N>, N> with GraphQLPointObject<N> {
  const GraphQLPointObjectType(super.name,
      {super.description,
      super.isInterface = false,
      super.polymorphicName,
      super.possibleTypes = const [],
      required this.axisType,
      this.xAxis = 'x',
      this.yAxis = 'y'});

  @override
  List<GraphQLObjectField> get fields => [
        GraphQLObjectField(xAxis, axisType),
        GraphQLObjectField(yAxis, axisType)
      ];

  @override
  final String xAxis;
  @override
  final String yAxis;
  final GraphQLScalarType axisType;

  @override
  GraphQLType<Point<N>, Map<String, N>> coerceToInputObject() {
    return GraphQLPointInputObjectType('${name}Input',
        axisType: axisType, xAxis: xAxis, yAxis: yAxis);
  }
}

class GraphQLMapPointObjectType<N extends num>
    extends GraphQLObjectType<Map<String, N>, N> with GraphQLMapPointObject<N> {
  const GraphQLMapPointObjectType(super.name,
      {super.description,
      super.isInterface = false,
      super.polymorphicName,
      super.possibleTypes = const [],
      required this.axisType,
      this.xAxis = 'x',
      this.yAxis = 'y'});

  @override
  List<GraphQLObjectField> get fields => [
        GraphQLObjectField(xAxis, axisType),
        GraphQLObjectField(yAxis, axisType)
      ];

  @override
  final String xAxis;
  @override
  final String yAxis;
  final GraphQLScalarType axisType;

  @override
  GraphQLType<Map<String, N>, Map<String, N>> coerceToInputObject() {
    return GraphQLMapPointInputObjectType('${name}Input',
        axisType: axisType, xAxis: xAxis, yAxis: yAxis);
  }
}

class GraphQLPointInputObjectType<N extends num>
    extends GraphQLInputObjectType<Point<N>, N> with GraphQLPointObject<N> {
  const GraphQLPointInputObjectType(super.name,
      {super.description,
      required this.axisType,
      required this.xAxis,
      required this.yAxis});

  @override
  Iterable<GraphQLInputObjectField> get inputFields => [
        GraphQLInputObjectField(xAxis, axisType),
        GraphQLInputObjectField(yAxis, axisType)
      ];

  @override
  final String xAxis;
  @override
  final String yAxis;
  final GraphQLScalarType axisType;
}

class GraphQLMapPointInputObjectType<N extends num>
    extends GraphQLInputObjectType<Map<String, N>, N>
    with GraphQLMapPointObject<N> {
  const GraphQLMapPointInputObjectType(super.name,
      {super.description,
      required this.axisType,
      required this.xAxis,
      required this.yAxis});

  @override
  Iterable<GraphQLInputObjectField> get inputFields => [
        GraphQLInputObjectField(xAxis, axisType),
        GraphQLInputObjectField(yAxis, axisType)
      ];

  @override
  final String xAxis;
  @override
  final String yAxis;
  final GraphQLScalarType axisType;
}
