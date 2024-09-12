// ignore_for_file: must_be_immutable, non_constant_identifier_names, unused_local_variable

import 'package:flutter/material.dart';
import 'package:mp3/views/deck.dart';
import 'package:mp3/views/editflashcard.dart';
import 'package:mp3/views/quiz.dart';
import 'package:mp3/views/createflashcard.dart';

class FlashCard extends StatefulWidget {
  List<DeckTable> data = [];
  int id = 0;
  int index = 0;
  int count = 0;
  FlashCard({super.key, required this.data, required this.index, required this.id, required this.count});

  @override
  State<FlashCard> createState() => _FlashCardState();
}

class _FlashCardState extends State<FlashCard> {
  final DBHelper dbHelper = DBHelper();
  int count = 0;
  bool sorted = false;
  int leng_flashcard = 0;
  List<Flashcard> raw_dataOfCard = [];
  List<dynamic> dataOfCard = [];
  List<Flashcard> raw_filtereddata = [];
  List<dynamic> filtereddata = [];
  List<Flashcard> dataofFlashcard = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    final fc1 = await dbHelper.getFlashcards(widget.id);
    final fc2 = await dbHelper.getFlashcardsSorted(widget.id);
    final flashcard = await dbHelper.getFlashcard();
    setState(() {
      raw_dataOfCard = fc1;
      raw_filtereddata = fc2;
      dataofFlashcard = flashcard;
      dataOfCard = raw_dataOfCard.map((item) => item.toMap()).toList();
      filtereddata = raw_filtereddata.map((item) => item.toMap()).toList();
      leng_flashcard = widget.count;
      count = dataOfCard.length;
    });
  }

  void toggleButton() {
    setState(() {
      sorted = !sorted;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            widget.data[widget.index].toMap()['title'],
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 20,
              shadows: [
                Shadow(
                  blurRadius: 2.0,
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(1.0, 1.0),
                ),
              ],
            ),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 85, 126, 90),
        leading: Tooltip(
          message: "Back",
          child: IconButton(
            onPressed: () {
              Navigator.pop(context, widget.data);
            },
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
        actions: <Widget>[
          Tooltip(
            message: !sorted ? "Sort" : "Sorted Alphabetically",
            child: IconButton(
              onPressed: toggleButton,
              icon: Icon(!sorted ? Icons.sort : Icons.sort_by_alpha, color: Colors.white),
            ),
          ),
          Tooltip(
            message: "Start Quiz",
            child: IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Quiz(data: raw_dataOfCard)));
              },
              icon: const Icon(Icons.quiz, color: Colors.white),
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'Settings',
                child: Text('Settings'),
              ),
              const PopupMenuItem<String>(
                value: 'Help',
                child: Text('Help'),
              ),
            ],
            icon: const Icon(Icons.more_vert, color: Colors.white),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
            color: Colors.white.withOpacity(0.5),
            height: 4.0,
          ),
        ),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: screenWidth > 600 ? 4 : 2, 
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
        ),
        itemCount: count,
        itemBuilder: (context, index) {
          final flashcard = sorted ? filtereddata[index] : dataOfCard[index];
          return Card(
            elevation: 5,
            margin: const EdgeInsets.all(8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: InkWell(
              onTap: () async {
                final newData = await Navigator.push(context, MaterialPageRoute(builder: (context) => EditFlashCard(
                  data: sorted ? raw_filtereddata : raw_dataOfCard,
                  cardID: flashcard['id'],
                  Cardindex: index,
                  Que: flashcard['question'],
                  IDdeck: widget.id,
                )));
                loadData();
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [Color.fromARGB(255, 114, 137, 120), Color.fromARGB(255, 81, 153, 80)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(flashcard['question'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newData = await Navigator.push(context, MaterialPageRoute(builder: (context) => CreateFlashCard(
            data: dataofFlashcard,
            deckCount: leng_flashcard,
            deck_id: widget.id,
          )));
          loadData();
        },
        backgroundColor: const Color.fromARGB(255, 3, 79, 49),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
