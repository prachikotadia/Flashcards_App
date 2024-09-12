// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, non_constant_identifier_names, library_private_types_in_public_api, avoid_print, unnecessary_this, unused_import, unnecessary_import

import 'dart:convert' show json;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:mp3/views/flashcard.dart';
import 'createdeck.dart';
import 'editdeck.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';

class DeckTable {
  final int id;
  final String title;

  DeckTable({required this.id, required this.title});

  Map<String, dynamic> toMap() => {'id': id, 'title': title};

  factory DeckTable.fromMap(Map<String, dynamic> map) {
    return DeckTable(
      id: map.containsKey('id') ? map['id'] : 0, 
      title: map.containsKey('title') ? map['title'] : '',
    );
  }

  DeckTable copyWith({int? id, String? title}) {
    return DeckTable(
      id: id ?? this.id,
      title: title ?? this.title,
    );
  }

  @override
  String toString() => 'DeckTable(id: $id, title: "$title")';
}

class Flashcard {
  int id = 0;
  String question = "";
  String answer = "";
  int deck_id = 0;

  Flashcard({required this.id, required this.question, required this.answer, required this.deck_id});

  Map<String, dynamic> toMap() {
    return {'id': id, 'question': question, 'answer': answer, 'deck_id': deck_id};
  }

  factory Flashcard.fromMap(Map<String, dynamic> map) {
    return Flashcard(id: map['id'], question: map['question'], answer: map['answer'], deck_id: map['deck_id']);
  }

  void updateQuestionAndAnswer(String newQuestion, String newAnswer) {
    question = newQuestion;
    answer = newAnswer;
  }

  @override
  String toString() {
    return 'Flashcard(id: $id, question: $question, answer: $answer, deck_id: $deck_id)';
  }

  Flashcard copyWith({int? id, String? question, String? answer, int? deck_id}) {
    return Flashcard(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      deck_id: deck_id ?? this.deck_id,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Flashcard &&
        other.id == id &&
        other.question == question &&
        other.answer == answer &&
        other.deck_id == deck_id;
  }

  @override
  int get hashCode => id.hashCode ^ question.hashCode ^ answer.hashCode ^ deck_id.hashCode;

  String toJson() => jsonEncode(toMap());

  factory Flashcard.fromJson(String source) => Flashcard.fromMap(jsonDecode(source));
}


class DBHelper {
  static const String _databaseName = 'flashcards.db';
  static const int _databaseVersion = 1;
  String appDocumentsDirectory = '';
  DBHelper._(); 
  static final DBHelper _singleton = DBHelper._();
  factory DBHelper() => _singleton;
  Database? _database;

  Future<Database> get db async => _database ??= await _initDatabase();
  Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    appDocumentsDirectory = directory.path;
    final dbPath = path.join(appDocumentsDirectory, _databaseName);
    final db = await openDatabase(
      dbPath,
      version: _databaseVersion,
      onCreate: (Database db, int version) async {
        // Grouped table creation commands for clarity and compactness
        var sqlCommands = [
          '''
            CREATE TABLE decks(
              id INTEGER PRIMARY KEY,
              title TEXT
            );
          ''',
          '''
            CREATE TABLE flashcards(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              question TEXT,
              answer TEXT,
              deck_id INTEGER,
              FOREIGN KEY (deck_id) REFERENCES decks(id)
            );
          '''
        ];

        for (var command in sqlCommands) {
          await db.execute(command);
        }
      },
    );
    return db;
  }

Future<int> insertDeck(DeckTable deck) => 
  this.db.then((db) => db.insert('decks', deck.toMap(), conflictAlgorithm: ConflictAlgorithm.replace));

Future<int> insertFlashcard(Flashcard flashcard) => 
  this.db.then((db) => db.insert('flashcards', flashcard.toMap(), conflictAlgorithm: ConflictAlgorithm.replace));

Future<List<DeckTable>> getDecks() => 
  this.db.then((db) => db.query('decks', orderBy: 'id'))
  .then((maps) => maps.map((map) => DeckTable.fromMap(map)).toList());

Future<List<Flashcard>> getFlashcard() => 
  this.db.then((db) => db.query('flashcards'))
  .then((maps) => maps.map((map) => Flashcard.fromMap(map)).toList());

Future<List<Flashcard>> getFlashcards(int deckId) => 
  this.db.then((db) => db.query('flashcards', where: 'deck_id = ?', whereArgs: [deckId]))
  .then((maps) => maps.map((map) => Flashcard.fromMap(map)).toList());

Future<List<Flashcard>> getFlashcardsSorted(int deckId) => 
  this.db.then((db) => db.query('flashcards', where: 'deck_id = ?', whereArgs: [deckId], orderBy: 'question'))
  .then((maps) => maps.map((map) => Flashcard.fromMap(map)).toList());

Future<int> getFlashcardsCount(int deckId) => 
  this.db.then((db) => db.query('flashcards', where: 'deck_id = ?', whereArgs: [deckId]))
  .then((maps) => maps.length);

  Future<void> updateDeck(DeckTable deck, String title) => 
  this.db.then((db) => db.update('decks', deck.toMap(), where: 'title = ?', whereArgs: [deck.title]));

  Future<void> deleteDeck(int id) => 
    this.db.then((db) => Future.wait([
      db.delete('decks', where: 'id = ?', whereArgs: [id]),
      db.delete('flashcards', where: 'deck_id = ?', whereArgs: [id])
    ]));

  Future<void> deleteFlashcard(int id) => 
    this.db.then((db) => db.delete('flashcards', where: 'id = ?', whereArgs: [id]));

