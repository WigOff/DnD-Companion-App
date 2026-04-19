# 🐉 DnD Companion App

A cross-platform companion application for Dungeons & Dragons, designed to help players and Dungeon Masters keep track of their campaigns, manage game states, and streamline gameplay. 

Built with a **Flutter** frontend for cross-platform support, a **Python** backend for handling game logic, and **MongoDB** for robust, scalable data persistence.

## 🛠️ Tech Stack

* **Frontend:** [Flutter](https://flutter.dev/) & Dart (Supports Android, iOS, Windows, macOS, Linux, and Web)
* **Backend:** Python
* **Database:** MongoDB

## ✨ Features

* **Cross-Platform:** Run the app seamlessly on desktop, mobile, or web.
* **Real-time Game State:** The Python server manages the campaign variables, character stats, and session data.
* **Persistent Storage:** MongoDB integration ensures that all campaign progress, character sheets, and items are securely saved and easily queryable.
* **Local Backend Server:** Easy to spin up a local instance for your D&D group.

---

## 🚀 Getting Started

To run this project locally, you will need to set up the Python backend server, your MongoDB database, and the Flutter frontend.

### Prerequisites

* [Flutter SDK](https://docs.flutter.dev/get-started/install)
* [Python 3.8+](https://www.python.org/downloads/)
* Pip (Python package manager)
* A running [MongoDB](https://www.mongodb.com/try/download/community) instance (local or cloud-based like MongoDB Atlas)

### 1. Database Setup (MongoDB)

1. Ensure MongoDB is installed and running on your machine, or have a MongoDB Atlas connection string ready.
2. If your Python backend requires environment variables for the database connection (e.g., a `.env` file), create one in the root directory:
   ```env
   MONGO_URI=mongodb://localhost:27017/dnd_companion
   ```

### 2. Backend Setup (Python)

The backend relies on a Python server to communicate with MongoDB and serve data to the Flutter app.

1.  Navigate to the root directory of the project.
2.  Install the required Python dependencies:
    ```bash
    pip install -r requirements.txt
    ```
3.  Start the backend server:
    ```bash
    python server.py
    ```

### 3. Frontend Setup (Flutter)

1.  Open a new terminal window and ensure you are in the root directory.
2.  Install the Flutter dependencies:
    ```bash
    flutter pub get
    ```
3.  Run the application on your desired device (e.g., Chrome, Android Emulator, Desktop):
    ```bash
    flutter run
    ```

---

## 📂 Project Structure

```text
DnD-Companion-App/
├── lib/                   # Flutter frontend code (Dart)
├── server.py              # Python backend server script routing to MongoDB
├── requirements.txt       # Python dependencies (e.g., pymongo, flask/fastapi)
├── pubspec.yaml           # Flutter project configurations and dependencies
├── android/, ios/         # Native mobile build folders
├── macos/, windows/, linux/ # Native desktop build folders
└── web/                   # Web build folder
```

## 🤝 Contributing

Contributions are welcome! If you'd like to improve the app or add new D&D utilities:
1. Fork the repository
2. Create your feature branch (`git checkout -b feature/NewFeature`)
3. Commit your changes (`git commit -m 'Add some NewFeature'`)
4. Push to the branch (`git push origin feature/NewFeature`)
5. Open a Pull Request

## 📄 License

This project is open-source.

*Created by [WigOff](https://github.com/WigOff)*
