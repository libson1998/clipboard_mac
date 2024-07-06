import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClipboardListenerScreen extends StatefulWidget {
  const ClipboardListenerScreen({super.key});

  @override
  _ClipboardListenerScreenState createState() =>
      _ClipboardListenerScreenState();
}

class _ClipboardListenerScreenState extends State<ClipboardListenerScreen> {
  List<String> copiedTexts = [];
  List<String> favoriteTexts = [];
  static const MethodChannel _channel = MethodChannel('clipboard_monitor');

  @override
  void initState() {
    super.initState();
    _channel.setMethodCallHandler(_handleMethod);
    _loadFavorites();
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    if (call.method == 'clipboardChanged') {
      setState(() {
        copiedTexts.insert(0, call.arguments as String);
        _reorderCopiedTexts();
      });
    }
    return null;
  }
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _channel.setMethodCallHandler(_handleMethod);
      _loadFavorites();
      setState(() {});
    }
  }
  void deleteItem(int index) {
    setState(() {
      copiedTexts.removeAt(index);
      _reorderCopiedTexts();
    });
  }

  void deleteAllItems() {
    setState(() {
      copiedTexts.clear();
    });
  }

  void toggleFavorite(String text) async {
    setState(() {
      if (favoriteTexts.contains(text)) {
        favoriteTexts.remove(text);
      } else {
        favoriteTexts.add(text);
      }
      _reorderCopiedTexts();
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', favoriteTexts);
  }

  void _reorderCopiedTexts() {
    final favoriteItems = copiedTexts.where((text) => favoriteTexts.contains(text)).toList();
    final nonFavoriteItems = copiedTexts.where((text) => !favoriteTexts.contains(text)).toList();
    copiedTexts = [...favoriteItems, ...nonFavoriteItems];
  }

  void _loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      favoriteTexts = prefs.getStringList('favorites') ?? [];
      _reorderCopiedTexts();
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
                      deleteAllItems();
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
                  final text = copiedTexts[index];
                  final isFavorite = favoriteTexts.contains(text);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: text)); // Copy text to clipboard
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
                          color: isFavorite ? Colors.yellow.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () {
                                toggleFavorite(text);
                              },
                              icon: Icon(
                                isFavorite ? Icons.star : Icons.star_border,
                                color: isFavorite ? Colors.yellow : Colors.grey,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                text,
                                maxLines: 6,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                deleteItem(index);
                              },
                              icon: const Icon(
                                Icons.delete,
                                size: 20,
                              ),
                            ),
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
