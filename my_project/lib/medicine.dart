import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MyMedicine extends StatefulWidget {
  const MyMedicine({super.key});

  @override
  State<MyMedicine> createState() => _MyMedicineState();
}

class _MyMedicineState extends State<MyMedicine> {
  Stream<QuerySnapshot> medicines =
      FirebaseFirestore.instance.collection("Medicine").snapshots();

  // Method to delete medicine
  void deleteMedicine(String documentId) async {
    await FirebaseFirestore.instance
        .collection('Medicine')
        .doc(documentId)
        .delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Medicine deleted successfully!")),
    );
  }

  // Method to update medicine
  void updateMedicine(String documentId) async {
    Navigator.pushNamed(context, '/addmedicine', arguments: documentId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Available Medicines"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, size: 30),
            onPressed: () {
              Navigator.pushNamed(context, "/addmedicine");
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: medicines,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No medicines available!"));
          }

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Two columns for the grid
                crossAxisSpacing: 8, // Reduced spacing between cards
                mainAxisSpacing: 8,
                childAspectRatio: 0.5, // Further reduced aspect ratio for smaller cards
              ),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var doc = snapshot.data!.docs[index];

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Smaller rounded corners
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8), // Reduced vertical padding
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
                      children: [
                        // Row to align the icon and title side by side
                        Row(
                          children: [
                            Icon(Icons.medical_services, size: 30, color: Colors.blue), // Smaller icon size
                            const SizedBox(width: 8), // Reduced space between icon and title
                            // Medicine Title
                            Expanded(
                              child: Text(
                                doc["Title"],
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6), // Reduced space between title and description

                        // Medicine Description
                        Text(
                          doc["Description"],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 10, color: Colors.black54), // Smaller text size for description
                        ),
                        const SizedBox(height: 6), // Reduced space between description and price

                        // Medicine Price
                        Text(
                          "\$${doc["Price"].toString()}",
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                        const SizedBox(height: 6), // Reduced space between price and buttons

                        // Buttons Row (Update and Delete)
                        Row(
                          children: [
                            // Update Button
                            ElevatedButton(
                              onPressed: () => updateMedicine(doc.id),
                              child: const Text("Update", style: TextStyle(fontSize: 10)), // Smaller text size for buttons
                            ),
                            const SizedBox(width: 8), // Reduced space between buttons
                            // Delete Button
                            ElevatedButton(
                              onPressed: () => deleteMedicine(doc.id),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text("Delete", style: TextStyle(fontSize: 10)), // Smaller text size for buttons
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
