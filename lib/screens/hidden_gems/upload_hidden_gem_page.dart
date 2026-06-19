import 'package:flutter/material.dart';

class UploadHiddenGemPage extends StatefulWidget {
  final String placeName;
  final String destination;
  final String category;
  final String description;

  const UploadHiddenGemPage({
    super.key,
    required this.placeName,
    required this.destination,
    required this.category,
    required this.description,
  });

  @override
  State<UploadHiddenGemPage> createState() => _UploadHiddenGemPageState();
}

class _UploadHiddenGemPageState extends State<UploadHiddenGemPage> {
  int selectedPhotos = 0;

  static const Color backgroundColor = Color(0xFFFCF8EF);
  static const Color darkColor = Color(0xFF384345);
  static const Color primaryColor = Color(0xFF3F646C);
  static const Color softGrey = Color(0xFFD9D9D9);
  static const Color textGrey = Color(0xFF7A7A7A);

  void selectPhotoSlot() {
    setState(() {
      if (selectedPhotos < 3) {
        selectedPhotos++;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Image picker will be connected later"),
      ),
    );
  }

  void submitHiddenGem(BuildContext context) {
    if (selectedPhotos == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please upload at least one photo"),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${widget.placeName} submitted successfully!"),
      ),
    );

    Navigator.popUntil(
      context,
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: darkColor,
                      ),
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
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Step 2 of 2",
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      "Upload photos to help other travellers discover this hidden gem.",
                      style: TextStyle(
                        color: textGrey,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 24),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.place,
                              color: primaryColor,
                            ),
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.placeName,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: darkColor,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  "${widget.destination} • ${widget.category}",
                                  style: const TextStyle(
                                    color: textGrey,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    const Text(
                      "Upload Photos",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: darkColor,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      "Add up to 3 photos. Choose clear photos that show the place well.",
                      style: TextStyle(
                        color: textGrey,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 18),

                    GestureDetector(
                      onTap: selectPhotoSlot,
                      child: Container(
                        width: double.infinity,
                        height: 190,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.25),
                              blurRadius: 14,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.cloud_upload_outlined,
                                color: Colors.white,
                                size: 38,
                              ),
                            ),

                            const SizedBox(height: 16),

                            const Text(
                              "Tap to upload image",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 6),

                            const Text(
                              "JPG or PNG supported",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    Row(
                      children: [
                        _buildPhotoSlot(0),
                        const SizedBox(width: 10),
                        _buildPhotoSlot(1),
                        const SizedBox(width: 10),
                        _buildPhotoSlot(2),
                      ],
                    ),

                    const SizedBox(height: 26),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7EAB6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: darkColor,
                          ),

                          SizedBox(width: 10),

                          Expanded(
                            child: Text(
                              "Photos will be uploaded to Firebase Storage in the next development phase.",
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
                  onPressed: () {
                    submitHiddenGem(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    "Submit Hidden Gem",
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

  Widget _buildPhotoSlot(int index) {
    final bool isSelected = index < selectedPhotos;

    return Expanded(
      child: GestureDetector(
        onTap: selectPhotoSlot,
        child: Container(
          height: 82,
          decoration: BoxDecoration(
            color: isSelected ? primaryColor.withValues(alpha: 0.15) : softGrey,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? primaryColor : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: isSelected
              ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: primaryColor,
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Added",
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
              : const Icon(
                  Icons.add_photo_alternate_outlined,
                  color: textGrey,
                  size: 28,
                ),
        ),
      ),
    );
  }
}