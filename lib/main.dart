import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:image_crop/image_crop.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

//import 'crop_image.dart';
import 'package:http/http.dart' as http;
const kAndroidUserAgent =
    'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Mobile Safari/537.36';

//String selectedUrl = 'https://damp-coast-35782.herokuapp.com';
String selectedUrl = 'https://devl06.borugroup.com/mvadev/mva-phoneapp/#!/';
//String selectedUrl = 'https://devl06.borugroup.com/cokere/buttontest/';

// ignore: prefer_collection_literals
final Set<JavascriptChannel> jsChannels = [
  JavascriptChannel(
      name: 'Print',
      onMessageReceived: (JavascriptMessage message) {
        if(message.message == 'scan'){
          //MyApp.startBarcode();
          print(message.message);
          sBarcode(MyApp());
        } else if(message.message=='scanAssets'){
          print(message.message);
          sAssetBarcode(MyApp());
        }
        else if(message.message=='captureImage'){
          print(message.message);
          //runApp(MyApps());
          takeImage(MyApps());
        }}),
].toSet();


sBarcode(someVal) async {
  String bCode = await FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", true);
  print(bCode);
  someVal.enterBarcode(bCode);
  return;
}
sAssetBarcode(someVal) async {
  String bCode = await FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", true);
  print(bCode);
  someVal.enterBarcodeAsset(bCode);
  return;
}
takeImage(someVal) async {
  Future opImg = _MyAppState()._openImage();
  opImg.then((image) => uploadImage(MyApp(),image) ).catchError((error) => debugPrint(error));
  //MyApps().createState();
  
}
uploadImage(someVal,file) async{
  debugPrint('$file');
  someVal._upload(file);
}

void main() => runApp(MyApp());


class MyApp extends StatelessWidget {

  final cropKey = GlobalKey<CropState>();

  final flutterWebViewPlugin = FlutterWebviewPlugin();
  enterBarcode(barc) {
    flutterWebViewPlugin.evalJavascript("document.getElementById('barcodenumber').value=" + barc);
  }
  enterCamera(barc) {
    flutterWebViewPlugin.evalJavascript("document.getElementById('barcodenumberasset').value=" + barc);
  }
  enterBarcodeAsset(barc) {
    flutterWebViewPlugin.evalJavascript("document.getElementById('barcodenumberasset').value=" + barc);
  }

