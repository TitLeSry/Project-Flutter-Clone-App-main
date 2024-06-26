import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StockDetailPage extends StatefulWidget {
  final DocumentReference docRef;

  FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  StockDetailPage({Key? key, required this.docRef}) : super(key: key);

  @override
  _StockDetailPageState createState() => _StockDetailPageState();
}

class _StockDetailPageState extends State<StockDetailPage> {
  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Menu Detail'),
        toolbarHeight: 80,
        leading: IconButton(
          padding: const EdgeInsets.only(left: 10),
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            size: 30,
            color: Colors.black,
          ),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: widget.docRef.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData) {
            return Center(
              child: Text('No Data'),
            );
          }

          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          final menuController = TextEditingController(text: data['name']);
          final priceController =
              TextEditingController(text: data['price'].toString());

          return Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.white,
            key: scaffoldKey,
            body: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                color: Color.fromARGB(255, 240, 240, 240),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.025,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.025,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.025,
                  ),
                  Container(
                    width: 320,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: menuController,
                          decoration: InputDecoration(
                            labelText: 'Choice',
                          ),
                          onChanged: (value) {},
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.025,
                        ),
                        TextFormField(
                          controller: priceController,
                          decoration: InputDecoration(
                            labelText: 'Price',
                          ),
                          onChanged: (value) {},
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.025,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          onPressed: () async {
                            await setMenuCollection(
                                    menuController.text,
                                    int.parse(priceController.text),
                                    data['docId'])
                                ?.then((value) => Navigator.pop(context));
                          },
                          child: const Text('Confirm edit choice.'))
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.025,
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future _acceptEdit() async {}

  Future<dynamic>? setMenuCollection(
    String name,
    int price,
    String data,
  ) async {
    await FirebaseFirestore.instance
        .collection('stock')
        .doc('$data')
        .update({'name': name, 'price': price});
  }
}
