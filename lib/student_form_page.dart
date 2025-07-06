import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentFormPage extends StatefulWidget {
  const StudentFormPage({super.key});

  @override
  State<StudentFormPage> createState() => _StudentFormPageState();
}

class _StudentFormPageState extends State<StudentFormPage> {
  final TextEditingController _isimController = TextEditingController();
  final TextEditingController _soyisimController = TextEditingController();
  final TextEditingController _dogumTarihiController = TextEditingController();
  final TextEditingController _guncelTYTController = TextEditingController();
  final TextEditingController _hedefTYTController = TextEditingController();
  final TextEditingController _guncelAYTController = TextEditingController();
  final TextEditingController _hedefAYTController = TextEditingController();
  final TextEditingController _hedefUniController = TextEditingController();
  final TextEditingController _hedefBolumController = TextEditingController();

  String _selectedGender = 'Erkek';

  Future<void> saveForm() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('isim', _isimController.text);
    await prefs.setString('soyisim', _soyisimController.text);
    await prefs.setString('cinsiyet', _selectedGender);
    await prefs.setString('dogumTarihi', _dogumTarihiController.text);
    await prefs.setInt('guncelTYT', int.tryParse(_guncelTYTController.text) ?? 0);
    await prefs.setInt('hedefTYT', int.tryParse(_hedefTYTController.text) ?? 0);
    await prefs.setInt('guncelAYT', int.tryParse(_guncelAYTController.text) ?? 0);
    await prefs.setInt('hedefAYT', int.tryParse(_hedefAYTController.text) ?? 0);
    await prefs.setString('hedefUni', _hedefUniController.text);
    await prefs.setString('hedefBolum', _hedefBolumController.text);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bilgiler kaydedildi ✅')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('👤 Öğrenci Formu'),
        backgroundColor: Colors.lightBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            _buildTextField(_isimController, 'İsim'),
            const SizedBox(height: 12),
            _buildTextField(_soyisimController, 'Soyisim'),
            const SizedBox(height: 12),
            _buildGenderDropdown(),
            const SizedBox(height: 12),
            _buildTextField(_dogumTarihiController, 'Doğum Tarihi (g/a/y)'),
            const SizedBox(height: 12),
            _buildTextField(_guncelTYTController, 'Güncel TYT Netin', isNumber: true),
            const SizedBox(height: 12),
            _buildTextField(_hedefTYTController, 'Hedef TYT Netin', isNumber: true),
            const SizedBox(height: 12),
            _buildTextField(_guncelAYTController, 'Güncel AYT Netin', isNumber: true),
            const SizedBox(height: 12),
            _buildTextField(_hedefAYTController, 'Hedef AYT Netin', isNumber: true),
            const SizedBox(height: 12),
            _buildTextField(_hedefUniController, 'Hedef Üniversite'),
            const SizedBox(height: 12),
            _buildTextField(_hedefBolumController, 'Hedef Bölüm'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveForm,
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      decoration: InputDecoration(
        labelText: 'Cinsiyet',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      items: ['Erkek', 'Kız'].map((gender) {
        return DropdownMenuItem(value: gender, child: Text(gender));
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedGender = value!;
        });
      },
    );
  }
}
