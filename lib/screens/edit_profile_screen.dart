import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile userProfile;

  const EditProfileScreen({Key? key, required this.userProfile})
    : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _birthdayController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userProfile.name);
    _emailController = TextEditingController(text: widget.userProfile.email);
    _phoneController = TextEditingController(text: widget.userProfile.phone);

    String birthdayVal = widget.userProfile.birthday;
    if (birthdayVal == '-' || birthdayVal == 'null') {
      birthdayVal = '';
    }

    _birthdayController = TextEditingController(text: birthdayVal);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _birthdayController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    try {
      if (_birthdayController.text.isNotEmpty &&
          _birthdayController.text != '-') {
        initialDate = DateFormat('dd/MM/yyyy').parse(_birthdayController.text);
      }
    } catch (e) {
      // 
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900), 
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E392A),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1E392A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _birthdayController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery, 
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      String rawDate =
          _birthdayController.text; 
      String formattedDate = rawDate;

      if (rawDate.isNotEmpty) {
        try {
          DateTime date = DateFormat('dd/MM/yyyy').parse(rawDate);

          formattedDate = DateFormat('yyyy-MM-dd').format(date);
        } catch (e) {
          print("Format tanggal error, mengirim raw data: $e");
        }
      }

      final result = await _apiService.updateUserProfile(
        _nameController.text,
        _emailController.text,
        _phoneController.text,
        formattedDate,
        _selectedImage,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to update profile.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF1E392A); 

    DecorationImage? _getProfileImage() {
      if (_selectedImage != null) {
        return DecorationImage(
          image: FileImage(_selectedImage!),
          fit: BoxFit.cover,
        );
      }

      if (widget.userProfile.fullProfilePhotoUrl != null) {
      return DecorationImage(
        image: NetworkImage(widget.userProfile.fullProfilePhotoUrl!),
        fit: BoxFit.cover,
      );
    }

      return null;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F5),
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      shape: BoxShape.circle,
                      border: Border.all(color: primaryColor, width: 2),
                      image: _getProfileImage(),
                    ),
                    child:
                        _selectedImage == null &&
                            widget.userProfile.fullProfilePhotoUrl ==
                                null
                        ? const Icon(Icons.person, size: 60, color: Colors.grey)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFF1E392A),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              _buildTextField(
                "Full Name",
                _nameController,
                Icons.person_outline,
              ),
              const SizedBox(height: 16),
              _buildTextField("Email", _emailController, Icons.email_outlined),
              const SizedBox(height: 16),
              _buildTextField(
                "Phone Number",
                _phoneController,
                Icons.phone_outlined,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                "Birthday",
                _birthdayController,
                Icons.cake_outlined,
                isReadOnly: true, 
                onTap: () =>
                    _selectDate(context),
                hintText: "-", 
                suffixIcon: Icons.calendar_today,
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : _handleSave, 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Save Changes",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool isReadOnly = false, 
    VoidCallback? onTap, 
    IconData? suffixIcon, 
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E2E2E),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: isReadOnly, 
          onTap: onTap, 
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: Icon(icon, color: const Color(0xFF1E392A)),
            suffixIcon: suffixIcon != null
                ? Icon(suffixIcon, color: const Color(0xFF1E392A))
                : null,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
          ),
        ),
      ],
    );
  }
}
