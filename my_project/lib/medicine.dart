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

  void deleteMedicine(String documentId) async {
    await FirebaseFirestore.instance
        .collection('Medicine')
        .doc(documentId)
        .delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Medicine deleted successfully!")),
    );
  }

  void updateMedicine(String documentId) async {
    Navigator.pushNamed(context, '/addmedicine', arguments: documentId);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    // Adjust number of columns based on screen size
    int crossAxisCount = screenWidth < 600 ? 2 : 4;  // Use 2 columns on small screens, 4 on large screens

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Available Medicines",
          style: TextStyle(fontSize: 24), // Increased font size for app bar title
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, size: 35),  // Increased icon size
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
            padding: const EdgeInsets.all(6.0),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
                childAspectRatio: 1.9, // Adjust child aspect ratio based on screen size
              ),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var doc = snapshot.data!.docs[index];

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.medical_services,
                              size: 24, // Increased icon size
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                doc["Title"],
                                style: const TextStyle(
                                  fontSize: 16, // Increased font size
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          doc["Description"],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12, // Increased font size
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "\$${doc["Price"].toString()}",
                          style: const TextStyle(
                            fontSize: 14, // Increased font size
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () => updateMedicine(doc.id),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.black,
                                backgroundColor: Colors.grey[300],
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 6), // Increased padding
                              ),
                              child: const Text(
                                "Update",
                                style: TextStyle(fontSize: 14), // Increased font size
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () => deleteMedicine(doc.id),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.black,
                                backgroundColor: Colors.red[300],
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 6), // Increased padding
                              ),
                              child: const Text(
                                "Delete",
                                style: TextStyle(fontSize: 14), // Increased font size
                              ),
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
