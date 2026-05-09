
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../../models/app_models.dart';
import '../../../providers/data_provider.dart';
import '../../../services/firebase_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../components/custom_text_field.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final _formKey = GlobalKey<FormState>();
  final _firebaseService = FirebaseService();

  late String name, title, bio, greeting, email, phone, whatsapp, linkedin;
  late String coverImage, resume;

  // Upload state
  double? _imageUploadProgress;
  double? _resumeUploadProgress;
  bool _imageUploading = false;
  bool _resumeUploading = false;
  bool _imagePicking = false;
  bool _resumePicking = false;

  // Selected file info (before/during upload)
  XFile? _selectedImage;
  String? _selectedResumeFileName;
  int? _selectedResumeFileSize;

  @override
  void initState() {
    super.initState();
    final profile = context.read<DataProvider>().profile;
    name = profile.name;
    title = profile.title;
    bio = profile.bio;
    greeting = profile.greeting;
    email = profile.email;
    phone = profile.phone;
    whatsapp = profile.whatsapp;
    linkedin = profile.linkedin;
    coverImage = profile.coverImage;
    resume = profile.resume;
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final updatedProfile = AppProfile(
        name: name, title: title, bio: bio, greeting: greeting,
        email: email, phone: phone, whatsapp: whatsapp, linkedin: linkedin,
        coverImage: coverImage, resume: resume,
      );
      context.read<DataProvider>().updateProfile(updatedProfile);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile Saved Successfully!', style: TextStyle(color: Colors.white))),
      );
    }
  }

  Future<void> _pickAndUploadImage() async {
    if (_imagePicking || _imageUploading) return;
    setState(() => _imagePicking = true);

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
    setState(() => _imagePicking = false);
    if (picked == null) return;

    setState(() {
      _selectedImage = picked;
      _imageUploading = true;
      _imageUploadProgress = 0;
    });

    try {
      final url = await _firebaseService.uploadProfileImage(
        picked,
        onProgress: (p) => setState(() => _imageUploadProgress = p),
      );
      setState(() { coverImage = url; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Profile image uploaded & saved!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Upload failed: $e')),
        );
      }
    } finally {
      setState(() { _imageUploading = false; _imageUploadProgress = null; });
    }
  }

  Future<void> _pickAndUploadResume() async {
    if (_resumePicking || _resumeUploading) return;
    setState(() => _resumePicking = true);

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    setState(() => _resumePicking = false);
    if (result == null || result.files.isEmpty) return;

    final file = result.files.single;
    setState(() {
      _selectedResumeFileName = file.name;
      _selectedResumeFileSize = file.size;
      _resumeUploading = true;
      _resumeUploadProgress = 0;
    });

    try {
      final url = await _firebaseService.uploadResumePDF(
        file,
        onProgress: (p) => setState(() => _resumeUploadProgress = p),
      );
      setState(() { resume = url; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Resume uploaded & saved!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Upload failed: $e')),
        );
      }
    } finally {
      setState(() { _resumeUploading = false; _resumeUploadProgress = null; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveProfile,
        icon: const Icon(Icons.save),
        label: const Text('Save Changes'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Profile Information', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                CustomTextField(label: 'Full Name', initialValue: name, isRequired: true, onSaved: (v) => name = v!),
                CustomTextField(label: 'Job Title', initialValue: title, isRequired: true, onSaved: (v) => title = v!),
                CustomTextField(label: 'Greeting Alert/Tag', initialValue: greeting, onSaved: (v) => greeting = v!),
                CustomTextField(label: 'About Bio', initialValue: bio, maxLines: 5, onSaved: (v) => bio = v!),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text('Contact Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),

                CustomTextField(label: 'Contact Email', initialValue: email, onSaved: (v) => email = v!),
                CustomTextField(label: 'Phone Number', initialValue: phone, onSaved: (v) => phone = v!),
                CustomTextField(label: 'WhatsApp Number (Intl Format)', initialValue: whatsapp, onSaved: (v) => whatsapp = v!),
                CustomTextField(label: 'LinkedIn Profile Link', initialValue: linkedin, onSaved: (v) => linkedin = v!),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text('Assets', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),

                // --- Profile Image Upload ---
                _ImageUploadCard(
                  colorScheme: colorScheme,
                  isUploading: _imageUploading,
                  isPicking: _imagePicking,
                  progress: _imageUploadProgress,
                  uploadedUrl: coverImage,
                  selectedFile: _selectedImage,
                  onTap: (_imageUploading || _imagePicking) ? null : _pickAndUploadImage,
                ),

                const SizedBox(height: 16),

                // --- Resume PDF Upload ---
                _ResumeUploadCard(
                  colorScheme: colorScheme,
                  isUploading: _resumeUploading,
                  isPicking: _resumePicking,
                  progress: _resumeUploadProgress,
                  uploadedUrl: resume,
                  selectedFileName: _selectedResumeFileName,
                  selectedFileSize: _selectedResumeFileSize,
                  onTap: (_resumeUploading || _resumePicking) ? null : _pickAndUploadResume,
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Profile Image Card ──────────────────────────────────────────────────────

class _ImageUploadCard extends StatelessWidget {
  final ColorScheme colorScheme;
  final bool isUploading, isPicking;
  final double? progress;
  final String uploadedUrl;
  final XFile? selectedFile;
  final VoidCallback? onTap;

  const _ImageUploadCard({
    required this.colorScheme,
    required this.isUploading,
    required this.isPicking,
    required this.progress,
    required this.uploadedUrl,
    required this.selectedFile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasFile = selectedFile != null || uploadedUrl.isNotEmpty;
    final fileName = selectedFile?.name ?? _extractFileName(uploadedUrl);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.person, color: colorScheme.primary),
                const SizedBox(width: 10),
                const Text('Profile Image', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                if (uploadedUrl.isNotEmpty && !isUploading)
                  Chip(
                    label: const Text('Live ✅', style: TextStyle(fontSize: 11)),
                    backgroundColor: Colors.green.withValues(alpha: 0.15),
                    side: BorderSide(color: Colors.green.withValues(alpha: 0.4)),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Preview Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail
                InkWell(
                  onTap: uploadedUrl.isNotEmpty ? () => _launchURL(uploadedUrl) : null,
                  borderRadius: BorderRadius.circular(8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _buildThumbnail(),
                  ),
                ),
                const SizedBox(width: 14),

                // Info + button
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hasFile) ...[
                        Text(
                          fileName,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          selectedFile != null && !isUploading && uploadedUrl.isEmpty
                              ? 'Ready to upload'
                              : isUploading
                                  ? 'Uploading...'
                                  : 'Saved to Firebase Storage',
                          style: TextStyle(
                            fontSize: 12,
                            color: isUploading
                                ? colorScheme.primary
                                : colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ] else ...[
                        Text(
                          'No image uploaded yet',
                          style: TextStyle(fontSize: 13, color: colorScheme.onSurface.withValues(alpha: 0.5)),
                        ),
                      ],

                      if (isUploading) ...[
                        const SizedBox(height: 10),
                        LinearProgressIndicator(
                          value: progress,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          progress != null ? '${(progress! * 100).toStringAsFixed(0)}%' : 'Preparing...',
                          style: TextStyle(fontSize: 11, color: colorScheme.primary),
                        ),
                      ],

                      const SizedBox(height: 12),
                      FilledButton.tonalIcon(
                        onPressed: onTap,
                        icon: isPicking
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                            : isUploading
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Icon(Icons.photo_library_outlined, size: 18),
                        label: Text(
                          isPicking ? 'Opening gallery...' : isUploading ? 'Uploading...' : uploadedUrl.isNotEmpty ? 'Replace Image' : 'Upload Image',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    // Prefer the live uploaded URL for the preview
    if (uploadedUrl.isNotEmpty) {
      return Image.network(
        uploadedUrl,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      width: 80,
      height: 80,
      color: colorScheme.surfaceContainerHighest,
      child: Icon(Icons.person_outline, size: 36, color: colorScheme.onSurface.withValues(alpha: 0.3)),
    );
  }

  String _extractFileName(String url) {
    if (url.isEmpty) return '';
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      return Uri.decodeComponent(segments.last.split('%2F').last);
    } catch (_) {
      return 'profile_image.jpg';
    }
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

// ─── Resume Upload Card ──────────────────────────────────────────────────────

class _ResumeUploadCard extends StatelessWidget {
  final ColorScheme colorScheme;
  final bool isUploading, isPicking;
  final double? progress;
  final String uploadedUrl;
  final String? selectedFileName;
  final int? selectedFileSize;
  final VoidCallback? onTap;

  const _ResumeUploadCard({
    required this.colorScheme,
    required this.isUploading,
    required this.isPicking,
    required this.progress,
    required this.uploadedUrl,
    required this.selectedFileName,
    required this.selectedFileSize,
    required this.onTap,
  });

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final displayName = selectedFileName ?? (uploadedUrl.isNotEmpty ? 'resume.pdf' : null);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.picture_as_pdf, color: Colors.red.shade400),
                const SizedBox(width: 10),
                const Text('Resume / CV', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                if (uploadedUrl.isNotEmpty && !isUploading)
                  Chip(
                    label: const Text('Live ✅', style: TextStyle(fontSize: 11)),
                    backgroundColor: Colors.green.withValues(alpha: 0.15),
                    side: BorderSide(color: Colors.green.withValues(alpha: 0.4)),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // File Preview Row
            Row(
              children: [
                // PDF Icon box
                InkWell(
                  onTap: uploadedUrl.isNotEmpty ? () => _launchURL(uploadedUrl) : null,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 52,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.description_outlined, color: Colors.red.shade400, size: 24),
                        const SizedBox(height: 2),
                        Text('PDF', style: TextStyle(fontSize: 10, color: Colors.red.shade400, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (displayName != null) ...[
                        Text(
                          displayName,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            if (selectedFileSize != null) ...[
                              Text(
                                _formatSize(selectedFileSize!),
                                style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withValues(alpha: 0.5)),
                              ),
                              const SizedBox(width: 8),
                              Container(width: 4, height: 4, decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle)),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              isUploading
                                  ? 'Uploading...'
                                  : uploadedUrl.isNotEmpty
                                      ? 'Saved to Firebase Storage'
                                      : 'Ready to upload',
                              style: TextStyle(
                                fontSize: 12,
                                color: isUploading
                                    ? colorScheme.primary
                                    : colorScheme.onSurface.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        Text(
                          'No CV uploaded yet',
                          style: TextStyle(fontSize: 13, color: colorScheme.onSurface.withValues(alpha: 0.5)),
                        ),
                      ],

                      if (isUploading) ...[
                        const SizedBox(height: 10),
                        LinearProgressIndicator(
                          value: progress,
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.red.shade400,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          progress != null ? '${(progress! * 100).toStringAsFixed(0)}%' : 'Preparing...',
                          style: TextStyle(fontSize: 11, color: Colors.red.shade400),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            FilledButton.tonalIcon(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.withValues(alpha: 0.12),
                foregroundColor: Colors.red.shade700,
              ),
              icon: isPicking
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : isUploading
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.upload_file_outlined, size: 18),
              label: Text(
                isPicking ? 'Opening file picker...' : isUploading ? 'Uploading...' : uploadedUrl.isNotEmpty ? 'Replace CV' : 'Upload CV (PDF)',
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
