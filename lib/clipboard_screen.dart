import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ClipboardListenerScreen extends StatefulWidget {
  const ClipboardListenerScreen({super.key});

  @override
  _ClipboardListenerScreenState createState() =>
      _ClipboardListenerScreenState();
}

class _ClipboardListenerScreenState extends State<ClipboardListenerScreen> {
  List<String> copiedTexts = [];
  static const MethodChannel _channel = MethodChannel('clipboard_monitor');

  @override
  void initState() {
    super.initState();
    _channel.setMethodCallHandler(_handleMethod);
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    if (call.method == 'clipboardChanged') {
      setState(() {
        copiedTexts.add(call.arguments as String);
      });
    }
    return null;
  }

  void deleteItem(int index) {
    setState(() {
      copiedTexts.removeAt(index);
    });
  }

  void deleteAlItem() {
    setState(() {
      copiedTexts.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    print(screenWidth.toString());
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: copiedTexts.isNotEmpty
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.paste,
                        size: 12,
                      ),
                      Text(
                        " All(${copiedTexts.length})",
                        style: const TextStyle(fontSize: 12),
                      ),
                      const Spacer(),
                      CupertinoButton(
                          child: const Text(
                            "Clear All",
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          onPressed: () {
                            deleteAlItem();
                          })
                    ],
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: copiedTexts.length,
                      itemBuilder: (context, index) {
                        final count = index + 1;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {
                              Clipboard.setData(ClipboardData(
                                  text: copiedTexts[
                                      index])); // Copy text to clipboard
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Copied',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Color(0xff1E1F22),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                      child: Text(
                                    copiedTexts[index],
                                    maxLines: 6,
                                  )),
                                  IconButton(
                                      onPressed: () {
                                        deleteItem(index);
                                      },
                                      icon: const Icon(
                                        Icons.delete,
                                        size: 20,
                                      )),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                ],
              )
            : const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Empty",
                      style: TextStyle(fontSize: 20),
                    ),
                    Icon(
                      Icons.paste,
                      size: 20,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
