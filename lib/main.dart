import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const WasteClassificationApp());
}

class WasteClassificationApp extends StatelessWidget {
  const WasteClassificationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EcoScan',
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32), // Eco Green
          secondary: const Color(0xFF81C784),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Color(0xFF1B5E20),
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),
      ),
      home: const ClassificationScreen(),
    );
  }
}

class ClassificationScreen extends StatefulWidget {
  const ClassificationScreen({super.key});

  @override
  State<ClassificationScreen> createState() => _ClassificationScreenState();
}

class _ClassificationScreenState extends State<ClassificationScreen> {
  File? _image;
  String? _result;
  double? _confidence;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  // Platform-aware URL
  String get _backendUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/predict';
    } else {
      return 'http://127.0.0.1:8000/predict'; 
    }
  } 

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _result = null;
        _confidence = null;
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      var request = http.MultipartRequest('POST', Uri.parse(_backendUrl));
      request.files.add(await http.MultipartFile.fromPath('file', _image!.path));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        setState(() {
          _result = jsonResponse['class'];
          _confidence = jsonResponse['confidence'];
        });
      } else {
        _showError("Erreur serveur: ${response.statusCode}");
      }
    } catch (e) {
      _showError("Erreur de connexion: Assurez-vous que le backend tourne.");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  Color _getResultColor() {
    // Simple logic: Green for recyclable (placeholder), Orange for others
    // You can expand this based on specific classes like "Plastic", "Glass"
    if (_result == null) return Colors.grey;
    if (['Cardboard', 'Glass', 'Metal', 'Paper', 'Plastic'].contains(_result)) {
      return const Color(0xFF43A047); // Green
    }
    return const Color(0xFFFB8C00); // Orange
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.eco, color: Color(0xFF2E7D32)),
            SizedBox(width: 8),
            Text('EcoScan'),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Image Container
              Center(
                child: Container(
                  height: 320,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: _image != null
                        ? Image.file(_image!, fit: BoxFit.cover)
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_outlined, 
                                   size: 80, 
                                   color: Colors.grey[300]),
                              const SizedBox(height: 10),
                              Text(
                                "Mettez un déchet ici",
                                style: TextStyle(color: Colors.grey[400]),
                              )
                            ],
                          ),
                  ),
                ),
              ),
              
              const SizedBox(height: 30),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_rounded),
                      label: const Text('Galerie'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt_rounded),
                      label: const Text('Caméra'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Predict Button
              if (_image != null && _result == null && !_isLoading)
                ElevatedButton(
                  onPressed: _uploadImage,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    backgroundColor: const Color(0xFF1B5E20),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'ANALYSER LE DÉCHET',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),

              // Loading State
              if (_isLoading)
                const Center(
                  child:  Column(
                    children: [
                      CircularProgressIndicator(color: Color(0xFF2E7D32)),
                      SizedBox(height: 10),
                      Text("Analyse en cours...", style: TextStyle(color: Colors.grey)),
                    ],
                  )
                ),

              // Result Card
              if (_result != null)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutBack,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _getResultColor().withOpacity(0.3), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: _getResultColor().withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Résultat".toUpperCase(),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _result!,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: _getResultColor(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Confidence Bar
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Confiance IA"),
                              Text(
                                "${(_confidence! * 100).toStringAsFixed(1)}%",
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: _confidence,
                              minHeight: 12,
                              backgroundColor: Colors.grey[100],
                              color: _getResultColor(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
