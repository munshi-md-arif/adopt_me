part of 'pet_bloc.dart';

abstract class PetState extends Equatable {
  const PetState();

  @override
  List<Object> get props => [];
}

class PetLoading extends PetState {}

class PetLoaded extends PetState {
  final List<Pet> pets;
  final int totalPets;
  final bool isEmpty;

  const PetLoaded(this.pets, this.totalPets, {this.isEmpty = false});

  @override
  List<Object> get props => [pets, totalPets];
}

class PetError extends PetState {}
