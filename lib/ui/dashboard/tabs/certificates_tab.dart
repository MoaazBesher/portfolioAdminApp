import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/app_models.dart';
import '../../../providers/data_provider.dart';
import '../../../services/firebase_service.dart';
import '../../components/generic_list_tab.dart';
import '../../components/custom_text_field.dart';

class CertificatesTab extends StatelessWidget {
  const CertificatesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, provider, child) {
        return GenericListTab<Certificate>(
          title: 'Manage Certificates',
          emptyMessage: 'No certificates yet.',
          items: provider.certificates,
          onAddPressed: () => _showCertificateForm(context, null),
          itemBuilder: (ctx, cert) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Icon(Icons.workspace_premium, color: Theme.of(context).primaryColor),
              title: Text(cert.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${cert.issuer} • ${cert.date}', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 13)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blueAccent),
                    onPressed: () => _showCertificateForm(context, cert),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () async {
                      if (await showConfirmDelete(context, cert.title)) {
                        provider.deleteCertificate(cert.id);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCertificateForm(BuildContext context, Certificate? existingCert) {
    final formKey = GlobalKey<FormState>();
    final provider = context.read<DataProvider>();
    final firebaseService = FirebaseService();

    String title = existingCert?.title ?? '';
    String issuer = existingCert?.issuer ?? '';
    String date = existingCert?.date ?? '';
    String category = existingCert?.category ?? 'professional';
    String pdfUrl = existingCert?.pdfUrl ?? '';
    String description = existingCert?.description ?? '';
    String certId = existingCert?.id ?? DateTime.now().millisecondsSinceEpoch.toString();

    // Upload state
    bool isUploading = false;
    double? uploadProgress;
    String? selectedFileName;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (stContext, setState) {
          final colorScheme = Theme.of(context).colorScheme;

          Future<void> pickAndUpload() async {
            if (isUploading) return;

            final result = await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['pdf'],
            );

            if (result == null || result.files.isEmpty) return;
            final file = result.files.single;

            setState(() {
              isUploading = true;
              uploadProgress = 0;
              selectedFileName = file.name;
            });

            try {
              final url = await firebaseService.uploadCertificatePDF(
                file,
                certId,
                onProgress: (p) => setState(() => uploadProgress = p),
              );
              setState(() {
                pdfUrl = url;
                isUploading = false;
                uploadProgress = null;
              });
              if (stContext.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ Certificate PDF uploaded successfully!')),
                );
              }
            } catch (e) {
              setState(() {
                isUploading = false;
                uploadProgress = null;
              });
              if (stContext.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('❌ Upload failed: $e')),
                );
              }
            }
          }

          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 24,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      existingCert == null ? 'Add Certificate' : 'Edit Certificate',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(label: 'Certificate Title', initialValue: title, isRequired: true, onSaved: (v) => title = v!),
                    CustomTextField(label: 'Issuer (e.g. Coursera)', initialValue: issuer, isRequired: true, onSaved: (v) => issuer = v!),
                    CustomTextField(label: 'Date (ex: Nov 2023)', initialValue: date, isRequired: true, onSaved: (v) => date = v!),
                    CustomTextField(label: 'Category', initialValue: category, onSaved: (v) => category = v!),
                    
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Certificate Asset', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),

                    _PDFUploadCard(
                      colorScheme: colorScheme,
                      isUploading: isUploading,
                      progress: uploadProgress,
                      uploadedUrl: pdfUrl,
                      selectedFileName: selectedFileName,
                      onTap: isUploading ? null : pickAndUpload,
                    ),

                    CustomTextField(label: 'Description', initialValue: description, maxLines: 4, onSaved: (v) => description = v!),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                        ElevatedButton(
                          onPressed: isUploading ? null : () {
                            if (formKey.currentState!.validate()) {
                              formKey.currentState!.save();
                              provider.saveCertificate(Certificate(
                                id: certId,
                                title: title,
                                issuer: issuer,
                                date: date,
                                category: category,
                                pdfUrl: pdfUrl,
                                description: description,
                              ));
                              Navigator.pop(ctx);
                            }
                          },
                          child: const Text('Save Certificate'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PDFUploadCard extends StatelessWidget {
  final ColorScheme colorScheme;
  final bool isUploading;
  final double? progress;
  final String uploadedUrl;
  final String? selectedFileName;
  final VoidCallback? onTap;

  const _PDFUploadCard({
    required this.colorScheme,
    required this.isUploading,
    required this.progress,
    required this.uploadedUrl,
    required this.selectedFileName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = selectedFileName ?? (uploadedUrl.isNotEmpty ? 'certificate_view.pdf' : null);

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: colorScheme.outlineVariant)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName ?? 'No file uploaded',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        isUploading ? 'Uploading...' : uploadedUrl.isNotEmpty ? 'Ready in Firebase' : 'Upload certificate PDF',
                        style: TextStyle(fontSize: 11, color: colorScheme.onSurface.withValues(alpha: 0.6)),
                      ),
                    ],
                  ),
                ),
                if (uploadedUrl.isNotEmpty && !isUploading)
                  IconButton(
                    icon: const Icon(Icons.open_in_new, size: 20),
                    onPressed: () async {
                      final uri = Uri.parse(uploadedUrl);
                      if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
                    },
                  ),
              ],
            ),
            if (isUploading) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(value: progress, borderRadius: BorderRadius.circular(4)),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: onTap,
                icon: isUploading 
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.upload_file, size: 18),
                label: Text(isUploading ? 'Uploading...' : uploadedUrl.isNotEmpty ? 'Replace PDF' : 'Choose PDF File'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
