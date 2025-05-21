import 'dart:typed_data';

import 'package:aws_dynamodb_api/dynamodb-2012-08-10.dart';

Map<String, AttributeValue> marshall(Map<String, dynamic> data) {
  final toReturn = <String, AttributeValue>{};
  data.forEach((key, value) {
    toReturn[key] = getMapValue(value);
  });
  return toReturn;
}

AttributeValue getMapValue(dynamic value) {
  if (value is Uint8List) {
    return AttributeValue(b: value);
  } else if (value is List<Uint8List>) {
    return AttributeValue(bs: value);
  } else if (value is List) {
    return AttributeValue(l: List.from(value.map((e) => getMapValue(e))));
  } else if (value is Map) {
    return AttributeValue(m: marshall(value as Map<String, dynamic>));
  } else if (value is bool) {
    return AttributeValue(boolValue: value);
  } else if (value is String) {
    return AttributeValue(s: value);
  } else if (value is num) {
    return AttributeValue(n: value.toString());
  } else {
    return AttributeValue(nullValue: true);
  }
}
