// import 'dart:convert';
// import 'package:aws_lambda_dart_runtime/aws_lambda_dart_runtime.dart';
// import 'package:aws_lambda_dart_runtime/runtime/context.dart';
// import 'package:dart_template/marshal.dart';
// import 'package:dart_template/models/pokemon.dart';
// import 'package:dart_template/unmarshal.dart';
// import 'package:uuid/uuid.dart';
// import 'package:aws_client/dynamo_document.dart';

// Future<AwsApiGatewayResponse> putPokemons(
//     Context context, AwsApiGatewayEvent event) async {
//   try {
//     final db = DocumentClient(region: context.region!);

//     final results = await db.scan(tableName: "pokemons");

//     final List<Pokemon> pokemonList = [];
//     for (var pokemon in pokemons) {
//       final pokemonData = unmarshal(pokemon);
//       pokemonList.add(Pokemon.fromJson(pokemonData));
//     }

//     return AwsApiGatewayResponse.fromJson(
//       {
//         'status': 'ok',
//         'content': pokemon.toJson(),
//       },
//     );
//   } catch (e) {
//     return AwsApiGatewayResponse.fromJson(
//       {
//         'status': 'error',
//         'content': 'Error creating Pokemon',
//         'error': e.toString()
//       },
//     );
//   }
// }
