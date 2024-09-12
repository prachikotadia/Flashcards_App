// ignore_for_file: unused_import, must_be_immutable, non_constant_identifier_names, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'deck.dart';
import 'dart:convert' show json;

class CreateFlashCard extends StatefulWidget {
  final List<Flashcard> data;
  final int deckCount;
  final int deck_id;

  const CreateFlashCard({
    Key? key,
    required this.data,
    required this.deckCount,
    required this.deck_id,
  }) : super(key: key);

  @override
  State<CreateFlashCard> createState() => _CreateFlashCardState();
}

class _CreateFlashCardState extends State<CreateFlashCard> {
  final DBHelper dbHelper = DBHelper();
  final TextEditingController _questionTextController = TextEditingController();
  final TextEditingController _answerTextController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleCreateFlashCard() async {
    if (_questionTextController.text.isEmpty || _answerTextController.text.isEmpty) {
      _showSnackBar("Please fill out all fields", Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    String question = _questionTextController.text.trim();
    String answer = _answerTextController.text.trim();

    Flashcard newFlashcard = Flashcard(
      id: widget.data.length, 
      question: question,
      answer: answer,
      deck_id: widget.deck_id,
    );

    try {
      await dbHelper.insertFlashcard(newFlashcard); 
      setState(() {
        widget.data.add(newFlashcard);
        _isLoading = false;
      });

      Navigator.pop(context, widget.data);
      _showSnackBar("Flashcard successfully added!", Colors.green);
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar("Failed to add flashcard. Please try again.", Colors.red);
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              if (!_isLoading) { 
                Navigator.pop(context, widget.data);
              }
            },
            icon: const Icon(Icons.arrow_back_sharp, color: Colors.white)),
        title: const Text('Add New Card', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 133, 143, 131),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 18, 54, 25), Color.fromARGB(255, 149, 158, 128)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: _isLoading ? const Center(child: CircularProgressIndicator()) : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(_questionTextController, 'Question'),
            const SizedBox(height: 20),
            _buildTextField(_answerTextController, 'Answer'),
            const SizedBox(height: 50),
            Center(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleCreateFlashCard,
                style: ElevatedButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 149, 129, 184), backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('Save', style: TextStyle(color: Color.fromRGBO(13, 51, 31, 1))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText) => TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: Colors.white),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25.0),
        borderSide: const BorderSide(color: Colors.white),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25.0),
        borderSide: const BorderSide(color: Colors.white),
      ),
    ),
    style: const TextStyle(color: Colors.white),
  );
}
