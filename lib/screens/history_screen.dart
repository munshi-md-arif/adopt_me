import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pet_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/pet_bloc.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Pet> adoptedPets = [];

  @override
  void initState() {
    super.initState();
    _loadAdoptedPets();
  }

  Future<void> _loadAdoptedPets() async {
    final prefs = await SharedPreferences.getInstance();
    final petBloc = context.read<PetBloc>();

    // Ensure pets are loaded
    if (petBloc.allPets.isEmpty) {
      petBloc.add(const LoadPets()); // Trigger loading if not already done
    }

    setState(() {
      adoptedPets = petBloc.allPets
          .where((pet) => prefs.getBool('adopted_${pet.id}') ?? false)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adoption History'),
        backgroundColor: Colors.green[800],
      ),
      body: adoptedPets.isEmpty
          ? Center(
              child: Text(
                'No pets adopted yet.',
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              ),
            )
          : ListView.builder(
              itemCount: adoptedPets.length,
              itemBuilder: (context, index) {
                final pet = adoptedPets[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(pet.imageUrl),
                    ),
                    title: Text(
                      pet.name,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text('Adopted'),
                    trailing:
                        const Icon(Icons.check_circle, color: Colors.green),
                  ),
                );
              },
            ),
    );
  }
}
