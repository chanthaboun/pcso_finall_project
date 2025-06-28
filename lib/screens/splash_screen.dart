// import 'package:flutter/material.dart';
// import '../services/storage_service.dart';
// import 'auth/login_screen.dart';
// import 'home_screen.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _checkLoginStatus();
//   }

//   Future<void> _checkLoginStatus() async {
//     await Future.delayed(const Duration(seconds: 2));

//     if (mounted) {
//       final isLoggedIn = await StorageService.isLoggedIn();

//       if (isLoggedIn) {
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(builder: (context) => const HomeScreen()),
//         );
//       } else {
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(builder: (context) => const LoginScreen()),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Logo
//             Container(
//               width: 120,
//               height: 120,
//               decoration: BoxDecoration(
//                 color: const Color(0xFFE91E63),
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: const Icon(
//                 Icons.favorite,
//                 color: Colors.white,
//                 size: 60,
//               ),
//             ),
//             const SizedBox(height: 24),

//             // App Name
//             RichText(
//               text: const TextSpan(
//                 children: [
//                   TextSpan(
//                     text: 'PCOS ',
//                     style: TextStyle(
//                       fontSize: 32,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFFE91E63),
//                     ),
//                   ),
//                   TextSpan(
//                     text: 'care.',
//                     style: TextStyle(
//                       fontSize: 32,
//                       fontWeight: FontWeight.normal,
//                       color: Colors.black87,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 16),

//             // Tagline in Lao
//             const Text(
//               '"ສຸຂະພາບດີ ເລີ່ມຕົ້ນຈາກເຮົາ" 🌸',
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.grey,
//                 fontStyle: FontStyle.italic,
//               ),
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               'PCOS Care ພ້ອມເປັນເພື່ອນຮ່ວມທາງ',
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey,
//               ),
//             ),
//             const Text(
//               '💪 ມາເລີ່ມຕົ້ນເປັນແມ່ສາວໃນທຸກວັນກັນເຮອ!',
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey,
//               ),
//             ),
//             const SizedBox(height: 40),

//             // Loading indicator
//             const CircularProgressIndicator(
//               valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE91E63)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }





import 'package:flutter/material.dart';
import '../services/simple_storage_service.dart';
import 'auth/login_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeAndCheckLoginStatus();
  }

  Future<void> _initializeAndCheckLoginStatus() async {
    try {
      // Initialize storage service first
      await SimpleStorageService.initialize();

      // Wait for splash screen display
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        // Check if user is logged in
        final isLoggedIn = await SimpleStorageService.isLoggedIn();
        final currentUser = await SimpleStorageService.getCurrentUser();

        if (isLoggedIn && currentUser != null) {
          // User is logged in, go to home screen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          // User is not logged in, go to login screen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      }
    } catch (e) {
      print('Error during initialization: $e');
      // On error, go to login screen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFE91E63),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE91E63).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.favorite,
                color: Colors.white,
                size: 60,
              ),
            ),
            const SizedBox(height: 32),

            // App Name
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'PCOS ',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE91E63),
                    ),
                  ),
                  TextSpan(
                    text: 'care.',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.normal,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tagline in Lao
            const Text(
              '"ສຸຂະພາບດີ ເລີ່ມຕົ້ນຈາກເຮົາ" 🌸',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'PCOS Care ພ້ອມເປັນເພື່ອນຮ່ວມທາງ',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            const Text(
              '💪 ມາເລີ່ມຕົ້ນເປັນແມ່ສາວໃນທຸກວັນກັນ!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE91E63)),
              strokeWidth: 3,
            ),
            const SizedBox(height: 16),

            // Loading text
            const Text(
              'ກຳລັງໂຫຼດ...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
