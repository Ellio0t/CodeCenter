import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/firestore_service.dart';

class SuggestSiteScreen extends StatefulWidget {
  const SuggestSiteScreen({super.key});

  @override
  State<SuggestSiteScreen> createState() => _SuggestSiteScreenState();
}

class _SuggestSiteScreenState extends State<SuggestSiteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();
  final _reasonController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitSuggestion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await FirestoreService().submitSiteSuggestion(
        name: _nameController.text.trim(),
        url: _urlController.text.trim(),
        reason: _reasonController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thanks! Your suggestion has been sent.'),
            backgroundColor: Color(0xFF10D34E),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting suggestion: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suggest a Site', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF10D34E).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF10D34E).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const FaIcon(FontAwesomeIcons.lightbulb, color: Color(0xFF10D34E), size: 24),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        "Know a great site for codes? Let us know and we might add it!",
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              _buildLabel("Site Name", isDark),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _nameController,
                hint: "e.g. CodeMaster",
                icon: FontAwesomeIcons.globe,
                isDark: isDark,
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),

              const SizedBox(height: 20),

              _buildLabel("Website URL", isDark),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _urlController,
                hint: "e.g. www.codemaster.com",
                icon: FontAwesomeIcons.link,
                isDark: isDark,
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),

              const SizedBox(height: 20),

              _buildLabel("Why should we add it?", isDark),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _reasonController,
                hint: "They post daily codes...",
                icon: FontAwesomeIcons.comment,
                isDark: isDark,
                maxLines: 3,
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitSuggestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10D34E),
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: const Color(0xFF10D34E).withOpacity(0.4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text(
                          "SUBMIT SUGGESTION",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.0),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, bool isDark) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        color: isDark ? Colors.white : Colors.black87,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.black38),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12),
          child: FaIcon(icon, size: 18, color: Colors.grey),
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF2D2D2D) : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF10D34E), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
