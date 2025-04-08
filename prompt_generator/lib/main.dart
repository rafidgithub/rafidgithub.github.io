import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'gemini_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prompt Generator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();

  String _response = "";

  bool btnEnabled = false;

  bool loading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller.addListener(() {
      setState(() {
        btnEnabled = _controller.text.trim().isNotEmpty;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Prompt Generator"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Text(
                "Input your prompt below to generate a prompt for other AI models",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Focus(
                focusNode: _focusNode,
                onKey: (FocusNode node, RawKeyEvent event) {
                  if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
                    _generatePrompt();
                    return KeyEventResult.handled; // Consume the event
                  }
                  return KeyEventResult
                      .ignored; // Let the event pass through if not Enter
                },
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Enter your prompt here",
                  ),
                ),
              ),
              const SizedBox(height: 20),
              loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: !btnEnabled
                          ? null
                          : () async {
                              await _generatePrompt();
                            },
                      child: const Text("Generate"),
                    ),
              const SizedBox(height: 20),
              if (_response.trim().isNotEmpty) ...[
                const Text(
                  "Generated Prompt:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SelectableText(
                        _response,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    InkWell(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: _response));
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Copied to clipboard")));
                      },
                      child: const Icon(
                        Icons.copy,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _generatePrompt() async {
    String query = _controller.text.trim();
    if (query.isNotEmpty) {
      setState(() {
        loading = true;
      });
      // _getResponse(query);
      await GeminiService().getAnswer(
        query,
        onSuccess: (response) {
          setState(() {
            _response = response;
          });
        },
      );
      setState(() {
        loading = false;
      });
    }
  }
}
