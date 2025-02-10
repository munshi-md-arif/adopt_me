// import 'package:adopt_me/screens/splash_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:adopt_me/bloc/pet_bloc.dart';
// import 'package:adopt_me/screens/home_screen.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => PetBloc(
//          rootBundle: rootBundle,
//     sharedPreferences: await SharedPreferences.getInstance(),
//       )..add(const LoadPets()),
//       child: MaterialApp(
//         title: 'Pet Adoption App',
//         theme: ThemeData.dark(),
//         home: const SplashScreen(),
//       ),
//     );
//   }
// }
import 'package:adopt_me/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:adopt_me/bloc/pet_bloc.dart';
import 'package:adopt_me/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize SharedPreferences
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        // Check if SharedPreferences is initialized
        if (snapshot.connectionState == ConnectionState.done) {
          final sharedPreferences = snapshot.data as SharedPreferences;

          return BlocProvider(
            create: (context) => PetBloc(
              rootBundle: rootBundle,
              sharedPreferences: sharedPreferences,
            )..add(const LoadPets()),
            child: MaterialApp(
              title: 'Pet Adoption App',
              theme: ThemeData.dark(),
              home: const SplashScreen(),
            ),
          );
        } else {
          return const MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
      },
    );
  }
}
