import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../shared/theme/duolingo_theme.dart';
import '../../../shared/widgets/kingdom_button.dart';
import '../../../shared/widgets/kingdom_card.dart';
import '../providers/kyc_provider.dart';
import '../models/kyc_models.dart';

class KycScreen extends ConsumerStatefulWidget {
  const KycScreen({super.key});

  @override
  ConsumerState<KycScreen> createState() => _KycScreenState();
}


class _KycScreenState extends ConsumerState<KycScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _personalInfoForm = GlobalKey<FormState>();
  final _addressForm = GlobalKey<FormState>();
  final _documentsForm = GlobalKey<FormState>();
  
  // Form controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dobController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  final _countryController = TextEditingController();
  
  File? _frontIdImage;
  File? _backIdImage;
  File? _selfieImage;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kycState = ref.watch(kycProvider);
    
    return Scaffold(
      backgroundColor: DuolingoTheme.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Kingdom Verification',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: DuolingoTheme.duoGreen,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: DuolingoTheme.duoGreen),
        bottom: TabBar(
          controller: _tabController,
          labelColor: DuolingoTheme.duoGreen,
          unselectedLabelColor: DuolingoTheme.textSecondary,
          indicatorColor: DuolingoTheme.duoGreen,
          tabs: const [
            Tab(text: 'Welcome'),
            Tab(text: 'Personal'),
            Tab(text: 'Address'),
            Tab(text: 'Documents'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildWelcomeTab(),
          _buildPersonalInfoTab(kycState),
          _buildAddressTab(kycState),
          _buildDocumentsTab(kycState),
        ],
      ),
    );
  }

  Widget _buildWelcomeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Kingdom castle icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: DuolingoTheme.duoGreen.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance,
              size: 60,
              color: DuolingoTheme.duoGreen,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Unlock Real Trading in Your Kingdom',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: DuolingoTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'To protect your kingdom and comply with financial regulations, we need to verify your identity.',
            style: TextStyle(
              fontSize: 16,
              color: DuolingoTheme.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          KingdomCard(
            child: Column(
              children: [
                _buildKycStep(
                  icon: Icons.person,
                  title: 'Personal Information',
                  description: 'Basic details about your identity',
                  isCompleted: false,
                ),
                const Divider(),
                _buildKycStep(
                  icon: Icons.home,
                  title: 'Address Verification',
                  description: 'Confirm your kingdom location',
                  isCompleted: false,
                ),
                const Divider(),
                _buildKycStep(
                  icon: Icons.camera_alt,
                  title: 'Document Upload',
                  description: 'Upload ID and verification photos',
                  isCompleted: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          KingdomButton(
            text: 'Begin Verification',
            onPressed: () {
              _tabController.animateTo(1);
            },
          ),
          const SizedBox(height: 16),
          const Text(
            '🔒 Your data is encrypted and secure',
            style: TextStyle(
              fontSize: 14,
              color: DuolingoTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoTab(KycState kycState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _personalInfoForm,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: DuolingoTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter your legal name exactly as it appears on your ID',
              style: TextStyle(
                fontSize: 14,
                color: DuolingoTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _firstNameController,
                    label: 'First Name',
                    icon: Icons.person,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'First name is required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _lastNameController,
                    label: 'Last Name',
                    icon: Icons.person,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Last name is required';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _dobController,
              label: 'Date of Birth',
              icon: Icons.cake,
              readOnly: true,
              onTap: () => _selectDate(context),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Date of birth is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _phoneController,
              label: 'Phone Number',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Phone number is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            if (kycState.isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _tabController.animateTo(0),
                      child: const Text('Back'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: KingdomButton(
                      text: 'Next',
                      onPressed: () {
                        if (_personalInfoForm.currentState!.validate()) {
                          _tabController.animateTo(2);
                        }
                      },
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressTab(KycState kycState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _addressForm,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Address Information',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: DuolingoTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Provide your current residential address',
              style: TextStyle(
                fontSize: 14,
                color: DuolingoTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            _buildTextField(
              controller: _addressController,
              label: 'Street Address',
              icon: Icons.home,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Street address is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _cityController,
                    label: 'City',
                    icon: Icons.location_city,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'City is required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _stateController,
                    label: 'State/Province',
                    icon: Icons.map,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'State is required';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _zipController,
                    label: 'ZIP/Postal Code',
                    icon: Icons.markunread_mailbox,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'ZIP code is required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _countryController,
                    label: 'Country',
                    icon: Icons.public,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Country is required';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            if (kycState.isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _tabController.animateTo(1),
                      child: const Text('Back'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: KingdomButton(
                      text: 'Next',
                      onPressed: () {
                        if (_addressForm.currentState!.validate()) {
                          _tabController.animateTo(3);
                        }
                      },
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsTab(KycState kycState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Document Verification',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: DuolingoTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Upload clear photos of your identification documents',
            style: TextStyle(
              fontSize: 14,
              color: DuolingoTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          _buildDocumentUpload(
            title: 'ID Front',
            description: 'Front of your government-issued ID',
            image: _frontIdImage,
            onTap: () => _pickImage(ImageType.frontId),
          ),
          const SizedBox(height: 16),
          _buildDocumentUpload(
            title: 'ID Back',
            description: 'Back of your government-issued ID',
            image: _backIdImage,
            onTap: () => _pickImage(ImageType.backId),
          ),
          const SizedBox(height: 16),
          _buildDocumentUpload(
            title: 'Selfie',
            description: 'A clear selfie holding your ID',
            image: _selfieImage,
            onTap: () => _pickImage(ImageType.selfie),
          ),
          const SizedBox(height: 32),
          if (kycState.isLoading)
            const Center(child: CircularProgressIndicator())
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _tabController.animateTo(2),
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: KingdomButton(
                    text: 'Submit Verification',
                    onPressed: _canSubmit() ? _submitKyc : null,
                  ),
                ),
              ],
            ),
          if (kycState.error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      kycState.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildKycStep({
    required IconData icon,
    required String title,
    required String description,
    required bool isCompleted,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted ? DuolingoTheme.duoGreen : DuolingoTheme.backgroundLight,
              shape: BoxShape.circle,
              border: Border.all(
                color: isCompleted ? DuolingoTheme.duoGreen : DuolingoTheme.borderLight,
              ),
            ),
            child: Icon(
              isCompleted ? Icons.check : icon,
              color: isCompleted ? Colors.white : DuolingoTheme.textSecondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: DuolingoTheme.textPrimary,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: DuolingoTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: DuolingoTheme.duoGreen),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: DuolingoTheme.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: DuolingoTheme.duoGreen, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildDocumentUpload({
    required String title,
    required String description,
    required File? image,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          border: Border.all(
            color: image != null ? DuolingoTheme.duoGreen : DuolingoTheme.borderLight,
            width: 2,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: image != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  image,
                  fit: BoxFit.cover,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt,
                    size: 32,
                    color: DuolingoTheme.textSecondary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: DuolingoTheme.textPrimary,
                    ),
                  ),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: DuolingoTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: DuolingoTheme.duoGreen,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      _dobController.text = '${picked.month}/${picked.day}/${picked.year}';
    }
  }

  Future<void> _pickImage(ImageType type) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        switch (type) {
          case ImageType.frontId:
            _frontIdImage = File(image.path);
            break;
          case ImageType.backId:
            _backIdImage = File(image.path);
            break;
          case ImageType.selfie:
            _selfieImage = File(image.path);
            break;
        }
      });
    }
  }

  bool _canSubmit() {
    return _frontIdImage != null && 
           _backIdImage != null && 
           _selfieImage != null &&
           _personalInfoForm.currentState?.validate() == true &&
           _addressForm.currentState?.validate() == true;
  }

  Future<void> _submitKyc() async {
    if (!_canSubmit()) return;

    final kycData = KycSubmissionData(
      personalInfo: PersonalInfo(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        dateOfBirth: _dobController.text,
        phoneNumber: _phoneController.text,
      ),
      addressInfo: AddressInfo(
        streetAddress: _addressController.text,
        city: _cityController.text,
        state: _stateController.text,
        zipCode: _zipController.text,
        country: _countryController.text,
      ),
      documents: DocumentInfo(
        frontIdImage: _frontIdImage!,
        backIdImage: _backIdImage!,
        selfieImage: _selfieImage!,
      ),
    );

    try {
      await ref.read(kycProvider.notifier).submitKyc(kycData);
      
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Verification Submitted! 🎉'),
            content: const Text(
              'Your verification has been submitted successfully. We\'ll review your documents and notify you within 1-2 business days.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('Continue'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Error handling is done in the provider
    }
  }
}

enum ImageType { frontId, backId, selfie }