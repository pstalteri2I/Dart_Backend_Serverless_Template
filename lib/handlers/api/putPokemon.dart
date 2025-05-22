import 'dart:convert';
import 'package:aws_client/dynamo_db_2012_08_10.dart';
import 'package:aws_lambda_dart_runtime/aws_lambda_dart_runtime.dart';
import 'package:aws_lambda_dart_runtime/runtime/context.dart';
import 'package:dart_template/marshal.dart';
import 'package:dart_template/models/pokemon.dart';
import 'package:uuid/uuid.dart';

Future<AwsApiGatewayResponse> putPokemon(
    Context context, AwsApiGatewayEvent event) async {
  try {
    var uuid = const Uuid();
    //final body = jsonDecode(event.body!) as List<dynamic>;

    //final body = List.from(jsonDecode(event.body!));

    final body = jsonDecode(event.body!);
    final db = DynamoDB(region: context.region!);

    if (body is! List) {
      Pokemon pokemon = Pokemon(
          pokemonID: uuid.v1(),
          name: body['name'],
          type: body['type'],
          type2: body['type2']);

      await db.putItem(
        item: marshall(pokemon.toJson()),
        tableName: "pokemons",
      );

      return AwsApiGatewayResponse.fromJson(
        {
          'status': 'ok',
          'content': pokemon.toJson(),
        },
      );
    }

    List<Pokemon> pokemonList = [];

    final requestItem = body.map((e) {
      Pokemon pokemon = Pokemon(
          pokemonID: uuid.v1(),
          name: e['name'],
          type: e['type'],
          type2: e['type2']);

      pokemonList.add(pokemon);
      return WriteRequest(
        putRequest: PutRequest(
          item: marshall(pokemon.toJson()),
        ),
      );
    }).toList();

    await db.batchWriteItem(
      requestItems: {
        "pokemons": requestItem,
      },
    );

    // final api = SesV2(region: context.region!);

    // await api.sendEmail(
    //   fromEmailAddress: 'tnicosia@2innovation.it',
    //   destination: Destination(
    //     toAddresses: ['pstalteri@2innovation.it'],
    //   ),
    //   content: EmailContent(
    //     simple: Message(
    //       body: Body(
    //           text: Content(
    //               data:
    //                   'Pokemon created, ID: ${pokemon.pokemonID}, name: ${pokemon.name}')),
    //       subject: Content(data: 'Email from SES'),
    //     ),
    //   ),
    // );

    // api.close();

    return AwsApiGatewayResponse.fromJson(
      {
        'status': 'ok',
        'content': pokemonList,
      },
    );
  } catch (e, stackTrace) {
    return AwsApiGatewayResponse.fromJson(
      {
        'status': 'error',
        'content': 'Error creating Pokemon',
        'error': e.toString(),
        'stackTrace': stackTrace.toString(),
      },
    );
  }
}
