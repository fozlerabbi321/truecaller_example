import 'package:flutter/material.dart';
import 'package:truecaller_sdk/truecaller_sdk.dart';

import 'non_tc_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Truecaller Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Stream<TruecallerSdkCallback>? _stream;

  @override
  void initState() {
    super.initState();
    _stream = TruecallerSdk.streamCallbackData;
  }

  @override
  void dispose() {
    _stream = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            MaterialButton(
              onPressed: () {
                TruecallerSdk.initializeSDK(
                    sdkOptions: TruecallerSdkScope.SDK_OPTION_WITH_OTP);
                TruecallerSdk.isUsable.then((isUsable) {
                  if (isUsable) {
                    TruecallerSdk.getProfile;
                  } else {
                    const snackBar = SnackBar(content: Text("Not Usable"));
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    print("***Not usable***");
                  }
                });
              },
              child: const Text(
                "Initialize SDK & Get Profile",
                style: TextStyle(color: Colors.white),
              ),
              color: Colors.blue,
            ),
            const Divider(
              color: Colors.transparent,
              height: 20.0,
            ),
            StreamBuilder<TruecallerSdkCallback>(
                stream: _stream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    switch (snapshot.data!.result) {
                      case TruecallerSdkCallbackResult.success:
                        return Text(
                          "Hi, ${snapshot.data!.profile!.firstName} ${snapshot.data!.profile!.lastName}"
                          "\nBusiness Profile: ${snapshot.data!.profile!.isBusiness}",
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                        );
                      case TruecallerSdkCallbackResult.failure:
                        return Text(
                            "Oops!! Error type ${snapshot.data!.error!.code}");
                      case TruecallerSdkCallbackResult.verification:
                        return Column(
                          children: [
                            Text("Verification Required : "
                                "${snapshot.data!.error != null ? snapshot.data!.error!.code : ""}"),
                            MaterialButton(
                              color: Colors.green,
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const NonTcVerification()));
                              },
                              child: const Text(
                                "Do manual verification",
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                          ],
                        );
                      default:
                        return const Text("Invalid result");
                    }
                  } else {
                    return const Text("");
                  }
                }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
