import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'edit_stock_promotion.dart';

class StockPromotionDetail extends StatefulWidget {
  final List<DocumentSnapshot> availablePromotion;
  const StockPromotionDetail({super.key, required this.availablePromotion});

  @override
  State<StockPromotionDetail> createState() => _StockPromotionDetailState();
}

class _StockPromotionDetailState extends State<StockPromotionDetail> {
  void _navigateToDetailPage(DocumentReference docRef) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditStockPromotion(docRef: docRef),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.width * 0.03,
        ),
        for (var doc in widget.availablePromotion)
          Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.width * 0.25,
                width: MediaQuery.of(context).size.width * 0.95,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                      // changes position of shadow
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    InkWell(
                      child: Container(
                        margin: const EdgeInsets.all(7),
                        height: MediaQuery.of(context).size.width * 0.4,
                        width: MediaQuery.of(context).size.width * 0.3,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(doc['url']),
                            fit: BoxFit.cover,
                          ),
                          border:
                              Border.all(width: 1, color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    Container(
                      child: Column(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.width * 0.05,
                          ),
                          Container(
                            child: Text(
                              // Get the name from Firestore
                              doc['name'],
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.width * 0.001,
                          ),
                          Container(
                            child: Text(
                              // Get the name from Firestore
                              'Quantity : ${doc['quantity']}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        const Spacer(),
                        GestureDetector(
                          onTap: () async {
                            DocumentReference docRef = FirebaseFirestore
                                .instance
                                .collection('promotion')
                                .doc(doc['docId']);
                            _navigateToDetailPage(docRef);
                          },
                          child: Container(
                            height: MediaQuery.of(context).size.width * 0.09,
                            width: MediaQuery.of(context).size.width * 0.18,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 33, 128, 223),
                              borderRadius: BorderRadius.circular(16.0),
                              boxShadow: const [
                                BoxShadow(
                                  blurRadius: 10,
                                  color: Color.fromARGB(152, 0, 0, 0),
                                  offset: Offset(1, 2),
                                )
                              ],
                            ),
                            child: Center(
                              child: Text(
                                'Edit',
                                style: GoogleFonts.poppins(
                                  textStyle:
                                      Theme.of(context).textTheme.titleLarge,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.width * 0.03,
              )
            ],
          ),
      ],
    );
  }
}
