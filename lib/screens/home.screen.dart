import 'package:dio/dio.dart' show BaseOptions, Dio;
import 'package:encrypt_it/services/hash.services.dart';
import 'package:encrypt_it/widgets/technique.card.dart';
import 'package:flutter/material.dart';
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
    'Diffie-Hellman',
  ];

  final TextEditingController _inputController = TextEditingController();
  String _result = "";
  String _selectedTechnique = 'SHA-1'; // Default

  Future<void> generateHashedText() async {
  final inputText = _inputController.text;

  if (inputText.isEmpty) return;

  // ✅ Supported techniques for now
  final supportedTechniques = ['SHA-1', 'SHA-256', 'MD5'];

  if (!supportedTechniques.contains(_selectedTechnique)) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "$_selectedTechnique support coming soon!",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.redAccent,
        duration: Duration(seconds: 2),
      ),
    );
    return;
  }

  final result =
      await HashService().hashText(inputText, _selectedTechnique);

  setState(() {
    _result = result;
  });
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

            /// Selected technique title
            Container(
              height: screenHeight * 0.05,
              width: screenWidth / 3,
              alignment: Alignment.center,
              // decoration: BoxDecoration(
              //   border: Border.all(color: Colors.grey, 
              //   width: ,),borderRadius: BorderRadius.circular(24),
              // ),
              child: Text(
                _selectedTechnique,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ),

            Gap(16),

            /// Description container (optional)
            // Container(
            //   height: screenHeight * 0.14,
            //   width: screenWidth * 0.95,
            //   decoration: BoxDecoration(
            //     border: Border.all(color: Colors.purple, width: 2),
            //   ),
            //   child: const Center(
            //     child: Text(
            //       'Description about the Selected technique',
            //       style: TextStyle(color: Colors.white70),
            //     ),
            //   ),
            // ),

            Gap(16),

            /// Input and Output
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// Input text
                Container(
                  padding: const EdgeInsets.only(top :0, left: 12),
                  height: screenHeight * 0.45,
                  width: screenWidth * 0.45,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.indigo, width: 2),
                    borderRadius: BorderRadius.circular(12)
                  ),
                  child:  TextField(
                    controller: _inputController,
                    maxLines: null,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter text',
                      hintStyle: TextStyle(color: Colors.white54),
                    ),
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
                  child: SingleChildScrollView(
                    child: Text(
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

            Gap(30),

            /// Generate Button
            GestureDetector(
              onTap: generateHashedText,
              child: Container(
                height: 40,
                width: screenWidth / 6,
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  border: Border.all(color: Colors.blueAccent, width: 2),
                  borderRadius: BorderRadius.circular(12)
                ),
                child: const Center(
                  child: Text(
                    "Generate",
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
            // 💛for later use
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
