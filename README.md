# ♻️ EcoScan - Intelligent Waste Classification

> **Project de Fin d'Année (PFA) - Engineering Cycle**
> *Real-time waste classification using Deep Learning and Cross-Platform Mobile Development.*

---

## 📄 Project Report & Context

### 1. Introduction
Waste management is a critical global challenge. Proper segregation is the first step towards effective recycling. "EcoScan" is an intelligent mobile application designed to assist users in identifying waste types instantly using Artificial Intelligence.

### 2. Objectives
- **Automate** the recognition of waste categories (e.g., Plastic, Glass, Paper).
- **Provide** a seamless, user-friendly mobile experience.
- **Demonstrate** the integration of a Deep Learning model with a modern mobile framework.

### 3. Architecture
The project follows a robust **Client-Server Architecture**:
*   **📱 Client (Frontend)**: Developed with **Flutter**, ensuring a native experience on both Android and iOS. It handles image capture and displays results.
*   **🧠 Server (Backend)**: Built with **FastAPI (Python)**. It hosts the AI model, processes incoming images, and returns predictions.
*   **🤖 AI Model**: A **MobileNetV3** Convolutional Neural Network (CNN), fine-tuned via Transfer Learning on a dataset of 12 waste classes (Accuracy: ~94%).

---

## 🛠️ Technical Stack

### Frontend (Mobile)
*   **Framework**: Flutter 3.x (Dart)
*   **Packages**:
    *   `image_picker`: For accessing Camera and Gallery.
    *   `http`: For REST API communication.
*   **Key Features**:
    *   Cross-Platform IP detection (Auto-switch `10.0.2.2` vs `localhost`).
    *   Premium "Eco-friendly" UI design.

### Backend (API & AI)
*   **Framework**: FastAPI (Python)
*   **Server**: Uvicorn (ASGI)
*   **ML Library**: PyTorch & Torchvision
*   **Model**: MobileNetV3 Large (State Dict loaded dynamically)

---

## 🚀 How to Run the Project

Follow these steps to set up the environment and launch the full system.

### Prerequisites
*   [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
*   Python 3.8+ installed.

### Step 1: Start the AI Backend
The backend serves the MobileNetV3 model. We provided a script to automate the setup.

1.  Open a terminal in the project root.
2.  Run the helper script:
    ```bash
    ./start_backend.sh
    ```
    *This script will activate the virtual environment and start the server on `http://0.0.0.0:8000`.*

### Step 2: Run the Mobile App
1.  Open a **new terminal** setup.
2.  Install Flutter dependencies:
    ```bash
    flutter pub get
    ```
3.  Run the app on your connected device or emulator:
    ```bash
    flutter run
    ```

> **Note for Emulators**:
> *   **Android Emulator**: The app automatically connects to `10.0.2.2`.
> *   **iOS Simulator**: The app automatically connects to `127.0.0.1`.

---

## 🌟 Key Features
*   **📸 Any Source**: Analyze photos from Camera or Gallery.
*   **⚡ Instant AI**: < 1s inference time thanks to MobileNetV3.
*   **📊 Confidence Score**: Visual gauge showing how sure the AI is about the result.
*   **🎨 Premium UI**: Modern, clean, and animated interface.

---

## 📂 Project Structure
*   `lib/main.dart` -> The brain of the Mobile App (UI + Logic).
*   `backend/main.py` -> The brain of the AI Server (FastAPI + PyTorch).
*   `backend/best_waste_model.pth` -> The trained neural network weights.
*   `ios/Runner/Info.plist` -> iOS Permissions configuration.

---

*Developed by Abdelhak Mirbah - EMSI 2025*
