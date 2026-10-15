part of graphql_schema.src.schema;

/// `true` or `false`.
const GraphQLScalarType<bool, bool> graphQLBoolean = _GraphQLBoolType();

/// A UTF‐8 character sequence.
const GraphQLScalarType<String, String> graphQLString = _GraphQLStringType();

/// A string type that is validated to be an e-mail address
const graphQLEmail = GraphQLEmailType();

const graphQLUri = GraphQLUriType();

/// The ID scalar type represents a unique identifier, often used to re-fetch an object or as the key for a cache.
///
/// The ID type is serialized in the same way as a String; however, defining it as an ID signifies that it is not intended to be human‐readable.
const GraphQLScalarType<String, String> graphQLId =
    _GraphQLStringType(name: 'ID');

const graphQLNonEmptyString =
    GraphQLStringMinType(1, description: 'Non empty String');

_GraphQLStringType graphQLStringMin(int min) => GraphQLStringMinType(min);

_GraphQLStringType graphQLStringMax(int max) => GraphQLStringMaxType(max);

_GraphQLStringType graphQLStringRange(int min, int max) =>
    GraphQLStringRangeType(min, max);

/// A [DateTime], serialized as an ISO-8601 string..
const GraphQLScalarType<DateTime, String> graphQLDate = _GraphQLDateType._();

const GraphQLScalarType<String, String> graphQLStringDate =
    _GraphQLStringDateType._();

/// A signed 32‐bit integer.
const graphQLInt = GraphQLIntType();

const graphQLPositiveInt =
    GraphQLIntMinType(1, description: 'Positive integer (>= 1)');

const graphQLNonPositiveInt =
    GraphQLIntMaxType(0, description: 'Non positive integer (<= 0)');

const graphQLNegativeInt =
    GraphQLIntMaxType(-1, description: 'Negative integer (<= -1)');

const graphQLNonNegativeInt =
    GraphQLIntMinType(0, description: 'Non negative integer (>= 0)');

GraphQLIntMinType graphQLIntMin(int min) => GraphQLIntMinType(min);

GraphQLIntMaxType graphQLIntMax(int max) => GraphQLIntMaxType(max);

GraphQLIntRangedType graphQLIntRange(int min, int max) =>
    GraphQLIntRangedType(min, max);

/// A signed double-precision floating-point value.
const graphQLFloat = GraphQLFloatType();

abstract class GraphQLScalarType<Value, Serialized>
    extends GraphQLType<Value, Serialized>
    with _NonNullableMixin<Value, Serialized> {
  const GraphQLScalarType();

  Type get valueType => Value;
}

class _GraphQLBoolType extends GraphQLScalarType<bool, bool> {
  const _GraphQLBoolType();

  @override
  bool serialize(bool value) {
    return value;
  }

  @override
  String get name => 'Boolean';

  @override
  String get description => 'A boolean value; can be either true or false.';

  @override
  ValidationResult<bool> validate(String key, input) {
    if (input is! bool) {
      return ValidationResult._failure(['Expected "$key" to be a boolean.']);
    }
    return ValidationResult._ok(input);
  }

  @override
  bool deserialize(bool serialized) {
    return serialized;
  }

  @override
  GraphQLType<bool, bool> coerceToInputObject() => this;
}

class GraphQLIntType extends GraphQLScalarType<int, num> {
  const GraphQLIntType({this.description = ''});

  @override
  final String name = 'Int';
  @override
  final String description;

  @override
  ValidationResult<int> validate(String key, input) {
    if (input is! int?) {
      return ValidationResult._failure(
          ['Expected "$key" to be $name but is ${input.runtimeType}.']);
    }

    return ValidationResult._ok(input);
  }

  @override
  int deserialize(num serialized) {
    return serialized.toInt();
  }

  @override
  int sanitize(dynamic value) {
    return (value as num).toInt();
  }

  @override
  num serialize(int value) {
    return value;
  }

  @override
  GraphQLType<int, num> coerceToInputObject() => this;
}

class GraphQLFloatType extends GraphQLScalarType<double, num> {
  const GraphQLFloatType({this.description = ''});

  @override
  final String name = 'Float';
  @override
  final String description;

  @override
  ValidationResult<double> validate(String key, input) {
    if (input is! double?) {
      return ValidationResult._failure(
          ['Expected "$key" to be $name but is ${input.runtimeType}.']);
    }

    return ValidationResult._ok(input);
  }

  @override
  double deserialize(num serialized) {
    return serialized.toDouble();
  }

  @override
  double sanitize(dynamic value) {
    return (value as num).toDouble();
  }

  @override
  num serialize(double value) {
    return value;
  }

  @override
  GraphQLType<double, num> coerceToInputObject() => this;
}

class GraphQLIntMinType extends GraphQLIntType {
  const GraphQLIntMinType(this.min, {String? description})
      : super(description: description ?? 'Int with minimum of $min');

  final int min;

  @override
  ValidationResult<int> validate(String key, int input) {
    var ret = super.validate(key, input);

    if (ret.successful && input < min) {
      ret = ValidationResult._failure(
          ['Value ($input) can not be lower than $min']);
    }

    return ret;
  }
}

class GraphQLIntMaxType extends GraphQLIntType {
  const GraphQLIntMaxType(this.max, {String? description})
      : super(description: description ?? 'Int with maximum of $max');

  final int max;

  @override
  ValidationResult<int> validate(String key, int input) {
    var ret = super.validate(key, input);

    if (ret.successful && input > max) {
      ret = ValidationResult._failure(
          ['Value ($input) can not be greater than $max']);
    }

    return ret;
  }
}

class GraphQLIntRangedType extends GraphQLIntType {
  const GraphQLIntRangedType(this.min, this.max, {String? description})
      : super(
            description: description ??
                'Int between $min and $max. (>= $min && <= $max)');

