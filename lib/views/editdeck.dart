// ignore_for_file: must_be_immutable, unused_import, unnecessary_import, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mp3/views/deck.dart';
import 'package:mp3/views/flashcard.dart';

class EditDeck extends StatefulWidget {
  final List<DeckTable> data;
  final String title;
  final int id;

  const EditDeck({
    Key? key,
    required this.data,
    required this.id,
    required this.title,
  }) : super(key: key);

  @override
  State<EditDeck> createState() => _EditDeckState();
}

class _EditDeckState extends State<EditDeck> {
  final DBHelper dbHelper = DBHelper();
  TextEditingController textController = TextEditingController();
  TextEditingController descriptionController = TextEditingController(); 

  @override
  void initState() {
    super.initState();
    textController = TextEditingController(text: widget.title);
  }

  void deleteDeckAndNavigateBack() async {
    await dbHelper.deleteDeck(widget.id);
    widget.data.removeWhere((element) => element.toMap()["id"] == widget.id);
    Navigator.pop(context, widget.data);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Flashcard deleted successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Edit Deck Name'),
        backgroundColor: const Color.fromARGB(255, 87, 104, 88), 
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context, widget.data);
          },
          icon: const Icon(Icons.arrow_back_sharp, color: Colors.white),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 40, 61, 41), Color.fromARGB(255, 87, 111, 68)], 
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView( 
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, 
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch, 
              children: [
                TextField(
                  controller: textController,
                  decoration: InputDecoration(
                    labelText: 'Deck Name',
                    labelStyle: const TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white54),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description (optional)',
                    labelStyle: const TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white54),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  maxLines: 3,
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      onPressed: () {
                      },
                      text: 'Save',
                      color: const Color.fromARGB(255, 236, 246, 237), 
                    ),
                    _buildActionButton(
                      onPressed: deleteDeckAndNavigateBack,
                      text: 'Delete',
                      color: const Color.fromARGB(255, 233, 245, 234), 
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({required VoidCallback onPressed, required String text, required Color color}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: const Color.fromARGB(255, 18, 33, 23), backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      ),
      child: Text(text),
    );
  }
}
