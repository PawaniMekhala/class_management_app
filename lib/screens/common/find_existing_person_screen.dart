import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/common/qr_scan_button.dart';

class FindExistingPersonScreen extends StatefulWidget {
  final String title;
  final String searchHint;
  final String registerButtonText;
  final bool enableQrScanner;

  final Future<List<Map<String, dynamic>>> Function(String) onSearch;

  final void Function(BuildContext) onRegisterNew;

  final void Function(BuildContext, Map<String, dynamic>) onPersonSelected;

  const FindExistingPersonScreen({
    super.key,
    required this.title,
    required this.searchHint,
    required this.onSearch,
    required this.onRegisterNew,
    required this.onPersonSelected,
    this.registerButtonText = 'Register new',
    this.enableQrScanner = false,
  });

  @override
  State<FindExistingPersonScreen> createState() =>
      _FindExistingPersonScreenState();
}

class _FindExistingPersonScreenState extends State<FindExistingPersonScreen> {
  final TextEditingController _searchController = TextEditingController();

  bool _isSearching = false;
  bool _hasSearched = false;

  List<Map<String, dynamic>> _results = [];

  Future<void> _search(String query) async {
    final text = query.trim();

    if (text.isEmpty) {
      setState(() {
        _hasSearched = false;
        _results = [];
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final results = await widget.onSearch(text);

      if (!mounted) return;

      setState(() {
        _results = results;
        _hasSearched = true;
      });
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to search. Please try again.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.profileBackground,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.profileBackground,
        foregroundColor: AppColors.authHeading,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 22, 16, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'First check whether they are already on IMS '
              '(e.g. at another institute).',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.authHeading,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _searchController,
              onSubmitted: _search,
              textInputAction: TextInputAction.search,
              cursorColor: AppColors.primary,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.authHeading,
              ),
              decoration: InputDecoration(
                hintText: widget.searchHint,
                hintStyle: const TextStyle(
                  fontSize: 11,
                  color: AppColors.authIcon,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.authIcon,
                  size: 19,
                ),

                // Show QR scanner only for students.
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.enableQrScanner)
                      QrScanButton(
                        scannerTitle: 'Find existing student',
                        onScanned: (code) {
                          _searchController.text = code;
                          _search(code);
                        },
                      ),

                    IconButton(
                      tooltip: 'Search',
                      onPressed: () => _search(_searchController.text),
                      icon: const Icon(
                        Icons.arrow_forward,
                        size: 19,
                        color: AppColors.authIcon,
                      ),
                    ),
                  ],
                ),

                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 13,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                  borderSide: const BorderSide(color: AppColors.profileDivider),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                  borderSide: const BorderSide(color: AppColors.profileDivider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // Reuse the existing primary button.
            PrimaryButton(
              text: widget.registerButtonText,
              icon: Icons.person_add_alt_1,
              onPressed: () => widget.onRegisterNew(context),
            ),

            const SizedBox(height: 18),

            if (_isSearching) const Center(child: CircularProgressIndicator()),

            if (!_isSearching && _hasSearched && _results.isEmpty)
              const Text(
                'No matching records found. '
                'If this is a new person, select Register new.',
                style: TextStyle(fontSize: 11, color: AppColors.authIcon),
              ),

            if (!_isSearching)
              ..._results.map(
                (person) => ListTile(
                  title: Text(person['name']?.toString() ?? 'Unknown'),
                  subtitle: Text(
                    person['student_code']?.toString() ??
                        person['teacher_code']?.toString() ??
                        '',
                  ),
                  onTap: () => widget.onPersonSelected(context, person),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