  Future<void> deleteAllData() => 
    this.db.then((db) => Future.wait([
      db.delete('decks'),
      db.delete('flashcards')
    ]));

  Future<int> getTableCount() => 
    this.db.then((db) => db.query('flashcards')).then((maps) => maps.length);

  void updateDeckTitle(int id, String updatedTitle) {}
  void updateFlashcard(int deckCardID, String updatedQuestion, String updatedAnswer) {}
}

class Deck extends StatefulWidget {
  const Deck({Key? key}) : super(key: key);

  @override
  _DeckState createState() => _DeckState();
}

class _DeckState extends State<Deck> {
  final DBHelper dbHelper = DBHelper();
  List<dynamic> deck_data = [];
  List<DeckTable> raw_deck_data = [];
  int deck_count = 0;
  int flashcard_count = 0;
  int flashcards_length = 0;

  @override
  void initState() {
    super.initState();
    loadJsonData();
  }

  void loadJsonData() async {
    String jsonString = await rootBundle.loadString('assets/flashcards.json');
    final List<dynamic> jsonData = json.decode(jsonString);
    
    await insertDataIntoDatabase(jsonData);
    await loadDataFromDatabase();
  }

  Future<void> insertDataIntoDatabase(List<dynamic> jsonData) async {
    int deckCount = 0;
    for (final item in jsonData) {
      final deck = DeckTable(id: deckCount, title: item['title']);
      await dbHelper.insertDeck(deck);

      for (final flashcard in item['flashcards']) {
        final card = Flashcard(
          id: flashcard_count,
          question: flashcard['question'],
          answer: flashcard['answer'],
          deck_id: deckCount,
        );
        await dbHelper.insertFlashcard(card);
        flashcard_count++;
      }
      deckCount++;
    }
  }

  Future<void> loadDataFromDatabase() async {
    final decks = await dbHelper.getDecks();
    setState(() {
      raw_deck_data = decks;
      deck_data = raw_deck_data.map((item) => item.toMap()).toList();
    });
    flashcards_length = await dbHelper.getTableCount();
  }

    void loadJsonDataAgain() async {
    String jsonString = await rootBundle.loadString('assets/flashcards.json');
    final List<dynamic> jsonData = json.decode(jsonString);
    
    int newDeckCount = raw_deck_data.length;

    for (final item in jsonData) {
      final deck = DeckTable(id: newDeckCount, title: item['title']);
      await dbHelper.insertDeck(deck);

      for (final flashcard in item['flashcards']) {
        final card = Flashcard(
            id: flashcard_count,
            question: flashcard['question'],
            answer: flashcard['answer'],
            deck_id: newDeckCount);
        await dbHelper.insertFlashcard(card);
        flashcard_count++;
      }

      newDeckCount++;
    }

    updateDeckData(newDeckCount);
    }

  void updateDeckData(int newDeckCount) async {
    final decks = await dbHelper.getDecks();
    setState(() {
      raw_deck_data = decks;
      deck_data = raw_deck_data.map((item) => item.toMap()).toList();
    });
    deck_count = newDeckCount;
  }

  void delete() async {
    await dbHelper.deleteAllData();
  }

  @override
    Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final deckCount = screenWidth ~/ 200;
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Flashcard Decks"),
          backgroundColor: Color.fromARGB(255, 97, 112, 106),
          actions: [
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: loadJsonDataAgain,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: delete,
            ),
          ],
        ),
      body: GridView.count(
        crossAxisCount: deckCount,
        padding: const EdgeInsets.all(4),
        children: List.generate(deck_data.length, (index) {
          return Card(
            elevation: 4.0, 
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20), 
            ),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromARGB(255, 220, 238, 192), 
                  Color(0xFF43563A),
                ],
              ),
                borderRadius: BorderRadius.circular(10), 
              ),
              child: Stack(
                children: [
                  InkWell(
                      onTap: () => index < deck_data.length ? Navigator.push(
                        context, 
                        MaterialPageRoute(
                          builder: (context) => FlashCard(
                            data: raw_deck_data,
                            id: deck_data[index]['id'],
                            index: index,
                            count: flashcards_length - 1,
                          ),
                        ),
                      ) : print(flashcards_length - 1),
                      child: Center(
                        child: Text(deck_data[index]['title']),
                      ),
                    ),
                 Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          var updatedData = await Navigator.push<List<DeckTable>>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditDeck(
                                data: raw_deck_data,
                                id: deck_data[index]['id'],
                                title: deck_data[index]['title'],
                              ),
                            ),
                          );

                          if (updatedData != null) {
                            setState(() {
                              raw_deck_data = updatedData;
                              deck_data = raw_deck_data.map((item) => item.toMap()).toList();
                            });
                          }
                        },
                      ),
                    ),
                  Positioned(
                    top: 16,
                    left: 0,
                    child: FutureBuilder<int>(
                      future: dbHelper.getFlashcardsCount(deck_data[index]['id']),
                      builder: (context, snapshot) {
                        String text;
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                            text = "Count: Loading...";
                            break;
                          case ConnectionState.done:
                          default:
                            text = snapshot.hasError ? "Count: Error" : " Count: ${snapshot.data}";
                            break;
                        }
                        return Text(text);
                      },
                    ),
                  )
                ],
              ),
            ),
          );
        }),
      ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final newData = await Navigator.push<List<DeckTable>>(
              context,
              MaterialPageRoute(builder: (context) => CreateDeck(data: raw_deck_data, deckCount: raw_deck_data.length)),
            );

            if (newData != null) {
              setState(() {
                raw_deck_data = newData;
                deck_data = newData.map((item) => item.toMap()).toList();
              });
            }
          },
          child: Icon(Icons.add),
        ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
