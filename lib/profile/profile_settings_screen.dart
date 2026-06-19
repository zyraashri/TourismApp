import 'dart:typed_data'; // Required for handling image bytes on Web
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  // Brand Color Palette Mapping Constants
  static const Color _primaryDark = Color(0xFF2E3D39);
  static const Color _bgNeutral = Color(0xFFF7F5F0);
  static const Color _sandAccent = Color(0xFFE5E2DA);
  static const Color _sageBorder = Color(0xFF9FA8A6);

  // Local state properties
  String _fullName = 'John Doe';
  String _phoneNumber = '+60 12-345 6789';
  String _emergencyContact = 'Jane Doe (+60 19-876 5432)';
  String _selectedCurrency = 'MYR';
  String _travelStyle = 'Backpacker';

  bool _notificationsEnabled = true;
  bool _locationTracking = true;

  // 🔴 NEW: This state memory variable holds the picked profile image bytes
  Uint8List? _profileImageBytes;

  // Edit Complex Profile Details Interface Modal
  void _showEditProfileDialog() {
    final TextEditingController nameController = TextEditingController(
      text: _fullName,
    );
    final TextEditingController phoneController = TextEditingController(
      text: _phoneNumber,
    );
    final TextEditingController emergencyController = TextEditingController(
      text: _emergencyContact,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: _bgNeutral,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Edit Profile & Safety',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: _primaryDark,
              letterSpacing: -0.5,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    labelStyle: const TextStyle(color: _primaryDark),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: _primaryDark,
                        width: 2,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: _primaryDark,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    labelStyle: const TextStyle(color: _primaryDark),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: _primaryDark,
                        width: 2,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(
                      Icons.phone_outlined,
                      color: _primaryDark,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emergencyController,
                  decoration: InputDecoration(
                    labelText: 'Emergency Contact Info',
                    labelStyle: const TextStyle(color: _primaryDark),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: _primaryDark,
                        width: 2,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(
                      Icons.gpp_good_outlined,
                      color: _primaryDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryDark,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                setState(() {
                  _fullName = nameController.text;
                  _phoneNumber = phoneController.text;
                  _emergencyContact = emergencyController.text;
                });
                Navigator.pop(context);
              },
              child: const Text(
                'Save Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // 3. Functional Action: Select Currency Bottom Sheet Selector
  void _showCurrencySelector() {
    final List<String> currencies = ['MYR', 'USD', 'EUR', 'GBP', 'SGD', 'AUD'];
    showModalBottomSheet(
      context: context,
      backgroundColor: _bgNeutral,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Default Currency',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _primaryDark,
              ),
            ),
            const SizedBox(height: 10),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: currencies
                    .map(
                      (currency) => ListTile(
                        title: Text(
                          currency,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        trailing: _selectedCurrency == currency
                            ? const Icon(Icons.check, color: _primaryDark)
                            : null,
                        onTap: () {
                          setState(() => _selectedCurrency = currency);
                          Navigator.pop(context);
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 4. Functional Action: Select Travel Style Bottom Sheet Selector
  void _showTravelStyleSelector() {
    final List<String> styles = [
      'Backpacker',
      'Luxury Exploration',
      'Family Trip',
      'Business Adventure',
      'Solo Minimalist',
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: _bgNeutral,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Travel Matrix Style',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _primaryDark,
              ),
            ),
            const SizedBox(height: 10),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: styles
                    .map(
                      (style) => ListTile(
                        title: Text(
                          style,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        trailing: _travelStyle == style
                            ? const Icon(Icons.check, color: _primaryDark)
                            : null,
                        onTap: () {
                          setState(() => _travelStyle = style);
                          Navigator.pop(context);
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog(String title, String placeholderContent) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _bgNeutral,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: _primaryDark,
          ),
        ),
        content: Text(
          placeholderContent,
          style: TextStyle(color: Colors.grey[800], height: 1.4),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _primaryDark),
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Understood',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ UPDATED: Image picker now converts selected data directly into visible UI bytes
  Future<void> _pickProfileImage() async {
    final ImagePicker picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      backgroundColor: _bgNeutral,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'Update Photo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _primaryDark,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: _primaryDark,
              ),
              title: const Text(
                'Device Gallery',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await picker.pickImage(
                  source: ImageSource.gallery,
                );
                if (image != null) {
                  final Uint8List bytes = await image
                      .readAsBytes(); // Read file bytes safely for web compiler target
                  setState(() {
                    _profileImageBytes = bytes; // Update state directly
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.camera_alt_outlined,
                color: _primaryDark,
              ),
              title: const Text(
                'Take Snap Capture',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await picker.pickImage(
                  source: ImageSource.camera,
                );
                if (image != null) {
                  final Uint8List bytes = await image.readAsBytes();
                  setState(() {
                    _profileImageBytes = bytes;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgNeutral,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            backgroundColor: _primaryDark,
            elevation: 0,
            flexibleSpace: const FlexibleSpaceBar(
              title: Text(
                'Profile',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontSize: 18,
                  letterSpacing: -0.5,
                ),
              ),
              centerTitle: true,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _buildProfileHeaderCard(),
                  const SizedBox(height: 24),

                  _buildSectionHeader('Adventure Profile Preferences'),
                  _buildMenuCard([
                    _buildListTile(
                      Icons.attach_money,
                      'Default Currency',
                      _selectedCurrency,
                      _showCurrencySelector,
                    ),
                    _buildListTile(
                      Icons.luggage_outlined,
                      'Travel Style Matrix',
                      _travelStyle,
                      _showTravelStyleSelector,
                    ),
                    _buildListTile(
                      Icons.bookmark_border,
                      'Saved Locations Hub',
                      'Manage',
                      () {
                        _showInfoDialog(
                          'Saved Locations',
                          'Your bookmarked travel attractions, routes, and favorite destinations will be safely listed here.',
                        );
                      },
                    ),
                  ]),

                  const SizedBox(height: 24),
                  _buildSectionHeader('Telemetry & Core Utility'),
                  _buildMenuCard([
                    ListTile(
                      leading: const Icon(
                        Icons.notifications_none,
                        color: _primaryDark,
                      ),
                      title: const Text(
                        'Push Notification Feed',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                      trailing: Switch.adaptive(
                        value: _notificationsEnabled,
                        activeColor: _sageBorder,
                        activeTrackColor: _primaryDark,
                        onChanged: (v) =>
                            setState(() => _notificationsEnabled = v),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.location_on_outlined,
                        color: _primaryDark,
                      ),
                      title: const Text(
                        'Offline Route Caching',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                      trailing: Switch.adaptive(
                        value: _locationTracking,
                        activeColor: _sageBorder,
                        activeTrackColor: _primaryDark,
                        onChanged: (v) => setState(() => _locationTracking = v),
                      ),
                    ),
                  ]),

                  const SizedBox(height: 24),
                  _buildSectionHeader('Support & Legal Integrity'),
                  _buildMenuCard([
                    _buildListTile(
                      Icons.help_outline,
                      'Help Desk Support',
                      '',
                      () {
                        _showInfoDialog(
                          'Help Desk Support',
                          'Need assistance planning a route or tracking your travel budgets? Reach our support system at support@smartplanner.com',
                        );
                      },
                    ),
                    _buildListTile(
                      Icons.gavel_outlined,
                      'Terms of Travel Service',
                      '',
                      () {
                        _showInfoDialog(
                          'Terms of Service',
                          'By using Smart Journey Planner, you agree to coordinate details, routes, and financial budgets responsibly within community standards.',
                        );
                      },
                    ),
                    _buildListTile(
                      Icons.privacy_tip_outlined,
                      'Privacy Policy Directives',
                      '',
                      () {
                        _showInfoDialog(
                          'Privacy Policy',
                          'Your personal identity data, currency budgets, and route files are encrypted locally and securely managed on the cloud infrastructure.',
                        );
                      },
                    ),
                  ]),

                  const SizedBox(height: 36),
                  _buildLogoutActionRow(),
                  const SizedBox(height: 12),
                  const Text(
                    'Smart Planner Engine • Version 1.0.4',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 10),
        child: Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: _primaryDark,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _sandAccent),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              // ✅ UPDATED: The avatar checks if image bytes are present, otherwise displays the default icon
              CircleAvatar(
                radius: 54,
                backgroundColor: _bgNeutral,
                backgroundImage: _profileImageBytes != null
                    ? MemoryImage(_profileImageBytes!)
                    : null,
                child: _profileImageBytes == null
                    ? const Icon(
                        Icons.face_retouching_natural_outlined,
                        size: 50,
                        color: _primaryDark,
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _pickProfileImage,
                  child: const CircleAvatar(
                    radius: 18,
                    backgroundColor: _primaryDark,
                    child: Icon(
                      Icons.camera_alt_outlined,
                      size: 15,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _fullName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: _primaryDark,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _phoneNumber,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _bgNeutral,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.shield_outlined,
                  size: 14,
                  color: Colors.redAccent,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'SOS: $_emergencyContact',
                    style: const TextStyle(
                      color: _primaryDark,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: _primaryDark),
            icon: const Icon(Icons.tune_outlined, size: 16),
            label: const Text(
              'Modify Identity profile',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            onPressed: _showEditProfileDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _sandAccent),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildListTile(
    IconData icon,
    String title,
    String trailingText,
    VoidCallback tapAction,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: Icon(icon, color: _primaryDark),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 15,
              color: _primaryDark,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (trailingText.isNotEmpty)
                Text(
                  trailingText,
                  style: const TextStyle(
                    color: _sageBorder,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_outlined, color: _sandAccent),
            ],
          ),
          onTap: tapAction,
        ),
      ],
    );
  }

  Widget _buildLogoutActionRow() {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        style: TextButton.styleFrom(
          foregroundColor: Colors.redAccent[700],
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Colors.redAccent.withOpacity(0.2),
              width: 1.5,
            ),
          ),
        ),
        icon: const Icon(Icons.power_settings_new_outlined),
        label: const Text(
          'Disconnect Travel Session',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Firebase Auth Disconnect Triggered')),
          );
        },
      ),
    );
  }
}
