import 'package:flutter/material.dart';

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PersonalInfoPageState createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  String selectedCountry = 'United States'; // Default country
  String selectedTimezone =
      'Pacific Standard Time (PST) UTC-08:00'; // Default timezone

  @override
  Widget build(BuildContext context) {
    // Get screen width and height
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen =
        screenWidth > 600; // Consider screens above 600px as large screens

    return Scaffold(
      appBar: AppBar(
        title: Text('Personal info'),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              // Cancel button logic
            },
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              // Save button logic
            },
            child: Text('Save', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Update your photo and personal details here.',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  SizedBox(height: 20),

                  // Row for first and last name on large screens
                  if (isLargeScreen)
                    Row(
                      children: [
                        Expanded(
                            child: _buildTextField(
                                'Name', 'First Name', 'Olivia')),
                        SizedBox(width: 16),
                        Expanded(
                            child: _buildTextField('', 'Last Name', 'Rhye')),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildTextField('Name', 'First Name', 'Olivia'),
                        SizedBox(height: 16),
                        _buildTextField('', 'Last Name', 'Rhye'),
                      ],
                    ),

                  SizedBox(height: 16),
                  _buildTextField('Email address', '', 'olivia@untitledui.com',
                      icon: Icons.email),
                  SizedBox(height: 16),
                  _buildPhotoUploadSection(),
                  SizedBox(height: 16),
                  _buildTextField('Role', '', 'Product Designer'),
                  SizedBox(height: 16),

                  // Row for country and timezone dropdowns on large screens
                  if (isLargeScreen)
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdownField(
                            'Country',
                            selectedCountry,
                            ['United States', 'Canada', 'United Kingdom'],
                            icon: Icons.flag,
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  selectedCountry = newValue;
                                });
                              }
                            },
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildDropdownField(
                            'Timezone',
                            selectedTimezone,
                            [
                              'Pacific Standard Time (PST) UTC-08:00',
                              'Eastern Standard Time (EST) UTC-05:00',
                              'Central European Time (CET) UTC+01:00'
                            ],
                            icon: Icons.access_time,
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  selectedTimezone = newValue;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildDropdownField(
                          'Country',
                          selectedCountry,
                          ['United States', 'Canada', 'United Kingdom'],
                          icon: Icons.flag,
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                selectedCountry = newValue;
                              });
                            }
                          },
                        ),
                        SizedBox(height: 16),
                        _buildDropdownField(
                          'Timezone',
                          selectedTimezone,
                          [
                            'Pacific Standard Time (PST) UTC-08:00',
                            'Eastern Standard Time (EST) UTC-05:00',
                            'Central European Time (CET) UTC+01:00'
                          ],
                          icon: Icons.access_time,
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                selectedTimezone = newValue;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, String initialValue,
      {IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            filled: true,
            fillColor: Colors.grey.shade100,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your photo',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage:
                    AssetImage('assets/logo.png'), // Example image asset
                backgroundColor: Colors.grey.shade200,
              ),
              SizedBox(height: 8),
              Text(
                'Click to upload or drag and drop',
                style: TextStyle(color: Colors.blue),
              ),
              Text(
                'SVG, PNG, JPG or GIF (max. 800x400px)',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(
      String label, String selectedValue, List<String> options,
      {IconData? icon, required ValueChanged<String?> onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButton<String>(
            value: selectedValue,
            icon: Icon(Icons.arrow_drop_down, color: Colors.grey),
            iconSize: 24,
            elevation: 16,
            underline: Container(),
            isExpanded: true,
            style: TextStyle(color: Colors.black, fontSize: 16),
            onChanged: onChanged,
            items: options.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Row(
                  children: [
                    if (icon != null) Icon(icon, color: Colors.grey),
                    SizedBox(width: 8),
                    Text(value),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
