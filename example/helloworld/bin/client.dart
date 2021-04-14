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

/// Dart implementation of the gRPC helloworld.Greeter client.
import 'package:grpc/grpc.dart';
import 'package:helloworld/src/generated/helloworld.pb.dart';
import 'package:helloworld/src/generated/helloworld.pbgrpc.dart';
import 'dart:async';

Future<void> main(List<String> args) async {
  final channel = ClientChannel(
    'localhost',
    port: 50051,
    options: ChannelOptions(
      credentials: ChannelCredentials.insecure(),
      codecRegistry: CodecRegistry(codecs: const [GzipCodec(), IdentityCodec()]),
    ),
  );
  final stub = GreeterClient(channel, options: CallOptions(timeout: Duration(seconds: 3), retryNum: 3));

  final name = args.isNotEmpty ? args[0] : 'world';

  try {
    final response = await stub.sayHello(
      HelloRequest()..name = name,
      options: CallOptions(compression: const GzipCodec(), retryNum: 2),
    );
    print('收到调用结果: ${response.message}');
  } catch (e) {
    print('${DateTime.now().toLocal()} 调用出错啦: $e');
  }
  await channel.shutdown();
}

void log(String msg) {
  print('${DateTime.now().toLocal()} $msg');
}

Future<int> test2(int n) async {
  log('调用test2: $n');
  await Future.delayed(Duration(seconds: 1));
  if (n <= 22) {
    log('test2 抛异常: $n');
    throw '出错啦';
  }
  return n + 1;
}

Future<int> test(int N) async {
  final resultCompleter = Completer<int>();
  Future<int> result;
  bool stopFlag = false;
  if (N == 3) {
    stopFlag = true;
  }
  result = test2(N);
  result.then((value) {
    log('调用test2完毕: $value');
    resultCompleter.complete(result);
  }, onError: (error) {
    log('调用出错 $N: $error');
    if (!stopFlag) {
      resultCompleter.complete(test(N + 1));
    } else {
      resultCompleter.completeError(error);
    }
  });
  return resultCompleter.future;
}

Future<void> main33(List<String> args) async {
  log('调用test');
  try {
    int xx = await test(1);
    log('调用test结果: $xx');
  } catch (e) {
    log('test 调用出错: $e');
  }
  log('调用test完毕');
}
