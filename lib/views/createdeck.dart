// ignore_for_file: must_be_immutable, unused_import

import 'package:flutter/material.dart';
import 'dart:convert' show json;
import 'package:mp3/views/deck.dart';

class CreateDeck extends StatefulWidget {
  final List<DeckTable> data;
  final int deckCount;

  const CreateDeck({
    Key? key,
    required this.data,
    required this.deckCount,
  }) : super(key: key);

  @override
  State<CreateDeck> createState() => _CreateDeckState();
}

class _CreateDeckState extends State<CreateDeck> {
  final TextEditingController _textController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); 
  final DBHelper dbHelper = DBHelper();

  void _saveDeck() {
    if (_formKey.currentState!.validate()) {
      String newDeckName = _textController.text.trim();
      DeckTable newDeck = DeckTable(id: widget.deckCount, title: newDeckName);

      dbHelper.insertDeck(newDeck).then((id) {
        if (id > 0) {
          setState(() {
            widget.data.add(newDeck);
          });
          Navigator.pop(context, widget.data);
        }
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create deck. Please try again.')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Add New Deck'),
        backgroundColor: const Color.fromARGB(255, 133, 143, 131),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context, widget.data),
        ),
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
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _textController,
                decoration: InputDecoration(
                  labelText: 'Deck Name',
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
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a deck name.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveDeck,
                style: ElevatedButton.styleFrom(
                  foregroundColor: const Color.fromRGBO(13, 51, 31, 1), backgroundColor: Colors.white, 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
