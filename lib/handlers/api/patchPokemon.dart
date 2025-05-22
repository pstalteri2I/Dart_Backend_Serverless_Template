import 'dart:convert';
import 'package:aws_lambda_dart_runtime/aws_lambda_dart_runtime.dart';
import 'package:aws_lambda_dart_runtime/runtime/context.dart';
import 'package:aws_client/dynamo_db_2012_08_10.dart';
import 'package:dart_template/marshal.dart';
import 'package:dart_template/models/pokemon.dart';
import 'package:dart_template/unmarshal.dart';

Future<AwsApiGatewayResponse> patchPokemon(
  Context context,
  AwsApiGatewayEvent event,
) async {
  try {
    final db = DynamoDB(region: context.region!);

    final pokemonID = event.pathParameters!['pokemonID'];
    final body = jsonDecode(event.body!);

    final results = await db.updateItem(
      key: marshall({"pokemonID": pokemonID}),
      tableName: "pokemons",
      updateExpression: "SET #name = :name, #type = :type, #type2 = :type2",
      expressionAttributeNames: {
        '#name': 'name',
        '#type': 'type',
        '#type2': 'type2',
      },
      expressionAttributeValues: marshall({
        ':name': body['name'],
        ':type': body['type'],
        ':type2': body['type2'],
      }),
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
  } catch (e) {
    return AwsApiGatewayResponse.fromJson({
      'status': 'error',
      'content': 'Error creating Pokemon',
      'error': e.toString(),
    });
  }
}
