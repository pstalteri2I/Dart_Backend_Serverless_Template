// ignore_for_file: prefer_function_declarations_over_variables
import 'package:aws_lambda_dart_runtime/aws_lambda_dart_runtime.dart';
import 'package:dart_template/handlers/api/getPokemons.dart';
import 'package:dart_template/handlers/api/putPokemon.dart';

void main() async {
  Runtime()
    ..registerHandler<AwsApiGatewayEvent>("main.putPokemon", putPokemon)
    ..registerHandler<AwsApiGatewayEvent>("main.getPokemons", getPokemons)
    ..invoke();
}
