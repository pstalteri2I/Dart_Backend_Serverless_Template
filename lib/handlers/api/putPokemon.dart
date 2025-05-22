import 'dart:convert';
import 'package:aws_client/dynamo_db_2012_08_10.dart';
import 'package:aws_lambda_dart_runtime/aws_lambda_dart_runtime.dart';
import 'package:aws_lambda_dart_runtime/runtime/context.dart';
import 'package:dart_template/marshal.dart';
import 'package:dart_template/models/pokemon.dart';
import 'package:uuid/uuid.dart';
import 'package:aws_client/ses_v2_2019_09_27.dart';

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

    final db = DynamoDB(region: context.region!);

    final newPokemon = await db.putItem(
      tableName: 'pokemons',
      item: marshall(pokemon.toJson()),
    );

    final api = SesV2(region: context.region!);

    await api.sendEmail(
      fromEmailAddress: 'tnicosia@2innovation.it',
      destination: Destination(
        toAddresses: ['pstalteri@2innovation.it'],
      ),
      content: EmailContent(
        simple: Message(
          body: Body(
              text: Content(
                  data:
                      'Pokemon created, ID: ${pokemon.pokemonID}, name: ${pokemon.name}')),
          subject: Content(data: 'Email from SES'),
        ),
      ),
    );

    api.close();

    return AwsApiGatewayResponse.fromJson(
      {
        'status': 'ok',
        'content': pokemon.toJson(),
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
