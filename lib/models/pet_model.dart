class Pet {
  final String id;
  final String name;
  final String imageUrl;
  final String description;
  final String age;
  final String breed;
  final String gender;
  final bool vaccinated;
  bool isAdopted;
  final double price;
  

  Pet({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.age,
    required this.breed,
    required this.gender,
    required this.vaccinated,
    required this.isAdopted,
    required this.price,
  });

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      description: json['description'],
      age: json['age'],
      breed: json['breed'],
      gender: json['gender'],
      vaccinated: json['vaccinated'],
      isAdopted: json['isAdopted'],
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'description': description,
      'age': age,
      'breed': breed,
      'gender': gender,
      'vaccinated': vaccinated,
      'isAdopted': isAdopted,
      'price': price,
    };
  }

  Pet copyWith({bool? isAdopted, double? price}) {
    return Pet(
      id: id,
      name: name,
      imageUrl: imageUrl,
      description: description,
      age: age,
      breed: breed,
      gender: gender,
      vaccinated: vaccinated,
      isAdopted: isAdopted ?? this.isAdopted,
      price: price ?? this.price,
    );
  }
}