  final int min;
  final int max;

  @override
  ValidationResult<int> validate(String key, int input) {
    var ret = super.validate(key, input);

    if (ret.successful && (input < min || input > max)) {
      ret = ValidationResult._failure([
        'Value ($input) must be between $min and $max. (>= $min && <= $max)'
      ]);
    }

    return ret;
  }
}

class _GraphQLStringType extends GraphQLScalarType<String, String> {
  const _GraphQLStringType(
      {this.name = 'String', this.description = 'A character sequence.'});

  @override
  final String name;

  @override
  final String description;

  @override
  String serialize(String value) => value;

  @override
  String deserialize(String serialized) => serialized;

  @override
  ValidationResult<String> validate(String key, input) => input is String
      ? ValidationResult<String>._ok(input)
      : ValidationResult._failure(['Expected "$key" to be a string.']);

  @override
  GraphQLType<String, String> coerceToInputObject() => this;
}

class GraphQLEmailType extends _GraphQLStringType {
  const GraphQLEmailType({super.description = 'A working e-mail address.'});

  @override
  ValidationResult<String> validate(String key, input) {
    final ret = super.validate(key, input);

    if (ret.successful) {
      return ev.EmailValidator.validate(input)
          ? ValidationResult<String>._ok(input)
          : ValidationResult._failure(
              ['Expected "$key" to be an e-mail address.']);
    }

    return ret;
  }
}

class GraphQLUriType extends GraphQLScalarType<Uri, String> {
  const GraphQLUriType();

  @override
  String serialize(dynamic value) {
    return value.toString();
  }

  @override
  String get name => 'Uri';

  @override
  String get description => 'A valid URI address.';

  @override
  ValidationResult<String> validate(String key, input) {
    if (input is! String) {
      return ValidationResult._failure(['Expected "$key" to be a string.']);
    }

    return validator.isURL(input)
        ? ValidationResult<String>._ok(input)
        : ValidationResult._failure(['Expected "$key" to be valid URI.']);
  }

  @override
  Uri deserialize(String serialized) {
    return Uri.parse(serialized);
  }

  @override
  GraphQLType<Uri, String> coerceToInputObject() => this;
}

class GraphQLStringMinType extends _GraphQLStringType {
  const GraphQLStringMinType(this.min,
      {String? description, String name = 'String'})
      : super(
            name: name,
            description:
                description ?? '$name with minimum of $min characters');

  final int min;

  @override
  ValidationResult<String> validate(String key, String input) {
    var ret = super.validate(key, input);

    if (ret.successful && input.length < min) {
      ret = ValidationResult._failure(
          ['Value (${input.length} chars) can not be lower than $min']);
    }

    return ret;
  }
}

class GraphQLStringMaxType extends _GraphQLStringType {
  const GraphQLStringMaxType(this.max,
      {String? description, String name = 'String'})
      : super(
            name: name,
            description: description ?? '$name with max of $max characters');

  final int max;

  @override
  ValidationResult<String> validate(String key, String input) {
    var ret = super.validate(key, input);

    if (ret.successful && input.length > max) {
      ret = ValidationResult._failure(
          ['Value (${input.length} chars) can not be greater than $max']);
    }

    return ret;
  }
}

class GraphQLStringRangeType extends _GraphQLStringType {
  const GraphQLStringRangeType(this.min, this.max,
      {String? description, String name = 'String'})
      : super(
            name: name,
            description:
                description ?? '$name with characters between $min and $max');

  final int min;
  final int max;

  @override
  ValidationResult<String> validate(String key, String input) {
    var ret = super.validate(key, input);

    if (ret.successful && (input.length < min || input.length > max)) {
      ret = ValidationResult._failure([
        'Value (${input.length} chars) must have between $min and $max chars'
      ]);
    }

    return ret;
  }
}

class _GraphQLDateType extends GraphQLScalarType<DateTime, String>
    with _NonNullableMixin<DateTime, String> {
  const _GraphQLDateType._();

  @override
  String get name => 'Date';

  @override
  String get description => 'An ISO-8601 Date.';

  @override
  String serialize(DateTime value) => value.toIso8601String();

  @override
  DateTime deserialize(String serialized) => DateTime.parse(serialized);

  @override
  String? convert(dynamic value) =>
      value == null ? null : (value as DateTime).toString();

  @override
  ValidationResult<String> validate(String key, input) {
    if (input is! String) {
      return ValidationResult<String>._failure(
          ['$key must be an ISO 8601-formatted date string.']);
    }

    try {
      DateTime.parse(input);
      return ValidationResult<String>._ok(input);
    } on FormatException {
      return ValidationResult<String>._failure(
          ['$key must be an ISO 8601-formatted date string.']);
    }
  }

  @override
  GraphQLType<DateTime, String> coerceToInputObject() => this;
}

class _GraphQLStringDateType extends GraphQLScalarType<String, String>
    with _NonNullableMixin<String, String> {
  const _GraphQLStringDateType._();

  @override
  String get name => 'Date';

  @override
  String get description => 'An ISO-8601 Date.';

  @override
  String serialize(String value) => value;

  @override
  String deserialize(String serialized) => serialized;

  @override
  String? convert(dynamic value) => value == null ? null : (value as String);

  @override
  ValidationResult<String> validate(String key, input) {
    if (input is! String) {
      return ValidationResult<String>._failure(
          ['$key must be an ISO 8601-formatted date string.']);
    }

    try {
      DateTime.parse(input);
      return ValidationResult<String>._ok(input);
    } on FormatException {
      return ValidationResult<String>._failure(
          ['$key must be an ISO 8601-formatted date string.']);
    }
  }

  @override
  GraphQLType<String, String> coerceToInputObject() => this;
}
