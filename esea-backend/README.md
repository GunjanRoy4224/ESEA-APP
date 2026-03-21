📌 Project Overview

The App is a full-stack academic management application designed to handle student timetables, courses, materials, and administration tasks in a structured and scalable way.

The system consists of:

A Flutter mobile application for students and admins

A FastAPI backend that provides secure REST APIs

A PostgreSQL database for persistent data storage

The project follows clean frontend–backend contracts, modular design, and real-world app development practices.

🚀 Features
👨‍🎓 Student Features

Secure login using SSO (OAuth-based authentication)

View personal timetable

Automatic slot conflict detection

View currently running courses

Access course materials

Profile details (name, roll number, department, year)

Cached timetable for faster app loading

👨‍🏫 Admin Features

Admin dashboard

Department and course management

Timetable creation and updates

Course material uploads

Student data access

Role-based API protection

⚙️ System Features

RESTful APIs using FastAPI

PostgreSQL database

JWT-based authentication

Error handling and logging

Modular and scalable architecture

Clear separation of frontend and backend logic

🛠️ Tech Stack
Frontend

Flutter

Dart

Dio (HTTP client)

Material UI

Backend

Python

FastAPI

SQLAlchemy

OAuth (SSO Integration)

Database

PostgreSQL

📂 Project Structure
Flutter Frontend
lib/
├── constants/      # API endpoints
├── models/         # Data models
├── services/       # API service classes
├── screens/        # App screens
│   └── timetable/
├── widgets/        # Reusable UI widgets
└── main.dart

FastAPI Backend
app/
├── routers/        # API routes
├── models/         # Database models
├── schemas/        # Pydantic schemas
├── services/       # Business logic
├── database.py
└── main.py

🔐 Authentication Flow

User logs in using SSO

Backend verifies OAuth token

JWT token is issued

Role (student/admin) is determined server-side

Secure APIs are accessed using JWT

📅 Timetable Module

Timetable is fetched using /timetable/student

Slot-based system using slot_code

Conflict detection handled in frontend logic

Running class detection based on current time

API response cached for performance

🧪 Error Handling

Backend returns structured JSON error responses

Frontend handles:

Network errors

Empty responses

Authentication failures

Loading indicators and fallback UI implemented

▶️ How to Run the Project
✅ Prerequisites

Flutter SDK installed

Python 3.10+

PostgreSQL installed and running

Git

🖥️ Backend Setup (FastAPI)

Navigate to backend directory:

cd esea-backend


Create and activate virtual environment:

python -m venv venv
venv\Scripts\activate     # Windows
# source venv/bin/activate  # Linux / macOS


Install dependencies:

pip install -r requirements.txt


Set environment variables (example):

DATABASE_URL=postgresql://username:password@localhost:5432/esea_db
SSO_CLIENT_ID=your_client_id
SSO_AUTH_URL=your_sso_auth_url
SECRET_KEY=your_secret_key


Run backend server:

uvicorn app.main:app --reload


Backend runs at:

http://127.0.0.1:8000

📱 Frontend Setup (Flutter)

Navigate to frontend directory:

cd esea_app


Install dependencies:

flutter pub get


Ensure backend URL is correct:

// lib/constants/api_constants.dart
static const String baseUrl = "http://127.0.0.1:8000/api";


Run the app:

flutter run

🧠 Design Decisions

API-driven architecture

Strongly typed models

Centralized API constants

Backend controls business logic

Frontend focuses on UI and state management

🔄 Future Improvements

UI/UX enhancements

Attendance tracking

Push notifications

Offline support

Docker-based deployment

Separate development and production environments

👤 Author

Gunjan Kumar
App Development Project
Flutter + FastAPI
