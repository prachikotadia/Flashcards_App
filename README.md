
# Flashcards App

## 1. Overview

This project is a Flutter-based multi-page application that allows users to create, edit, and manage decks of two-sided flashcards (with questions on one side and answers on the other). The app also includes a quiz mode to help users review the flashcards. All data, including decks and flashcards, is persisted using an SQLite database, ensuring that user-created content is saved across sessions.

## 2. Features

The Flashcards app supports the following features:

1. **Create, Edit, Delete Decks**: Users can create new decks, update their titles, and delete them.
2. **Create, Edit, Sort, Delete Flashcards**: Each deck contains flashcards, which can be created, updated, sorted, or deleted.
3. **Persistent Data**: Data is stored in a local SQLite database, ensuring all decks and flashcards are saved even after the app restarts.
4. **JSON Initialization**: Users can load a starter set of decks and flashcards from a pre-configured JSON file.
5. **Quiz Mode**: Users can select a deck to quiz themselves, reviewing the flashcards in a shuffled order.

## 3. Installation

To run the project locally:

1. Clone the repository:  
   ```bash
   git clone https://github.com/yourusername/flashcards-app.git
   ```
2. Navigate to the project directory:  
   ```bash
   cd flashcards-app
   ```
3. Install the necessary dependencies:  
   ```bash
   flutter pub get
   ```
4. Run the app on a connected device or simulator:  
   ```bash
   flutter run
   ```

## 4. Dependencies

The project makes use of the following external packages:

- **provider**: For state management
- **collection**: Provides utilities for list and map operations
- **sqflite**: A package for persisting data to an SQLite database
- **path_provider**: Helps in locating common filesystem locations
- **path**: For managing file and directory paths

## 5. Database

The app uses the `sqflite` package to store data in a local SQLite database. The data schema includes two tables: one for decks and one for cards, linked by a foreign key. The database file is stored in an appropriate location using `path_provider` and `path`.

## 6. Navigation

The app uses Flutter’s `Navigator` for managing screen transitions. It includes multiple screens:

- **Deck List Page**: Displays a scrollable list of created decks.
- **Deck Editor Page**: Allows the user to update the deck title or delete the deck.
- **Card List Page**: Displays all cards in a selected deck, allowing the user to view or edit individual cards.
- **Card Editor Page**: Provides a UI for editing the card’s question and answer.
- **Quiz Page**: Runs a quiz by showing the flashcards from a selected deck in a shuffled order.

## 7. Responsiveness

The UI adapts to various screen sizes, providing an optimal experience on both mobile devices and larger screens. The layout adjusts dynamically, and on larger screens, the deck and card lists may be merged into a single view.

## 8. JSON Initialization

The app can load a set of predefined decks and flashcards from a JSON file located in the `assets` folder. This feature is available via a button on the deck list page.

## 9. Testing

This app has been tested on various screen sizes, including mobile and desktop environments. It should run smoothly without any errors or UI issues across devices.
