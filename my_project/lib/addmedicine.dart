import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddMedicine extends StatefulWidget {
  const AddMedicine({super.key});

  @override
  State<AddMedicine> createState() => _AddMedicineState();
}

class _AddMedicineState extends State<AddMedicine> {
  final TextEditingController _medicineNameController = TextEditingController();
  final TextEditingController _medicineDescController = TextEditingController();
  final TextEditingController _medicinePriceController = TextEditingController();
  final CollectionReference medicines = FirebaseFirestore.instance.collection('Medicine');
  String? documentId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null) {
      documentId = args as String;
      _loadMedicineData();
    }
  }

  Future<void> _loadMedicineData() async {
    DocumentSnapshot doc = await medicines.doc(documentId).get();
    _medicineNameController.text = doc["Title"];
    _medicineDescController.text = doc["Description"];
    _medicinePriceController.text = doc["Price"].toString();
  }

  Future<void> addOrUpdateMedicine() async {
    String medicineTitle = _medicineNameController.text.trim();
    String description = _medicineDescController.text.trim();
    String priceText = _medicinePriceController.text.trim();

    if (medicineTitle.isEmpty || description.isEmpty || priceText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required!")),
      );
      return;
    }

    int? price;
    try {
      price = int.parse(priceText);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid price! Enter a valid number.")),
      );
      return;
    }

    if (documentId == null) {
      await medicines.add({
        'Title': medicineTitle,
        'Description': description,
        'Price': price,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Medicine added successfully!")),
      );
    } else {
      await medicines.doc(documentId).update({
        'Title': medicineTitle,
        'Description': description,
        'Price': price,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Medicine updated successfully!")),
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(documentId == null ? "Add Medicine" : "Update Medicine")),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            TextField(
              controller: _medicineNameController,
              decoration: const InputDecoration(
                labelText: "Medicine Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _medicineDescController,
              decoration: const InputDecoration(
                labelText: "Medicine Description",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _medicinePriceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Medicine Price",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: addOrUpdateMedicine,
              child: Text(documentId == null ? "Add Medicine" : "Update Medicine"),
            ),
          ],
        ),
      ),
    );
  }
}
