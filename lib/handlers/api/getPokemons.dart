import 'package:aws_lambda_dart_runtime/aws_lambda_dart_runtime.dart';
import 'package:aws_lambda_dart_runtime/runtime/context.dart';
import 'package:dart_template/marshal.dart';
import 'package:dart_template/models/pokemon.dart';
import 'package:dart_template/unmarshal.dart';
import 'package:aws_client/dynamo_db_2012_08_10.dart';

Future<AwsApiGatewayResponse> getPokemons(
  Context context,
  AwsApiGatewayEvent event,
) async {
  try {
    final db = DynamoDB(region: context.region!);

    final lastEvalueted = event.queryStringParameters?['lastEvalueted'];

    final pokemonType = event.queryStringParameters?['type'];
    final pokemonType2 = event.queryStringParameters?['type2'];

    final results = await db.scan(
        tableName: "pokemons",
        filterExpression: pokemonType != null
            ? pokemonType2 != null
                ? "(contains(#type, :type) or contains(#type2, :type)) and (contains(#type, :type2) or contains(#type2, :type2))"
                : "contains(#type, :type) or contains(#type2, :type)"
            : null,
        expressionAttributeNames: pokemonType != null
            ? {
                "#type": "type",
                "#type2": "type2",
              }
            : null,
        expressionAttributeValues: pokemonType != null
            ? marshall({
                ":type": pokemonType,
                if (pokemonType2 != null) ":type2": pokemonType2
              })
            : null,
        limit: 5,
        exclusiveStartKey: lastEvalueted != null
            ? marshall({"pokemonID": lastEvalueted})
            : null);

    // final pokemonList = results.items!.map((p) {
    //   Pokemon pokemon = Pokemon.fromJson(unmarshal(p));
    //   pokemon.pokemonID = "Tiziano riscrivi il backend di Sell-y";
    //   return pokemon;
    // }).toList();

    final pokemonList =
        results.items!.map((p) => Pokemon.fromJson(unmarshal(p))).toList();

    return AwsApiGatewayResponse.fromJson({
      'status': 'ok',
      'content': pokemonList,
      'next': results.lastEvaluatedKey
    });
  } catch (e, s) {
    return AwsApiGatewayResponse.fromJson({
      'status': 'error',
      'content': 'Error creating Pokemon',
      'error': e.toString(),
      'stack': s.toString(),
    });
  }
}
