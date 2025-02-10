import 'package:adopt_me/screens/history_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/pet_bloc.dart';
import '../widgets/pet_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  int _totalPets = 0;

  String? _selectedBreed;
  String? _selectedGender;
  bool? _isVaccinated = true;
  double _minPrice = 0;
  double _maxPrice = 1000;

  bool _isAdopted = false;
  double _minAge = 0;
  double _maxAge = 100;

  @override
  void initState() {
    super.initState();
    _fetchPets();
  }

  void _fetchPets() {
    context.read<PetBloc>().add(LoadPets(
          page: _currentPage,
          searchQuery: _searchController.text,
          gender: _selectedGender ?? '',
          vaccinated: _isVaccinated,
          adopted: _isAdopted,
          minAge: _minAge,
          maxAge: _maxAge,
          minPrice: _minPrice,
          maxPrice: _maxPrice,
        ));
  }

  void _changePage(int newPage) {
    setState(() => _currentPage = newPage);
    _fetchPets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Adoption'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSearchAndFilters(),
            BlocBuilder<PetBloc, PetState>(
              builder: (context, state) {
                if (state is PetLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is PetLoaded) {
                  _totalPets = state.totalPets;
                  if (state.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          'No pets found',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  } else {
                    return Column(
                      children: [
                        GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.7,
                          ),
                          itemCount: state.pets.length,
                          shrinkWrap:
                              true, // Allows it to be inside SingleChildScrollView
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return PetCard(pet: state.pets[index]);
                          },
                        ),
                        _buildPaginationButtons(),
                      ],
                    );
                  }
                } else {
                  return const Center(
                      child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text('Error loading pets'),
                  ));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (_) => _fetchPets(),
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              hintText: 'Search pets by name...',
              hintStyle: const TextStyle(color: Colors.black),
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              filled: true,
              fillColor: Colors.grey[200],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey),
                ),
                child: DropdownButton<String>(
                  value: _selectedGender,
                  hint: const Text('Gender'),
                  onChanged: (value) {
                    setState(() => _selectedGender = value);
                    _fetchPets();
                  },
                  items: ['Male', 'Female']
                      .map((gender) => DropdownMenuItem(
                            value: gender,
                            child: Text(gender),
                          ))
                      .toList(),
                  underline: Container(),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Vaccinated:'),
                  Switch(
                    activeColor: Colors.green,
                    value: _isVaccinated ?? true,
                    onChanged: (value) {
                      setState(() => _isVaccinated = value);
                      _fetchPets();
                    },
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Adopted:'),
                  Switch(
                    activeColor: Colors.green,
                    value: _isAdopted ?? false,
                    onChanged: (value) {
                      setState(() => _isAdopted = value);
                      _fetchPets();
                    },
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Price Range: \$${_minPrice.toInt()} - \$${_maxPrice.toInt()}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                RangeSlider(
                  min: 0,
                  max: 1000,
                  divisions: 10,
                  activeColor: Colors.green,
                  values: RangeValues(_minPrice, _maxPrice),
                  onChanged: (RangeValues values) {
                    setState(() {
                      _minPrice = values.start;
                      _maxPrice = values.end;
                    });
                    _fetchPets();
                  },
                  labels: RangeLabels(
                    '\$${_minPrice.toInt()}',
                    '\$${_maxPrice.toInt()}',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationButtons() {
    int totalPages = (_totalPets / 6).ceil();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Wrap(
        spacing: 8,
        children: List.generate(totalPages, (index) {
          int pageNumber = index + 1;
          return ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              backgroundColor:
                  _currentPage == pageNumber ? Colors.green : Colors.grey[300],
              foregroundColor:
                  _currentPage == pageNumber ? Colors.white : Colors.black,
            ),
            onPressed: () => _changePage(pageNumber),
            child: Text('$pageNumber'),
          );
        }),
      ),
    );
  }
}
