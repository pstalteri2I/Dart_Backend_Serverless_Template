import 'dart:convert';
import 'package:aws_lambda_dart_runtime/aws_lambda_dart_runtime.dart';
import 'package:aws_lambda_dart_runtime/runtime/context.dart';
import 'package:aws_client/dynamo_db_2012_08_10.dart';
import 'package:dart_template/marshal.dart';
import 'package:dart_template/models/pokemon.dart';
import 'package:dart_template/unmarshal.dart';
import 'package:aws_client/s3_2006_03_01.dart';

Future<AwsApiGatewayResponse> patchPokemon(
  Context context,
  AwsApiGatewayEvent event,
) async {
  try {
    final db = DynamoDB(region: context.region!);

    final pokemonID = event.pathParameters!['pokemonID'];
    final body = jsonDecode(event.body!);

    String? urlImage;
    if (body['image'] != null && body['image'].toString().contains(',')) {
      final base64String = body['image'].split(',').last;
      final imageData = base64Decode(base64String);

      final header = body['image'].split(',').first;
      final contentType = header.split(':').last.split(';').first;
      final key = "$pokemonID.${contentType.split("/").last}";

      final s3 = S3(region: context.region!);
      await s3.putObject(
        bucket: 'pie-nele-bucket',
        key: key,
        body: imageData,
        contentType: contentType,
      );
      urlImage =
          'https://pie-nele-bucket.s3.amazonaws.com/$pokemonID.${contentType.split("/").last}';
      s3.close();
    }

    String expression = "";

    if (body['name'] != null ||
        body['type'] != null ||
        body['type2'] != null ||
        urlImage != null) {
      expression = "SET ";
      if (body['name'] != null) {
        expression += "#name = :name, ";
      }
      if (body['type'] != null) {
        expression += "#type = :type, ";
      }
      if (body['type2'] != null) {
        expression += "#type2 = :type2, ";
      }
      if (urlImage != null) {
        expression += "#imageUrl = :imageUrl, ";
      }

      if (expression.endsWith(', ')) {
        expression = expression.substring(0, expression.length - 2);
      }
    }

    final results = await db.updateItem(
      key: marshall({"pokemonID": pokemonID}),
      tableName: "pokemons",
      updateExpression: expression.isNotEmpty ? expression : null,
      expressionAttributeNames: expression.isNotEmpty
          ? {
              if (body['name'] != null) '#name': 'name',
              if (body['type'] != null) '#type': 'type',
              if (body['type2'] != null) '#type2': 'type2',
              if (urlImage != null) '#image': 'image',
            }
          : null,
      expressionAttributeValues: expression.isNotEmpty
          ? marshall({
              if (body['name'] != null) ':name': body['name'],
              if (body['type'] != null) ':type': body['type'],
              if (body['type2'] != null) ':type2': body['type2'],
              if (urlImage != null) ':imageUrl': urlImage,
            })
          : null,
      returnValues: ReturnValue.allNew,
    );

    if (results.attributes == null) {
      return AwsApiGatewayResponse.fromJson({
        'status': 'error',
        'content': 'Pokemon not found',
      });
    }
    final pokemon = Pokemon.fromJson(unmarshal(results.attributes!));

    return AwsApiGatewayResponse.fromJson(
        {'status': 'ok', 'content': pokemon.toJson()});
  } catch (e, s) {
    return AwsApiGatewayResponse.fromJson({
      'status': 'error',
      'content': 'Error creating Pokemon',
      'error': e.toString(),
      'stack': s.toString(),
    });
  }
}
