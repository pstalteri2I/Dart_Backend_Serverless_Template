import 'package:aws_lambda_dart_runtime/aws_lambda_dart_runtime.dart';
import 'package:aws_lambda_dart_runtime/runtime/context.dart';

Future<AwsApiGatewayResponse> status(
    Context context, AwsApiGatewayEvent event) async {
  return AwsApiGatewayResponse.fromJson({'status': 'okk'},
      statusCode: 200, headers: {'Access-Control-Allow-Origin': '*'});
}
//ciao
