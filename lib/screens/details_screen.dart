import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_view/photo_view.dart'; // For interactive image viewer
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bloc/pet_bloc.dart';
import '../models/pet_model.dart';
import '../widgets/confetti.dart';

class DetailsScreen extends StatefulWidget {
  final Pet pet;

  const DetailsScreen({super.key, required this.pet});

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  late bool isAdopted = widget.pet.isAdopted;

  @override
  void initState() {
    super.initState();
    _loadAdoptionStatus();
  }

  Future<void> _loadAdoptionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isAdopted =
          prefs.getBool('adopted_${widget.pet.id}') ?? widget.pet.isAdopted;
    });
  }

  void _adoptPet() async {
    if (isAdopted) return;

    setState(() {
      isAdopted = true;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('adopted_${widget.pet.id}', true);

    context.read<PetBloc>().add(AdoptPet(widget.pet.id));

    showDialog(
      context: context,
      builder: (context) => ConfettiPopup(petName: widget.pet.name),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pet.name),
        backgroundColor: Colors.green[800],
      ),
      body: BlocListener<PetBloc, PetState>(
        listener: (context, state) {
          if (state is PetLoaded) {
            final updatedPet = state.pets.firstWhere(
              (pet) => pet.id == widget.pet.id,
              orElse: () => widget.pet,
            );
            setState(() {
              isAdopted = updatedPet.isAdopted;
            });
          }
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InteractiveImageViewer(
                            imageUrl: widget.pet.imageUrl,
                          ),
                        ),
                      );
                    },
                    child: Hero(
                      tag: widget.pet.id,
                      child: Image.network(
                        widget.pet.imageUrl,
                        width: double.infinity,
                        height: 300,
                        fit: BoxFit.cover,
                        color: isAdopted ? Colors.grey : null,
                        colorBlendMode:
                            isAdopted ? BlendMode.saturation : BlendMode.srcIn,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isAdopted ? Colors.red : Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isAdopted ? 'Adopted' : 'Available',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.pet.name,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Age: ${widget.pet.age} years',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Price: \$${widget.pet.price}',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'About ${widget.pet.name}:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.green[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.pet.description ?? 'No description available.',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          widget.pet.vaccinated
                              ? FontAwesomeIcons.syringe
                              : FontAwesomeIcons.timesCircle,
                          color:
                              widget.pet.vaccinated ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          widget.pet.vaccinated
                              ? 'Vaccinated'
                              : 'Not Vaccinated',
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        onPressed: isAdopted ? null : _adoptPet,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[800],
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          isAdopted ? 'Already Adopted' : 'Adopt Me',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
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

class InteractiveImageViewer extends StatelessWidget {
  final String imageUrl;

  const InteractiveImageViewer({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Image'),
        backgroundColor: Colors.green[800],
      ),
      body: PhotoView(
        imageProvider: NetworkImage(imageUrl),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 2,
      ),
    );
  }
}
