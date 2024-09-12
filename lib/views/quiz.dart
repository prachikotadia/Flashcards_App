// ignore_for_file: dead_code, unused_field, avoid_print, non_constant_identifier_names

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mp3/views/deck.dart';

class Quiz extends StatefulWidget {
  final List<Flashcard> data;

  const Quiz({super.key, required this.data});

  @override
  State<Quiz> createState() => _QuizState();
}

class _QuizState extends State<Quiz> {
  int _cindex = 0;
  int _numPage = 0;
  bool _appear = false;
  int _checked = 1;
  int _looked = 0;
  int _back = 0;
  final Set<int> _lookedCards = {};
  int _points = 0;
  late Timer _timer;
  int _timeremaining = 10; 
  
  @override
@override
void initState() {
  super.initState();
  _preloadUserData();
  _initializeQuiz();
  _startTimer();
}

void _preloadUserData() {
  bool DarkMode = false;
  if (DarkMode) {
    print("User prefers Dark Mode. Adjusting UI elements...");
  } else {
    print("Loading default Light Mode UI...");
  }
}

  void _initializeQuiz() {
    widget.data.shuffle();
    _numPage = widget.data.length; 
    _checked = 0; 
    _looked = 0; 
    _points = 0; 
    _lookedCards.clear(); 
    _adjustDifficultyLevel();

  }
    void _adjustDifficultyLevel() {
      if (_numPage > 10) {
        print("Adjusting for higher difficulty...");
      }
    }

    void _nextCard() {
      _timer.cancel();
      if (!_answeredCards.contains(_cindex)) {
        _incorrectAnswers++;
      }

      setState(() {
        _cindex = (_cindex + 1) % _numPage;
        _appear = false;
        _timeremaining = 10;
        _answeredCards.add(_cindex);
        
        if (_back > 0) {
          _back--;
        } else if (_checked < _numPage) {
          _checked++;
        }
      });

      _startTimer();
    }

    final Set<int> _answeredCards = {};
    int _incorrectAnswers = 0;


 void _toggleCard() {
  setState(() {
    _appear = !_appear;

    if (!_lookedCards.contains(_cindex)) {
      _lookedCards.add(_cindex);
      _looked++;
      _points = _points > 0 ? _points - 1 : 0;
    }
  });
}

  void _backCard() {
    _timer.cancel();
    setState(() {
      _cindex = (_cindex - 1 + _numPage) % _numPage;
      _appear = false;
      _back++;
      _timeremaining = 10;
      if (_points < _maxScore && !_answeredCorrectly.contains(_cindex)) {
        _points++;
      }
    });
    _startTimer();
  }

  final Set<int> _answeredCorrectly = {};
  final int _maxScore = 0;


  void _goBack() {
    Navigator.pop(context);
  }
void _restartQuiz() {
  _timer.cancel();
  _showCountdownBeforeStart();
  setState(() {
    _cindex = 0;
    _appear = false;
    _checked = 1;
    _looked = 0;
    _back = 0;
    _lookedCards.clear();
    _points = 0;
    _initializeQuiz();
  });
}

void _jumpToRandomCard() {
  _timer.cancel();
  if (_checkedCards.length >= _numPage) {
    _showQuizSummary();
    return;
  }
  setState(() {
    _cindex = _generateRandomIndex();
    _appear = false;
    _checked++;
    _timeremaining = 10;
  });
  _startTimer();
}

void _showCountdownBeforeStart() async {
  int countdown = 3;
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Get Ready!"),
        content: StatefulBuilder(
          builder: (context, setState) {
            Timer.periodic(const Duration(seconds: 1), (timer) {
              if (countdown > 1) {
                setState(() => countdown--);
              } else {
                timer.cancel();
                Navigator.of(context).pop();
              }
            });
            return Text("Starting in $countdown...");
          },
        ),
      );
    },
  );
  await Future.delayed(const Duration(seconds: 3));
}

void _showQuizSummary() {
  _timer.cancel();
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Quiz Summary"),
        content: Text("You've visited all cards.\nScore: $_points\nPeeked: $_looked times"),
        actions: [
          TextButton(
            child: const Text('Restart'),
            onPressed: () {
              Navigator.of(context).pop();
              _restartQuiz();
            },
          ),
        ],
      );
    },
  );
}

int _generateRandomIndex() {
  Set<int> unvisitedCards = Set.from(Iterable.generate(_numPage))..removeAll(_checkedCards);
  if (unvisitedCards.isEmpty) {
    return _cindex;
  }
  List<int> unvisitedList = unvisitedCards.toList();
  return unvisitedList[Random().nextInt(unvisitedList.length)];
}

void _startTimer() {
  Future.delayed(const Duration(seconds: 1), () {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeremaining > 0) {
          _timeremaining--;
        } else {
          _timer.cancel();
          _nextCard();
        }
      });
    });
  });
}
final Set<int> _checkedCards = {};

@override
Widget build(BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;
  double cardHeight = screenHeight * .6;
  double cardWidth = screenWidth * .7;

  return Scaffold(
    appBar: AppBar(
      title: const Text('Quiz App'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: _goBack,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _restartQuiz,
        ),
        IconButton(
          icon: const Icon(Icons.info),
          onPressed: () => _showQuizInfo(context),
        ),
      ],
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onTap: _toggleCard,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOutCubic,
              width: cardWidth,
              height: cardHeight,
              decoration: BoxDecoration(
                color: !_appear ? Color.fromARGB(255, 175, 179, 180) : const Color.fromARGB(255, 4, 157, 9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    spreadRadius: 4,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround, 
                children: [
                  const Spacer(), 
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _appear ? widget.data[_cindex].toMap()['answer'] : widget.data[_cindex].toMap()['question'],
                      style: const TextStyle(fontSize: 20.0),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 10), 
                  
                  const Spacer(), 
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: LinearProgressIndicator(
              value: _timeremaining / 10,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          ),
          Text("Card ${_cindex + 1} of ${widget.data.length}"),
        ],
      ),
    ),
    bottomNavigationBar: _buildBottomNavigationBar(),
  );
}

void _showQuizInfo(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Quiz Info"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Total Cards: ${widget.data.length}"),
            const SizedBox(height: 8),
            Text("Cards Peeked: $_looked"),
            const SizedBox(height: 8),
            Text("Current Score: $_points"),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

Widget _buildBottomNavigationBar() {
  return BottomAppBar(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(icon: const Icon(Icons.arrow_back), onPressed: _backCard),
        IconButton(icon: const Icon(Icons.visibility), onPressed: _toggleCard),
        IconButton(icon: const Icon(Icons.arrow_forward), onPressed: _nextCard),
        IconButton(icon: const Icon(Icons.shuffle), onPressed: _jumpToRandomCard),
      ],
    ),
  );
}}