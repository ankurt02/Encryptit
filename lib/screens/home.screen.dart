import 'package:dio/dio.dart' show BaseOptions, Dio;
import 'package:encrypt_it/services/hash.services.dart';
import 'package:encrypt_it/widgets/technique.card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> techniqueList = [
    'SHA-1',
    'SHA-256',
    'MD5',
    'AES',
    'RSA',
    'DES',
  ];

  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _keyController = TextEditingController();

  String _result = "";
  String _selectedTechnique = 'SHA-1'; // Default
  bool _isEncryptMode = true; // true for encrypt, false for decrypt
  
  Future<void> generateHashedText() async {
    final inputText = _inputController.text;

    if (inputText.isEmpty) return;

    // Define hash algorithms vs encryption algorithms
    final hashAlgorithms = ['SHA-1', 'SHA-256', 'MD5'];
    final encryptionAlgorithms = ['AES', 'DES', 'RSA'];

    String result = "";

    try {
      if (hashAlgorithms.contains(_selectedTechnique)) {
        // Hashing algorithms don't support decryption
        if (!_isEncryptMode) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.warning, color: Colors.white),
                  SizedBox(width: 8),
                  Text("Hash algorithms cannot be reversed!"),
                ],
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }
        
        // Call hash service for hashing algorithms
        result = await HashService().hashText(inputText, _selectedTechnique);
      } else if (encryptionAlgorithms.contains(_selectedTechnique)) {
        // Call encryption/decryption service for encryption algorithms
        final key = _keyController.text;
        
        if (key.isEmpty && _selectedTechnique != 'RSA') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.warning, color: Colors.white),
                  SizedBox(width: 8),
                  Text("Please enter an encryption key!"),
                ],
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }

        if (_isEncryptMode) {
          result = await HashService().encryptText(inputText, key, _selectedTechnique);
        } else {
          // Decrypt mode
          result = await HashService().decryptText(inputText, key, _selectedTechnique);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.white),
                SizedBox(width: 8),
                Text("$_selectedTechnique support coming soon!"),
              ],
            ),
            backgroundColor: Colors.deepOrange,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      setState(() {
        _result = result;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Text("Error: ${e.toString()}"),
            ],
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xEE000000),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Gap(24),

            /// Technique selection row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: screenWidth, // forces horizontal center inside screen width
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: techniqueList.map((technique) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTechnique = technique;
                          _result = '';
                        });
                      },
                      child: CryptoTechniqueCard(
                        title: technique,
                        isSelected: _selectedTechnique == technique,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            Gap(24),

            /// Selected technique title and encrypt/decrypt toggle
            Column(
              children: [
                Container(
                  height: screenHeight * 0.05,
                  width: screenWidth / 3,
                  alignment: Alignment.center,
                  child: Text(
                    _selectedTechnique,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
                
                // Show encrypt/decrypt toggle only for encryption algorithms
                if (_selectedTechnique == 'AES' || _selectedTechnique == 'DES' || _selectedTechnique == 'RSA')
                  Gap(8),
                
                if (_selectedTechnique == 'AES' || _selectedTechnique == 'DES' || _selectedTechnique == 'RSA')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isEncryptMode = true;
                            _result = '';
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: _isEncryptMode ? Colors.green : Colors.transparent,
                            border: Border.all(color: Colors.green, width: 2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Encrypt',
                            style: TextStyle(
                              color: _isEncryptMode ? Colors.white : Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Gap(16),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isEncryptMode = false;
                            _result = '';
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: !_isEncryptMode ? Colors.red : Colors.transparent,
                            border: Border.all(color: Colors.red, width: 2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Decrypt',
                            style: TextStyle(
                              color: !_isEncryptMode ? Colors.white : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),

            // Show key input field for encryption algorithms (except RSA which generates its own keys)
            if (_selectedTechnique == 'AES' || _selectedTechnique == 'DES')
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _keyController,
                  decoration: InputDecoration(
                    hintText: 'Enter encryption key',
                    hintStyle: TextStyle(color: Colors.white54),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
              ),

            Gap(16),

            /// Input and Output
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// Input text
                Container(
                  padding: const EdgeInsets.only(top: 0, left: 12),
                  height: screenHeight * 0.45,
                  width: screenWidth * 0.45,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.indigo, width: 2),
                    borderRadius: BorderRadius.circular(12)
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 4),
                        child: Text(
                          _isEncryptMode ? 'Input Text' : 'Encrypted Text (Base64)',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _inputController,
                          maxLines: null,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter text...',
                            hintStyle: TextStyle(color: Colors.white54),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Gap(20),

                /// Output text
                Container(
                  padding: const EdgeInsets.all(8),
                  height: screenHeight * 0.45,
                  width: screenWidth * 0.45,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.indigo, width: 2),
                    borderRadius: BorderRadius.circular(12)
                  ),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isEncryptMode ? 'Output' : 'Decrypted Text',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Expanded(
                            child: SingleChildScrollView(
                              child: SelectableText(
                                _result,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_result.isNotEmpty)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () {
                              // Copy to clipboard
                              Clipboard.setData(ClipboardData(text: _result));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      Icon(Icons.check_circle, color: Colors.white),
                                      SizedBox(width: 8),
                                      Text("Copied to clipboard!"),
                                    ],
                                  ),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Icon(
                                Icons.copy,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            Gap(30),

            /// Generate Button
            GestureDetector(
              onTap: _inputController.text.isEmpty ? null : generateHashedText,
              child: Container(
                height: 40,
                width: screenWidth / 6,
                decoration: BoxDecoration(
                  color: _isEncryptMode ? Colors.green : Colors.red,
                  border: Border.all(color: _isEncryptMode ? Colors.green : Colors.red, width: 2),
                  borderRadius: BorderRadius.circular(12)
                ),
                child: Center(
                  child: Text(
                    _isEncryptMode ? "Encrypt" : "Decrypt",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),

      /// Footer
      bottomNavigationBar: Container(
        color: Colors.white70,
        width: screenWidth,
        height: 26,
        child: const Center(
          child: Text(
            "Made with Flutter 💙",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}