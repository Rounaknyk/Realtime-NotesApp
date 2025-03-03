Realtime Notes App - Setup Instructions

1. Clone the Repository

   Open your terminal and run the following command to clone the repository:
    git clone https://github.com/Rounaknyk/Realtime-NotesApp.git

   Navigate to the project directory:
    cd Realtime-NotesApp

2. Set Up the Node.js Server

   Navigate to the services directory:
    cd services

   Install the required dependencies:
    npm install

   Open the .env file and ensure the IP and PORT are correctly configured. For example:
    PORT=3000
    IP=0.0.0.0

   Start the Node.js server in development mode:
    npm run dev

3. Set Up the Flutter App

   Navigate back to the root directory of the project:
    cd ..

   Install Flutter dependencies:
    flutter pub get

   Update the API base URL in the lib/utils/constants.dart to match the IP and port of your Node.js server. For example:
    // In lib/utils/constants.dart
    String kBaseUrl = "http://0.0.0.0:3000";

   Run the Flutter app on Chrome:
    flutter run -d chrome
