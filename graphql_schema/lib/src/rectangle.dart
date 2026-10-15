part of graphql_schema.src.schema;

const graphQLFloatRectangle = GraphQLMapRectangleObjectType<double>(
    'FloatRectangle',
    axisType: GraphQLFloatType());

const graphQLIntRectangle = GraphQLMapRectangleObjectType<int>('IntRectangle',
    axisType: GraphQLIntType());

mixin GraphQLRectangleObject<N extends num> {
  String get xAxis;
  String get yAxis;
  String get xSize;
  String get ySize;

  Map<String, N>? convert(value) {
    final ret = switch (value) {
      Map<String, N>() => value,
      Map() || Map<String, dynamic>() => value.cast<String, N>(),
      Rectangle<N>() => serialize(value),
      _ => value
    };

    return ret;
  }

  Map<String, N> serialize(dynamic value) {
    final ret = switch (value) {
      Map<String, N>() => value,
      Map() || Map<String, dynamic>() => value.cast<String, N>(),
      Rectangle<N>() => {
          xAxis: value.left,
          yAxis: value.top,
          xSize: value.width,
          ySize: value.height
        },
      _ => value
    };

    return ret;
  }

  Rectangle<N> deserialize(Map serialized) {
    return Rectangle<N>(
        (serialized[xAxis] ?? 0) as N,
        (serialized[xAxis] ?? 0) as N,
        (serialized[xSize] ?? 0) as N,
        (serialized[ySize] ?? 0) as N);
  }
}

class GraphQLRectangleObjectType<N extends num>
    extends GraphQLObjectType<Rectangle<N>, N>
    with GraphQLRectangleObject<N>, GraphQLFixedType {
  const GraphQLRectangleObjectType(super.name,
      {super.description,
      super.isInterface = false,
      super.polymorphicName,
      super.possibleTypes = const [],
      required this.axisType,
      this.yAxis = 'left',
      this.xAxis = 'top',
      this.xSize = 'width',
      this.ySize = 'height'});

  @override
  List<GraphQLObjectField> get fields => [
        GraphQLObjectField(xAxis, axisType),
        GraphQLObjectField(yAxis, axisType),
        GraphQLObjectField(xSize, axisType),
        GraphQLObjectField(ySize, axisType)
      ];

  @override
  final String xAxis;
  @override
  final String yAxis;
  @override
  final String xSize;
  @override
  final String ySize;
  final GraphQLScalarType axisType;

  @override
  GraphQLType<Rectangle<N>, Map<String, N>> coerceToInputObject() {
    return GraphQLRectangleInputObjectType('${name}Input',
        axisType: axisType,
        xAxis: xAxis,
        yAxis: yAxis,
        xSize: xSize,
        ySize: ySize);
  }
}

class GraphQLRectangleInputObjectType<N extends num>
    extends GraphQLInputObjectType<Rectangle<N>, N>
    with GraphQLRectangleObject<N> {
  const GraphQLRectangleInputObjectType(super.name,
      {super.description,
      required this.axisType,
      required this.xAxis,
      required this.yAxis,
      required this.xSize,
      required this.ySize});

  @override
  Iterable<GraphQLInputObjectField> get inputFields => [
        GraphQLInputObjectField(xAxis, axisType),
        GraphQLInputObjectField(yAxis, axisType)
      ];

  @override
  final String xAxis;
  @override
  final String yAxis;
  @override
  final String xSize;
  @override
  final String ySize;
  final GraphQLScalarType axisType;
}

mixin GraphQLMapRectangleObject<N extends num> {
  String get xAxis;
  String get yAxis;
  String get xSize;
  String get ySize;

  Map<String, N>? convert(value) {
    final ret = switch (value) {
      Map<String, N>() => value,
      Map() || Map<String, dynamic>() => value.cast<String, N>(),
      _ => value
    };

    return ret;
  }

  Map<String, N> serialize(Map value) {
    return value.cast<String, N>();
  }

  Map<String, N> deserialize(Map serialized) {
    return serialized.cast<String, N>();
  }
}

const graphQLFloatMapRectangle = GraphQLMapRectangleObjectType<double>(
    'FloatMapRectangle',
    axisType: GraphQLFloatType());

const graphQLIntMapRectangle = GraphQLMapRectangleObjectType<int>(
    'IntMapRectangle',
    axisType: GraphQLIntType());

class GraphQLMapRectangleObjectType<N extends num>
    extends GraphQLObjectType<Map<String, N>, N>
    with GraphQLMapRectangleObject<N>, GraphQLFixedType {
  const GraphQLMapRectangleObjectType(super.name,
      {super.description,
      super.isInterface = false,
      super.polymorphicName,
      super.possibleTypes = const [],
      required this.axisType,
      this.yAxis = 'left',
      this.xAxis = 'top',
      this.xSize = 'width',
      this.ySize = 'height'});

  @override
  List<GraphQLObjectField> get fields => [
        GraphQLObjectField(xAxis, axisType),
        GraphQLObjectField(yAxis, axisType),
        GraphQLObjectField(xSize, axisType),
        GraphQLObjectField(ySize, axisType)
      ];

  @override
  final String xAxis;
  @override
  final String yAxis;
  @override
  final String xSize;
  @override
  final String ySize;
  final GraphQLScalarType axisType;

  @override
  GraphQLType<Map<String, N>, Map<String, N>> coerceToInputObject() {
    return GraphQLMapRectangleInputObjectType('${name}Input',
        axisType: axisType,
        xAxis: xAxis,
        yAxis: yAxis,
        xSize: xSize,
        ySize: ySize);
  }
}

class GraphQLMapRectangleInputObjectType<N extends num>
    extends GraphQLInputObjectType<Map<String, N>, N>
    with GraphQLMapRectangleObject<N> {
  const GraphQLMapRectangleInputObjectType(super.name,
      {super.description,
      required this.axisType,
      required this.xAxis,
      required this.yAxis,
      required this.xSize,
      required this.ySize});

  @override
  final String xAxis;
  @override
  final String yAxis;
  @override
  final String xSize;
  @override
  final String ySize;
  final GraphQLScalarType axisType;

  @override
  Iterable<GraphQLInputObjectField> get inputFields => [
        GraphQLInputObjectField(xAxis, axisType),
        GraphQLInputObjectField(yAxis, axisType),
        GraphQLInputObjectField(xSize, axisType),
        GraphQLInputObjectField(ySize, axisType)
      ];
}
