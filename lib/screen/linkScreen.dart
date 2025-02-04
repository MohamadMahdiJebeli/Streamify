import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:streamify/gen/assets.gen.dart';
import 'package:streamify/screen/mainScreen.dart';

class Linkscreen extends StatefulWidget {
  const Linkscreen({super.key});

  @override
  State<Linkscreen> createState() => _LinkscreenState();
}

class _LinkscreenState extends State<Linkscreen> {
  final TextEditingController _linkController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blueGrey.shade900,
              Colors.blueGrey.shade800,
              Colors.blueGrey.shade400,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Section
                Column(
                  children: [
                    Image.asset(Assets.streamfiyNoBG.path,color: Colors.amber.shade300,),
                    const SizedBox(height: 10),
                    Text(
                      'Enter your streaming URL',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Input Section
                Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _linkController,
                    style: TextStyle(color: Colors.grey.shade200),
                    decoration: InputDecoration(
                      // suffixIcon: IconButton(
                      //   icon: Icon(Icons.paste_rounded),
                      //   color: const Color.fromRGBO(255, 213, 79, 1),
                      //   onPressed: () async {
                      //     await Clipboard.getData('text/plain');
                      //   },
                      // ),
                      hintText: 'https://eu.cdn.hailey-cdn.com/download/2/9/145418/341440/7583/147.182.205.163/1741013169/309a5f18e529169555604a5e6055bd6340ea484229/movies/i/Interstellar_2014_IMAX_10bit_HDR_2160p_x265_BrRip_6CH_PSA_30NAMA.mkv',
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      filled: true,
                      fillColor: Colors.blueGrey.shade800.withOpacity(0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 20,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a valid URL';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 30),

                // Action Button
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              Mainscreen(streamUrl: _linkController.text),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade300,
                    foregroundColor: Colors.blueGrey.shade900,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    shadowColor: Colors.black.withOpacity(0.3),
                  ),
                  child: const Text(
                    'Start Streaming',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}