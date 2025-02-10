part of 'pet_bloc.dart';

abstract class PetEvent extends Equatable {
  const PetEvent();

  @override
  List<Object> get props => [];
}

class LoadPets extends PetEvent {
  final int page;
  final String searchQuery;
  final String breed;
  final String gender;
  final bool? vaccinated;
  final bool? adopted;
  final double minPrice;
  final double maxPrice;
  final double minAge;
  final double maxAge;

  const LoadPets({
    this.page = 1,
    this.searchQuery = '',
    this.breed = '',
    this.gender = '',
    this.vaccinated,
    this.adopted,
    this.minPrice = 0,
    this.maxPrice = double.infinity,
    this.minAge = 0,
    this.maxAge = 15,
  });

  @override
  List<Object> get props => [
        page,
        searchQuery,
        breed,
        gender,
        vaccinated ?? true,
        adopted ?? true,
        minPrice,
        maxPrice,
        minAge,
        maxAge,
      ];
}

class AdoptPet extends PetEvent {
  final String petId;

  const AdoptPet(this.petId);

  @override
  List<Object> get props => [petId];
}
