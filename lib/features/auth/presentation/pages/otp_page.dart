import 'package:flutter/material.dart';
import 'package:tapovana_mobile_app/features/profile/presentation/pages/data_entry_page.dart';

class OtpPage extends StatelessWidget {
  const OtpPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),

          child: Column(
            children: [

              const SizedBox(height: 130),

              /// LOGO
              Image.asset(
                'assets/login_images/topovan_png.png',
                width: 200,
              ),

              const SizedBox(height: 8),

              /// TITLE
              const Text(
                "Confirm Your Code",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 10),

              /// DESCRIPTION
              const Text(
                "Enter the code we sent to the exa***@gmail.com",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 40),

              /// OTP FIELDS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  4,
                  (index) => SizedBox(
                    width: 40,
                    child: TextField(
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,

                      decoration: const InputDecoration(
                        counterText: "",
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color.fromARGB(255, 56, 56, 56)),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height:70),

              /// VERIFY BUTTON
              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton(
                  onPressed: () {
                     Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DataEntryPage(),
                      ),
                    ); 
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC9A14A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),

                  child: const Text(
                    "Verify",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}