  void _upload(file) {
    if (file == null) {
      //String base64Image = base64Encode(file.readAsBytesSync());
      //String fileName = file.path.split("/").last;
      flutterWebViewPlugin.evalJavascript("document.getElementById('barcodenumberasset').value=0123");

    } else{
      final String phpEndPoint = 'http://devl06.borugroup.com/mvadev/phoneapi/scanImage.php';
      String base64Image = base64Encode(file.readAsBytesSync());
      String fileName = file.path.split("/").last;
      flutterWebViewPlugin.evalJavascript("document.getElementById('barcodenumberasset').value= 'Fetching...'");

      http.post(phpEndPoint, body: {
        "image": base64Image,
        "name": fileName,
      }).then((res) {
        flutterWebViewPlugin.evalJavascript("document.getElementById('barcodenumberasset').value= 6767");
        print(res.statusCode);
        String statusCode = res.body;
        final jsonResponse = json.decode(res.body);
        //String message =statusCode.message;
        flutterWebViewPlugin.evalJavascript("document.getElementById('barcodenumberasset').value="+jsonResponse['message']);

      }).catchError((err) {
        //print(err);
        flutterWebViewPlugin.evalJavascript("document.getElementById('barcodenumberasset').value= 11"+err);

      });
    }

  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter WebView Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        // '/': (_) => const MyHomePage(title: 'Flutter WebView Demo'),
        '/': (_) {
          return WebviewScaffold(
            url: selectedUrl,
            javascriptChannels: jsChannels,
            withZoom: true,
            withLocalStorage: true,
            withJavascript: true,
            hidden: true,
            initialChild: Container(
              color: Colors.white,
              child: const Center(
                child: Text('Loading...'),
              ),
            ),
          );
        },
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Instance of WebView plugin
  final flutterWebViewPlugin = FlutterWebviewPlugin();

  // On destroy stream
  StreamSubscription _onDestroy;

  // On urlChanged stream
  StreamSubscription<String> _onUrlChanged;

  // On urlChanged stream
  StreamSubscription<WebViewStateChanged> _onStateChanged;

  StreamSubscription<WebViewHttpError> _onHttpError;

  StreamSubscription<double> _onProgressChanged;

  StreamSubscription<double> _onScrollYChanged;

  StreamSubscription<double> _onScrollXChanged;

  final _urlCtrl = TextEditingController(text: selectedUrl);

  final _codeCtrl = TextEditingController(text: 'window.navigator.userAgent');

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _history = [];

  @override
  void initState() {
    super.initState();

    flutterWebViewPlugin.close();

    _urlCtrl.addListener(() {
      selectedUrl = _urlCtrl.text;
    });

    // Add a listener to on destroy WebView, so you can make came actions.
    _onDestroy = flutterWebViewPlugin.onDestroy.listen((_) {
      if (mounted) {
        // Actions like show a info toast.
        _scaffoldKey.currentState.showSnackBar(
            const SnackBar(content: const Text('Webview Destroyed')));
      }
    });

    // Add a listener to on url changed
    _onUrlChanged = flutterWebViewPlugin.onUrlChanged.listen((String url) {
      if (mounted) {
        setState(() {
          _history.add('onUrlChanged: $url');
        });
      }
    });

    _onProgressChanged =
        flutterWebViewPlugin.onProgressChanged.listen((double progress) {
          if (mounted) {
            setState(() {
              _history.add('onProgressChanged: $progress');
            });
          }
        });

    _onScrollYChanged =
        flutterWebViewPlugin.onScrollYChanged.listen((double y) {
          if (mounted) {
            setState(() {
              _history.add('Scroll in Y Direction: $y');
            });
          }
        });

    _onScrollXChanged =
        flutterWebViewPlugin.onScrollXChanged.listen((double x) {
          if (mounted) {
            setState(() {
              _history.add('Scroll in X Direction: $x');
            });
          }
        });

    _onStateChanged =
        flutterWebViewPlugin.onStateChanged.listen((WebViewStateChanged state) {
          print(state.type);
          if (mounted) {
            setState(() {
              _history.add('onStateChanged: ${state.type} ${state.url}');
            });
          }
        });

    _onHttpError =
        flutterWebViewPlugin.onHttpError.listen((WebViewHttpError error) {
          if (mounted) {
            setState(() {
              _history.add('onHttpError: ${error.code} ${error.url}');
            });
          }
        });
  }

  @override
  void dispose() {
    // Every listener should be canceled, the same should be done with this stream.
    _onDestroy.cancel();
    _onUrlChanged.cancel();
    _onStateChanged.cancel();
    _onHttpError.cancel();
    _onProgressChanged.cancel();
    _onScrollXChanged.cancel();
    _onScrollYChanged.cancel();

    flutterWebViewPlugin.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24.0),
              child: TextField(controller: _urlCtrl),
            ),
            RaisedButton(
              onPressed: () {
                flutterWebViewPlugin.launch(
                  selectedUrl,
                  rect: Rect.fromLTWH(
                      0.0, 0.0, MediaQuery.of(context).size.width, 300.0),
                  userAgent: kAndroidUserAgent,
                  invalidUrlRegex:
                  r'^(https).+(twitter)', // prevent redirecting to twitter when user click on its icon in flutter website
                );
              },
              child: const Text('Open Webview (rect)'),
            ),
            RaisedButton(
              onPressed: () {
                flutterWebViewPlugin.launch(selectedUrl, hidden: true);
              },
              child: const Text('Open "hidden" Webview'),
            ),
            RaisedButton(
              onPressed: () {
                flutterWebViewPlugin.launch(selectedUrl);
              },
              child: const Text('Open Fullscreen Webview'),
            ),
            RaisedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/widget');
              },
              child: const Text('Open widget webview'),
            ),
            Container(
              padding: const EdgeInsets.all(24.0),
              child: TextField(controller: _codeCtrl),
            ),
            RaisedButton(
              onPressed: () {
                final future =
                flutterWebViewPlugin.evalJavascript(_codeCtrl.text);
                future.then((String result) {
                  setState(() {
                    _history.add('eval: $result');
                  });
                });
              },
              child: const Text('Eval some javascript'),
            ),
            RaisedButton(
              onPressed: () {
                setState(() {
                  _history.clear();
                });
                flutterWebViewPlugin.close();
              },
              child: const Text('Close'),
            ),
            RaisedButton(
              onPressed: () {
                flutterWebViewPlugin.getCookies().then((m) {
                  setState(() {
                    _history.add('cookies: $m');
                  });
                });
              },
              child: const Text('Cookies'),
            ),
            Text(_history.join('\n'))
          ],
        ),
      ),
    );
  }
}
//git pull git@github.com:vixur-legacy/todaysepicure.git master

class MyApps extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApps> {
  final cropKey = GlobalKey<CropState>();
  File _file;
  File _sample;
  File _lastCropped;

  @override
  void dispose() {
    super.dispose();
    _file?.delete();
    _sample?.delete();
    _lastCropped?.delete();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Container(
          color: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
          child: _sample == null ? _buildOpeningImage() : _buildCroppingImage(),
        ),
      ),
    );
  }

  Widget _buildOpeningImage() {
    return Center(child: _buildOpenImage());
  }

  Widget _buildCroppingImage() {
    return Column(
      children: <Widget>[
        Expanded(
          child: Crop.file(_sample, key: cropKey),
        ),
        Container(
          padding: const EdgeInsets.only(top: 20.0),
          alignment: AlignmentDirectional.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              /* FlatButton(
                child: Text(
                  'Crop Image',
                  /* style: Theme.of(context)
                      .textTheme
                      .button
                      .copyWith(color: Colors.white), */
                ),
                onPressed: () => (),
              ), */
              _buildOpenImage(),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildOpenImage() {
    return FlatButton(
      child: Text(
        'Open Camera',
        //style: Theme.of(context).textTheme.button.copyWith(color: Colors.white),
      ),
      onPressed: () => _openImage(),
    );
  }

  Future<File> _openImage() async {
    final file = await ImagePicker.pickImage(source: ImageSource.camera);
    final sample = await ImageCrop.sampleImage(
      file: file,
      preferredWidth: 1024,
      preferredHeight: 4096,
    );

    _sample?.delete();
    _file?.delete();

     /* setState(() {
      this._sample = sample;
      this._file = file;
    });  */
    this._sample = sample;
    this._file = file; 
    final area = Rect.fromLTWH( 0.0, 0.0, 1.0, 1.0);
     final img = await ImageCrop.cropImage(
      file: this._file,
      area: area,
    );
    
    File croppedFile = await ImageCropper.cropImage(
      sourcePath: img.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: Colors.blueGrey,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false),
      iosUiSettings: IOSUiSettings(
        minimumAspectRatio: 1.0,
      )
    );

     //_buildCroppingImage();
    return croppedFile;
    
   // _cropImage(this._file);
   
  }
}
