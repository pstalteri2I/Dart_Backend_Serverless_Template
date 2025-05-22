import 'package:aws_lambda_dart_runtime/aws_lambda_dart_runtime.dart';
import 'package:aws_lambda_dart_runtime/runtime/context.dart';
import 'package:aws_client/dynamo_db_2012_08_10.dart';
import 'package:dart_template/marshal.dart';
import 'package:dart_template/models/pokemon.dart';
import 'package:dart_template/unmarshal.dart';

Future<AwsApiGatewayResponse> getPokemon(
  Context context,
  AwsApiGatewayEvent event,
) async {
  try {
    final db = DynamoDB(region: context.region!);

    final pokemonID = event.pathParameters!['pokemonID'];

    final results = await db.getItem(
        key: marshall({"pokemonID": pokemonID}), tableName: "pokemons");

    if (results.item == null) {
      return AwsApiGatewayResponse.fromJson({
        'status': 'error',
        'content': 'Pokemon not found',
      });
    }
    final pokemon = Pokemon.fromJson(unmarshal(results.item!));

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
