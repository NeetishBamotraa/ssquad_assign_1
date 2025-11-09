import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

const String apiUrl = 'http://10.0.2.2:3000';

class BanquetFormScreen extends StatefulWidget {
  const BanquetFormScreen({super.key});

  @override
  State<BanquetFormScreen> createState() => _BanquetFormScreenState();
}

class _BanquetFormScreenState extends State<BanquetFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _stateController = TextEditingController();
  final _cityController = TextEditingController();
  final _adultsController = TextEditingController();
  final _dateController = TextEditingController();
  final _amountController = TextEditingController();

  String? _selectedEventType;
  String? _selectedCountry;
  String? _selectedCatering;
  String? _selectedOfferTime;
  final Map<String, bool> _cuisines = {
    'Indian': false,
    'Italian': false,
    'Asian': false,
    'Mexican': false,
  };

  bool _isSubmitting = false;

  @override
  void dispose() {
    _stateController.dispose();
    _cityController.dispose();
    _adultsController.dispose();
    _dateController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      initialDate: DateTime.now(),
    );
    if (picked != null) {
      _dateController.text = "${picked.day}/${picked.month}/${picked.year}";
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill out all required fields.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final selectedCuisines = _cuisines.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    final formData = {
      'eventType': _selectedEventType,
      'country': _selectedCountry,
      'state': _stateController.text,
      'city': _cityController.text,
      'eventDates': [_dateController.text],
      'numAdults': _adultsController.text,
      'catering': _selectedCatering,
      'cuisines': selectedCuisines,
      'budget': _amountController.text,
      'offerWithin': _selectedOfferTime,
    };

    try {
      final response = await http.post(
        Uri.parse('$apiUrl/api/banquet-request'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(formData),
      );

      if (response.statusCode == 201 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } else {
        throw Exception('Failed: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _buildWhiteCard({required Widget child}) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _loadIcon(String type) {
    final url =
        '$apiUrl/images/${type == "veg" ? "veg-icon.png" : "non-veg-icon.png"}';
    final localAsset =
        'assets/images/${type == "veg" ? "veg-icon.png" : "non-veg-icon.png"}';

    return Image.network(
      url,
      width: 24,
      height: 24,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          localAsset,
          width: 24,
          height: 24,
          errorBuilder: (_, __, ___) => Icon(
            Icons.square,
            color: type == "veg" ? Colors.green : Colors.red,
            size: 24,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Banquets & Venues'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Tell Us Your Venue Requirements',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildWhiteCard(
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: _selectedEventType,
                        hint: const Text('Event Type'),
                        items:
                            const [
                                  'Wedding',
                                  'Anniversary',
                                  'Corporate event',
                                  'Other Party',
                                ]
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedEventType = value),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            v == null ? 'Please select an event type' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCountry,
                        hint: const Text('Country'),
                        items: const ['India', 'China', 'Japan', 'Russia']
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedCountry = value),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            v == null ? 'Please select a country' : null,
                      ), //made by neetish bamotra 2024pcs0031
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _stateController,
                        decoration: const InputDecoration(
                          labelText: 'State',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            (v ?? '').isEmpty ? 'Please enter a state' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _cityController,
                        decoration: const InputDecoration(
                          labelText: 'City',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            (v ?? '').isEmpty ? 'Please enter a city' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _dateController,
                        readOnly: true,
                        onTap: () => _selectDate(context),
                        decoration: const InputDecoration(
                          labelText: 'Event Date',
                          hintText: '1st March 2025',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        validator: (v) =>
                            (v ?? '').isEmpty ? 'Please select a date' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _adultsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Number of Adults',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => (v ?? '').isEmpty
                            ? 'Please enter number of adults'
                            : null,
                      ),
                    ],
                  ),
                ),
                _buildSectionTitle('Catering Preference'),
                _buildWhiteCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            children: [
                              Radio<String>(
                                value: 'Non-veg',
                                groupValue: _selectedCatering,
                                onChanged: (value) {
                                  setState(() => _selectedCatering = value);
                                },
                              ),
                              _loadIcon('non-veg'),
                              const SizedBox(width: 8),
                              const Text('Non-Veg'),
                            ],
                          ),
                          Row(
                            children: [
                              Radio<String>(
                                value: 'Veg',
                                groupValue: _selectedCatering,
                                onChanged: (value) {
                                  setState(() => _selectedCatering = value);
                                },
                              ),
                              _loadIcon('veg'),
                              const SizedBox(width: 8),
                              const Text('Veg'),
                            ],
                          ),
                        ],
                      ),
                      if (_selectedCatering == null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8, left: 12),
                          child: Text(
                            'Please select one',
                            style: TextStyle(
                              color: colorScheme.error,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                _buildSectionTitle('Please select your Cuisines'),
                _buildWhiteCard(
                  child: Column(
                    children: _cuisines.keys.map((key) {
                      return CheckboxListTile(
                        title: Text(key),
                        value: _cuisines[key],
                        onChanged: (v) =>
                            setState(() => _cuisines[key] = v ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                      );
                    }).toList(),
                  ),
                ),
                _buildSectionTitle('Budget'),
                _buildWhiteCard(
                  child: TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(),
                      suffixText: 'INR',
                    ),
                    validator: (v) =>
                        (v ?? '').isEmpty ? 'Please enter a budget' : null,
                  ),
                ),
                _buildSectionTitle('Get offer within'),
                _buildWhiteCard(
                  child: Column(
                    children: [
                      RadioListTile<String>(
                        title: const Text('24 Hours'),
                        value: '24hr',
                        groupValue: _selectedOfferTime,
                        onChanged: (value) =>
                            setState(() => _selectedOfferTime = value),
                      ),
                      RadioListTile<String>(
                        title: const Text('18 Hours'),
                        value: '18hr',
                        groupValue: _selectedOfferTime,
                        onChanged: (value) =>
                            setState(() => _selectedOfferTime = value),
                      ),
                      RadioListTile<String>(
                        title: const Text('12 Hours'),
                        value: '12hr',
                        groupValue: _selectedOfferTime,
                        onChanged: (value) =>
                            setState(() => _selectedOfferTime = value),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: FilledButton(
          onPressed: _isSubmitting ? null : _submitForm,
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isSubmitting
              ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                )
              : const Text(
                  'Submit Request',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }
}
