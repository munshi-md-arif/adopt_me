import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pet_model.dart';

part 'pet_event.dart';
part 'pet_state.dart';

class PetBloc extends Bloc<PetEvent, PetState> {
  List<Pet> allPets = [];
  final AssetBundle rootBundle;
  final SharedPreferences sharedPreferences;

  PetBloc({
    required this.rootBundle,
    required this.sharedPreferences,
  }) : super(PetLoading()) {
    on<LoadPets>(_onLoadPets);
    on<AdoptPet>(_onAdoptPet);
  }

  void _onLoadPets(LoadPets event, Emitter<PetState> emit) async {
    try {
      if (allPets.isEmpty) {
        final String response = await rootBundle.loadString('assets/pets.json');
        final List<dynamic> data = json.decode(response);
        allPets = data.map((json) => Pet.fromJson(json)).toList();

        final prefs = await SharedPreferences.getInstance();
        for (var pet in allPets) {
          pet.isAdopted = prefs.getBool('adopted_${pet.id}') ?? false;
        }
      }

      // 🛠 Apply Filters
      List<Pet> filteredPets = allPets.where((pet) {
        bool matchesSearch = event.searchQuery.isEmpty ||
            pet.name.toLowerCase().contains(event.searchQuery.toLowerCase());

        bool matchesGender = event.gender.isEmpty || pet.gender == event.gender;
        bool matchesVaccination =
            event.vaccinated == null || pet.vaccinated == event.vaccinated;
        bool matchesAdopted =
            event.adopted == null || pet.isAdopted == event.adopted;
        bool matchesPrice =
            pet.price >= event.minPrice && pet.price <= event.maxPrice;

        return matchesSearch &&
            matchesGender &&
            matchesVaccination &&
            matchesAdopted &&
            matchesPrice;
      }).toList();

      bool isEmpty = filteredPets.isEmpty;

      // Pagination
      int startIndex = (event.page - 1) * 6;
      int endIndex = startIndex + 6;
      if (startIndex >= filteredPets.length) {
        startIndex = 0;
        endIndex = filteredPets.length;
      }
      endIndex =
          endIndex > filteredPets.length ? filteredPets.length : endIndex;

      List<Pet> paginatedPets = filteredPets.sublist(startIndex, endIndex);

      emit(PetLoaded(paginatedPets, filteredPets.length, isEmpty: isEmpty));
    } catch (e) {
      print('Error in _onLoadPets: $e'); // Add logging
      emit(PetError());
    }
  }

  void _onAdoptPet(AdoptPet event, Emitter<PetState> emit) async {
    final state = this.state;
    if (state is PetLoaded) {
      final List<Pet> updatedPets = [];

      for (var pet in state.pets) {
        if (pet.id == event.petId) {
          final updatedPet = pet.copyWith(isAdopted: true);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('adopted_${pet.id}', true);
          updatedPets.add(updatedPet);
        } else {
          updatedPets.add(pet);
        }
      }

      emit(PetLoaded(updatedPets, state.totalPets));
    }
  }
}
