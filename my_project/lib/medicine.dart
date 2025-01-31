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
                crossAxisCount: 2, 
                crossAxisSpacing: 8, 
                mainAxisSpacing: 8,
                childAspectRatio: 0.6, 
              ),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var doc = snapshot.data!.docs[index];

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // Adjusts height dynamically
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.medical_services, size: 28, color: Colors.blue),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                doc["Title"],
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        Text(
                          doc["Description"],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 10, color: Colors.black54),
                        ),
                        const SizedBox(height: 6),

                        Text(
                          "\$${doc["Price"].toString()}",
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                        const SizedBox(height: 8),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () => updateMedicine(doc.id),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.black, 
                                backgroundColor: Colors.grey[300],
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              ),
                              child: const Text("Update", style: TextStyle(fontSize: 10)),
                            ),
                            ElevatedButton(
                              onPressed: () => deleteMedicine(doc.id),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.black, 
                                backgroundColor: Colors.red[300],
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              ),
                              child: const Text("Delete", style: TextStyle(fontSize: 10)),
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
