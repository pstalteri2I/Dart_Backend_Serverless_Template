import 'package:aws_lambda_dart_runtime/aws_lambda_dart_runtime.dart';
import 'package:aws_lambda_dart_runtime/runtime/context.dart';
import 'package:dart_template/models/pokemon.dart';
import 'package:dart_template/unmarshal.dart';
import 'package:aws_client/dynamo_db_2012_08_10.dart';

Future<AwsApiGatewayResponse> getPokemons(
  Context context,
  AwsApiGatewayEvent event,
) async {
  try {
    final db = DynamoDB(region: context.region!);

    final results = await db.scan(tableName: "pokemons");

    final pokemonList = results.items!
        .map((pokemon) => Pokemon.fromJson(unmarshal(pokemon)))
        .toList();

    return AwsApiGatewayResponse.fromJson({
      'status': 'ok',
      'content': pokemonList.map((p) => p.toJson()).toList(),
    });
  } catch (e) {
    return AwsApiGatewayResponse.fromJson({
      'status': 'error',
      'content': 'Error creating Pokemon',
      'error': e.toString(),
    });
  }
}
