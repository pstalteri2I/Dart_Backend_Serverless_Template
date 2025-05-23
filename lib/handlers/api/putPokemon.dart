import 'dart:convert';
import 'package:aws_client/dynamo_db_2012_08_10.dart';
import 'package:aws_client/s3_2006_03_01.dart';
import 'package:aws_lambda_dart_runtime/aws_lambda_dart_runtime.dart';
import 'package:aws_lambda_dart_runtime/runtime/context.dart';
import 'package:dart_template/marshal.dart';
import 'package:dart_template/models/pokemon.dart';
import 'package:uuid/uuid.dart';

Future<AwsApiGatewayResponse> putPokemon(
    Context context, AwsApiGatewayEvent event) async {
  try {
    var uuid = const Uuid();
    final body = jsonDecode(event.body!);
    final db = DynamoDB(region: context.region!);

    // Singolo oggetto
    if (body is! List) {
      final pokemonID = uuid.v1();
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
          acl: ObjectCannedACL.publicRead,
        );
        urlImage =
            'https://pie-nele-bucket.s3.amazonaws.com/$pokemonID.${contentType.split("/").last}';
        s3.close();
      }

      final pokemon = Pokemon(
        pokemonID: pokemonID,
        name: body['name'],
        type: body['type'],
        type2: body['type2'],
        imageUrl: urlImage,
      );

      await db.putItem(
        item: marshall(pokemon.toJson()),
        tableName: "pokemons",
      );

      return AwsApiGatewayResponse.fromJson({
        'status': 'ok',
        'content': pokemon.toJson(),
      });
    }

    if (body.length > 25) {
      return AwsApiGatewayResponse.fromJson({
        'status': 'error',
        'content': 'Massimo 25 Pokemon alla volta',
      });
    }

    List<Pokemon> pokemonList = [];

    final requestItems =
        await Future.wait(body.map<Future<WriteRequest>>((e) async {
      final pokemonID = uuid.v1();
      String? urlImage;

      if (e['image'] != null && e['image'].toString().contains(',')) {
        final base64String = e['image'].split(',').last;
        final imageData = base64Decode(base64String);

        final header = e['image'].split(',').first;
        final contentType = header.split(':').last.split(';').first;
        final key = "$pokemonID.${contentType.split("/").last}";

        final s3 = S3(region: context.region!);
        await s3.putObject(
          bucket: 'pie-nele-bucket',
          key: key,
          body: imageData,
          contentType: contentType,
          acl: ObjectCannedACL.publicRead,
        );
        urlImage =
            'https://pie-nele-bucket.s3.amazonaws.com/$pokemonID.${contentType.split("/").last}';
        s3.close();
      }

      final pokemon = Pokemon(
        pokemonID: pokemonID,
        name: e['name'],
        type: e['type'],
        type2: e['type2'] ?? e['type'],
        imageUrl: urlImage,
      );

      pokemonList.add(pokemon);

      return WriteRequest(
        putRequest: PutRequest(
          item: marshall(pokemon.toJson()),
        ),
      );
    }).toList());

    await db.batchWriteItem(
      requestItems: {
        "pokemons": requestItems,
      },
    );

    return AwsApiGatewayResponse.fromJson({
      'status': 'ok',
      'content': pokemonList.map((p) => p.toJson()).toList(),
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
