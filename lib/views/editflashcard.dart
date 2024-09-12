// ignore_for_file: duplicate_import, unnecessary_this, prefer_initializing_formals, non_constant_identifier_names, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:mp3/views/deck.dart'; 
import 'package:flutter/material.dart';
import 'package:mp3/views/deck.dart';

class EditFlashCard extends StatefulWidget {
  final List<Flashcard> data;
  final String Que;
  final int cardID;
  final int Cardindex;
  final int IDdeck;

  const EditFlashCard({
    Key? key,
    required List<Flashcard> data,
    required String Que,
    required int cardID,
    required int Cardindex,
    required int IDdeck,
  })  : this.data = data,
        this.Que = Que,
        this.cardID = cardID,
        this.Cardindex = Cardindex,
        this.IDdeck = IDdeck,
        super(key: key);

  @override
  _EditFlashCardState createState() => _EditFlashCardState();
}

class _EditFlashCardState extends State<EditFlashCard> {
  late TextEditingController _QueTextController, _answerTextController;
  final _dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    _QueTextController = TextEditingController(text: widget.Que);
    _answerTextController = TextEditingController(text: widget.data[widget.Cardindex].answer);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text("Edit Flashcard", style: TextStyle(fontWeight: FontWeight.bold)),
      backgroundColor: const Color.fromARGB(255, 133, 143, 131),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context, widget.data),
      ),
    );
  }

  Widget _buildBody() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color.fromARGB(255, 76, 112, 101), Color.fromARGB(255, 20, 57, 33)],
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(label: "Que", controller: _QueTextController),
            const SizedBox(height: 30),
            _buildTextField(label: "Answer", controller: _answerTextController),
            const SizedBox(height: 40),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required String label, required TextEditingController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 18, color: Colors.white70, fontWeight: FontWeight.bold)),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Enter here",
            hintStyle: TextStyle(color: Colors.white70),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildButton(icon: Icons.save, label: 'Save', onPressed: _saveFlashCard),
        _buildButton(icon: Icons.delete_forever, label: 'Delete', onPressed: _showDeleteConfirmationDialog),
      ],
    );
  }

  Widget _buildButton({required IconData icon, required String label, required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: const Color.fromARGB(255, 246, 244, 244)),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 158, 193, 159),
      ),
    );
  }

  Future<void> _saveFlashCard() async {
    _dbHelper.updateFlashcard(widget.cardID, _QueTextController.text, _answerTextController.text);
    Navigator.pop(context, widget.data);
  }

  void _showDeleteConfirmationDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const SingleChildScrollView(
            child: ListBody(children: [Text('Are you sure you want to delete this flashcard?')]),
          ),
          actions: <Widget>[
            TextButton(onPressed: Navigator.of(context).pop, child: const Text('Cancel')),
            TextButton(onPressed: _deleteFlashCard, child: const Text('Delete')),
          ],
        );
      },
    );
  }

  void _deleteFlashCard() {
    _dbHelper.deleteFlashcard(widget.cardID);
    Navigator.pop(context, widget.data);
  }
}
