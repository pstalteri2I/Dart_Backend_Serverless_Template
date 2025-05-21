import 'package:aws_dynamodb_api/dynamodb-2012-08-10.dart';

Map<String, dynamic> unmarshal(Map<String, AttributeValue> data) {
  final toReturn = <String, dynamic>{};
  data.forEach((key, value) {
    toReturn[key] = getAttributeValueValue(value);
  });
  return toReturn;
}

dynamic getAttributeValueValue(AttributeValue value) {
  if (value.b != null) {
    return value.b;
  } else if (value.bs != null) {
    return value.bs;
  } else if (value.l != null) {
    return List.from(value.l!.map<dynamic>((e) => getAttributeValueValue(e)));
  } else if (value.m != null) {
    return unmarshal(value.m!);
  } else if (value.n != null) {
    return num.parse(value.n!);
  } else if (value.ns != null) {
    return value.ns;
  } else if (value.s != null) {
    return value.s;
  } else if (value.ss != null) {
    return value.ss;
  } else if (value.boolValue != null) {
    return value.boolValue;
  } else if (value.nullValue != null) {
    return null;
  }
}
