import 'dart:async';
import 'dart:developer' as developer;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription _intentDataStreamSubscription;
  String? _sharedFilePath;

  @override
  void initState() {
    super.initState();

    // For sharing or opening files from outside the app
    _intentDataStreamSubscription = ReceiveSharingIntent.instance.getMediaStream()
        .listen((List<SharedMediaFile> value) {
      setState(() {
        _sharedFilePath = value.isNotEmpty ? value[0].path : null;
      });
    });

    // For opening files from the home screen
    ReceiveSharingIntent.instance.getInitialMedia().then((List<SharedMediaFile> value) {
      setState(() {
        _sharedFilePath = value.isNotEmpty ? value[0].path : null;
      });
    });
  }

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        _sharedFilePath = result.files.single.path;
      });
    } else {
      // User canceled the picker
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF Viewer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('PDF Viewer'),
          actions: [
            IconButton(
              icon: const Icon(Icons.file_open),
              onPressed: _pickFile,
              tooltip: 'Open PDF',
            )
          ],
        ),
        body: _sharedFilePath == null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Open a PDF file to view it here.'),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _pickFile,
                      icon: const Icon(Icons.folder_open),
                      label: const Text("Choose a PDF File"),
                    ),
                  ],
                ),
              )
            : PDFScreen(path: _sharedFilePath!),
      ),
    );
  }
}

class PDFScreen extends StatefulWidget {
  final String path;

  const PDFScreen({super.key, required this.path});

  @override
  State<PDFScreen> createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> with WidgetsBindingObserver {
  final Completer<PDFViewController> _controller = Completer<PDFViewController>();
  int? pages = 0;
  int? currentPage = 0;
  bool isReady = false;
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        PDFView(
          filePath: widget.path,
          enableSwipe: true,
          swipeHorizontal: false, // Changed to vertical scrolling
          autoSpacing: false,
          pageFling: true,
          pageSnap: true,
          defaultPage: currentPage!,
          fitPolicy: FitPolicy.BOTH,
          preventLinkNavigation: false,
          onRender: (pages) {
            setState(() {
              pages = pages;
              isReady = true;
            });
          },
          onError: (error) {
            setState(() {
              errorMessage = error.toString();
            });
            developer.log('PDF View Error: $error');
          },
          onPageError: (page, error) {
            setState(() {
              errorMessage = '$page: ${error.toString()}';
            });
            developer.log('PDF Page Error: $page: $error');
          },
          onViewCreated: (PDFViewController pdfViewController) {
            _controller.complete(pdfViewController);
          },
          onPageChanged: (int? page, int? total) {
            setState(() {
              currentPage = page;
            });
          },
        ),
        errorMessage.isEmpty
            ? !isReady
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Container()
            : Center(
                child: Text(errorMessage),
              )
      ],
    );
  }
}
