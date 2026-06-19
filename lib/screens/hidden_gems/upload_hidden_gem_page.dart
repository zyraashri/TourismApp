import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadHiddenGemPage extends StatefulWidget {
  final String placeName;
  final String destination;
  final String category;
  final String description;
  final double rating;

  const UploadHiddenGemPage({
    super.key,
    required this.placeName,
    required this.destination,
    required this.category,
    required this.description,
    required this.rating,
  });

  @override
  State<UploadHiddenGemPage> createState() => _UploadHiddenGemPageState();
}

class _UploadHiddenGemPageState extends State<UploadHiddenGemPage> {
  final ImagePicker imagePicker = ImagePicker();

  final List<Uint8List> selectedImageBytes = [];
  final List<String> selectedImageNames = [];

  bool isSubmitting = false;

  static const Color backgroundColor = Color(0xFFFCF8EF);
  static const Color darkColor = Color(0xFF384345);
  static const Color primaryColor = Color(0xFF3F646C);
  static const Color softGrey = Color(0xFFD9D9D9);
  static const Color textGrey = Color(0xFF7A7A7A);

  Future<void> selectPhotoSlot() async {
    if (selectedImageBytes.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You can upload up to 3 photos only")),
      );
      return;
    }

    final XFile? pickedImage = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );

    if (pickedImage == null) {
      return;
    }

    final Uint8List imageBytes = await pickedImage.readAsBytes();

    setState(() {
      selectedImageBytes.add(imageBytes);
      selectedImageNames.add(pickedImage.name);
    });
  }

  void removePhoto(int index) {
    setState(() {
      selectedImageBytes.removeAt(index);
      selectedImageNames.removeAt(index);
    });
  }

  List<String> getDemoUploadedGallery() {
    return [
      "assets/images/uploadedgem.jpg",
      "assets/images/uploadedgem2.jpg",
      "assets/images/uploadedgem3.jpg",
    ];
  }

  Future<void> submitHiddenGem(BuildContext context) async {
    if (selectedImageBytes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please upload at least one photo")),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final List<String> displayGalleryImages = getDemoUploadedGallery();
      await FirebaseFirestore.instance.collection("hidden_gems").add({
        "placeName": widget.placeName,
        "destination": widget.destination,
        "category": widget.category,
        "description": widget.description,
        // Review/rating fields
        "rating": widget.rating,

        "imagePath": displayGalleryImages.first,
        "galleryImages": displayGalleryImages,

        "submissionType": "user",

        "reviewCount": 1,

        // Submission status
        "status": "pending",

        // Photo submission info
        "hasPhoto": true,
        "photoCount": selectedImageBytes.length,
        "photoNames": selectedImageNames,
        "photoStatus": "selected",

        // Date
        "createdAt": FieldValue.serverTimestamp(),
      });

      if (!context.mounted) return;

      setState(() {
        isSubmitting = false;
      });

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: primaryColor),
                SizedBox(width: 8),
                Text(
                  "Submitted!",
                  style: TextStyle(
                    color: darkColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Text(
              "${widget.placeName} has been submitted successfully with ${selectedImageBytes.length} photo(s).",
              style: const TextStyle(color: textGrey, height: 1.4),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text(
                  "Back to Hidden Gems",
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      );
    } catch (error) {
      if (!context.mounted) return;

      setState(() {
        isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to submit hidden gem: $error")),
      );
    }
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
                      icon: const Icon(Icons.arrow_back, color: darkColor),
                      onPressed: isSubmitting
                          ? null
                          : () {
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
                      style: TextStyle(color: textGrey, height: 1.4),
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
                            child: const Icon(Icons.place, color: primaryColor),
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
                                const SizedBox(height: 5),

                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 15,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.rating.toStringAsFixed(1),
                                      style: const TextStyle(
                                        color: textGrey,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
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
                      "Add up to 3 photos. Photos will be previewed here before submission.",
                      style: TextStyle(
                        color: textGrey,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 18),

                    GestureDetector(
                      onTap: isSubmitting ? null : selectPhotoSlot,
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
                              "Tap to choose image",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              "${selectedImageBytes.length}/3 photos selected",
                              style: const TextStyle(
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
                          Icon(Icons.info_outline, color: darkColor),

                          SizedBox(width: 10),

                          Expanded(
                            child: Text(
                              "Review your selected photos before submitting this hidden gem to the community.",
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
                  onPressed: isSubmitting
                      ? null
                      : () {
                          submitHiddenGem(context);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkColor,
                    disabledBackgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
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
    final bool hasImage = index < selectedImageBytes.length;

    return Expanded(
      child: GestureDetector(
        onTap: isSubmitting
            ? null
            : () {
                if (hasImage) {
                  removePhoto(index);
                } else {
                  selectPhotoSlot();
                }
              },
        child: Container(
          height: 82,
          decoration: BoxDecoration(
            color: hasImage ? Colors.white : softGrey,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasImage ? primaryColor : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: hasImage
              ? Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.memory(
                        selectedImageBytes[index],
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),

                    Positioned(
                      top: 5,
                      right: 5,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18,
                        ),
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
