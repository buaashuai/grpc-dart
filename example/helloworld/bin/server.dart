// Copyright (c) 2018, the gRPC project authors. Please see the AUTHORS file
// for details. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

/// Dart implementation of the gRPC helloworld.Greeter server.
import 'package:grpc/grpc.dart';
import 'package:helloworld/src/generated/helloworld.pb.dart';
import 'package:helloworld/src/generated/helloworld.pbgrpc.dart';


class GreeterService extends GreeterServiceBase {
  int num = 0;
  @override
  Future<HelloReply> sayHello(ServiceCall call, HelloRequest request) async {
    if(num <=1) {
      num++;
      print('${DateTime.now().toLocal()} 延迟调用 5');
      await Future.delayed(Duration(seconds: 5));
    } else {
      print('${DateTime.now().toLocal()} 延迟调用 2');
      await Future.delayed(Duration(seconds: 2));
    }
    //   await Future.delayed(Duration(seconds: 2));
    print('${DateTime.now().toLocal()} 返回结果');
    return HelloReply()..message = 'Hello, ${request.name}!';
  }
}

Future<void> main(List<String> args) async {
  final server = Server(
    [GreeterService()],
    const <Interceptor>[],
    CodecRegistry(codecs: const [GzipCodec(), IdentityCodec()]),
  );
  await server.serve(port: 50051);
  print('Server listening on port ${server.port}...');
}
