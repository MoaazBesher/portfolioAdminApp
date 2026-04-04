import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/app_models.dart';
import '../../../providers/data_provider.dart';
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

    String title = existingCert?.title ?? '';
    String issuer = existingCert?.issuer ?? '';
    String date = existingCert?.date ?? '';
    String category = existingCert?.category ?? 'professional';
    String pdfUrl = existingCert?.pdfUrl ?? '';
    String description = existingCert?.description ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 16, right: 16, top: 24,
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
                Text(existingCert == null ? 'Add Certificate' : 'Edit Certificate', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                CustomTextField(label: 'Certificate Title', initialValue: title, isRequired: true, onSaved: (v) => title = v!),
                CustomTextField(label: 'Issuer (e.g. Coursera)', initialValue: issuer, isRequired: true, onSaved: (v) => issuer = v!),
                CustomTextField(label: 'Date (ex: Nov 2023)', initialValue: date, isRequired: true, onSaved: (v) => date = v!),
                CustomTextField(label: 'Category', initialValue: category, onSaved: (v) => category = v!),
                CustomTextField(label: 'PDF View/Download URL (Optional)', initialValue: pdfUrl, onSaved: (v) => pdfUrl = v!),
                CustomTextField(label: 'Description', initialValue: description, maxLines: 4, onSaved: (v) => description = v!),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                    ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          formKey.currentState!.save();
                          provider.saveCertificate(Certificate(
                            id: existingCert?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                            title: title, issuer: issuer, date: date, category: category, 
                            pdfUrl: pdfUrl, description: description,
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
      ),
    );
  }
}
