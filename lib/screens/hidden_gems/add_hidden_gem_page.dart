import 'package:flutter/material.dart';
import 'upload_hidden_gem_page.dart';

class AddHiddenGemPage extends StatefulWidget {
  const AddHiddenGemPage({super.key});

  @override
  State<AddHiddenGemPage> createState() => _AddHiddenGemPageState();
}

class _AddHiddenGemPageState extends State<AddHiddenGemPage> {
  final TextEditingController placeNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String? selectedDestination;
  String selectedCategory = "Nature";
  int selectedRating = 0;

  static const Color backgroundColor = Color(0xFFFCF8EF);
  static const Color darkColor = Color(0xFF384345);
  static const Color primaryColor = Color(0xFF3F646C);
  static const Color softYellow = Color(0xFFF7EAB6);
  static const Color textGrey = Color(0xFF7A7A7A);

  final List<String> malaysiaStates = [
    "Perlis",
    "Kedah",
    "Kuala Lumpur",
    "Putrajaya",
    "Labuan",
    "Pulau Pinang",
    "Perak",
    "Kelantan",
    "Terengganu",
    "Pahang",
    "Selangor",
    "Negeri Sembilan",
    "Melaka",
    "Johor",
    "Sabah",
    "Sarawak",
  ];

  final List<String> categories = [
    "Nature",
    "Food & Beverages",
    "Culture",
    "Scenic Views",
  ];

  @override
  void dispose() {
    placeNameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void goToUploadPage() {
    if (placeNameController.text.isEmpty ||
        selectedDestination == null ||
        descriptionController.text.isEmpty ||
        selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please complete all fields and add your rating"),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UploadHiddenGemPage(
          placeName: placeNameController.text,
          destination: selectedDestination!,
          category: selectedCategory,
          description: descriptionController.text,
          rating: selectedRating.toDouble(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromARGB(255, 159, 153, 131),
                    Color(0xFFF7EAB6),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: darkColor),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),

                      const SizedBox(width: 14),

                      const Expanded(
                        child: Text(
                          "Add Hidden Gem",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: darkColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Step 1 of 2",
                    style: TextStyle(
                      color: darkColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    "Share a unique place with the community and help travellers discover hidden attractions around Malaysia.",
                    style: TextStyle(
                      color: darkColor,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Place Information",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: darkColor,
                            ),
                          ),

                          const SizedBox(height: 6),

                          const Text(
                            "Fill in the basic information about this hidden gem.",
                            style: TextStyle(color: textGrey, fontSize: 13),
                          ),

                          const SizedBox(height: 22),

                          _buildLabel("Place Name"),
                          _buildTextField(
                            controller: placeNameController,
                            hintText: "Enter the place name",
                            icon: Icons.place_outlined,
                          ),

                          const SizedBox(height: 18),

                          _buildLabel("Location"),
                          _buildDropdown(
                            value: selectedDestination,
                            hintText: "Select location",
                            items: malaysiaStates,
                            icon: Icons.location_on_outlined,
                            onChanged: (value) {
                              setState(() {
                                selectedDestination = value;
                              });
                            },
                          ),

                          const SizedBox(height: 18),

                          _buildLabel("Category"),
                          _buildDropdown(
                            value: selectedCategory,
                            hintText: "Select category",
                            items: categories,
                            icon: Icons.category_outlined,
                            onChanged: (value) {
                              setState(() {
                                selectedCategory = value!;
                              });
                            },
                          ),

                          const SizedBox(height: 18),

                          _buildLabel("Description"),
                          TextField(
                            controller: descriptionController,
                            maxLines: 5,
                            decoration: InputDecoration(
                              hintText:
                                  "Tell travellers what makes this place special...",
                              hintStyle: const TextStyle(
                                color: textGrey,
                                fontSize: 13,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF1F0EA),
                              contentPadding: const EdgeInsets.all(16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    _buildLabel("Your Rating"),
                    _buildStarRating(),

                    const SizedBox(height: 22),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: softYellow,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.lightbulb_outline, color: darkColor),

                          SizedBox(width: 10),

                          Expanded(
                            child: Text(
                              "Tip: Add clear and honest details so other travellers can easily understand the attraction.",
                              style: TextStyle(
                                color: darkColor,
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 25),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: goToUploadPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    "Continue to Upload",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: darkColor,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: primaryColor),
        hintText: hintText,
        hintStyle: const TextStyle(color: textGrey, fontSize: 13),
        filled: true,
        fillColor: const Color(0xFFF1F0EA),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hintText,
    required List<String> items,
    required IconData icon,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      hint: Text(
        hintText,
        style: const TextStyle(color: textGrey, fontSize: 13),
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: primaryColor),
        filled: true,
        fillColor: const Color(0xFFF1F0EA),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item, overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildStarRating() {
    return Row(
      children: List.generate(5, (index) {
        final int starNumber = index + 1;
        final bool isSelected = starNumber <= selectedRating;

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedRating = starNumber;
            });
          },
          child: Icon(
            isSelected ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 34,
          ),
        );
      }),
    );
  }
}
