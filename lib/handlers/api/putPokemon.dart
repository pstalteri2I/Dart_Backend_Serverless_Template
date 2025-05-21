import 'dart:convert';
import 'package:aws_lambda_dart_runtime/aws_lambda_dart_runtime.dart';
import 'package:aws_lambda_dart_runtime/runtime/context.dart';
import 'package:dart_template/marshall.dart';
import 'package:dart_template/models/pokemon.dart';
import 'package:uuid/uuid.dart';
import 'package:aws_client/dynamo_document.dart';

Future<AwsApiGatewayResponse> putPokemon(
    Context context, AwsApiGatewayEvent event) async {
  try {
    var uuid = const Uuid();
    final body = jsonDecode(event.body!);

    Pokemon pokemon = Pokemon(
        pokemonID: uuid.v1(),
        name: body['name'],
        type: body['type'],
        type2: body['type2']);

    final db = DocumentClient(region: context.region!);

    final newPokemon = await db.put(
      tableName: 'pokemons',
      item: marshall(pokemon.toJson()),
    );

    print(newPokemon);

    return AwsApiGatewayResponse.fromJson(
      {
        'status': 'ok',
        'content': 'Pokemon created',
        'pokemon': pokemon.toJson()
      },
    );
  } catch (e) {
    return AwsApiGatewayResponse.fromJson(
      {
        'status': 'error',
        'content': 'Error creating Pokemon',
        'error': e.toString()
      },
    );
  }
}
