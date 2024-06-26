import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:test_se/model/product.dart';
import 'package:test_se/provider/provider.dart';

import '../../widgets/drawer_list.dart';

class OrderList extends StatefulWidget {
  const OrderList({super.key});

  @override
  State<OrderList> createState() => _OrderListState();
}

class _OrderListState extends State<OrderList> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  void initState() {
    super.initState();
    Provider.of<CartProvider>(context, listen: false).fetchCartFromSharedPref();
    Provider.of<ConfirmCart>(context, listen: false)
        .fetchConfirmCartFromSharedPref();
  }

  @override
  Widget build(BuildContext context) {
    bool isPressed = false;
    bool isSnackBarVisible = false;
    User? user = FirebaseAuth.instance.currentUser;
    String user_id = user!.uid;

    final formatCurrency = NumberFormat.currency(locale: 'en_US', symbol: '');
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xff17333C),
      key: scaffoldKey,
      drawer: DrawerList(),
      appBar: AppBar(
        toolbarHeight: 90,
        leading: IconButton(
          padding: const EdgeInsets.only(left: 10),
          onPressed: () {
            scaffoldKey.currentState?.openDrawer();
          },
          icon: const Icon(
            Icons.notifications_active,
            size: 30,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff396870), Color(0xff17333C)],
              stops: [0, 1],
              begin: AlignmentDirectional(0, -0.8),
              end: AlignmentDirectional(0, 1.5),
              tileMode: TileMode.clamp,
            ),
          ),
        ),
        title: const Text(
          "Order",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            color: Color.fromARGB(255, 240, 240, 240)),
        child: Consumer<CartProvider>(
          builder: (context, cartProvider, _) {
            List<Product> cartItems = cartProvider.items;

            if (cartItems.isEmpty) {
              return Center(
                child: Text('There are no products in the cart.'),
              );
            } else {
              return ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  Product product = cartItems[index];

                  return Container(
                    margin: EdgeInsets.all(
                        MediaQuery.of(context).size.width * 0.025),
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(0)),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(
                              MediaQuery.of(context).size.width * 0.04),
                          child: Text(
                            '${product.name} Price: ${product.price} THB',
                            style: GoogleFonts.mitr(
                              textStyle: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400),
                            ),
                          ),
                        ),
                        Container(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: Row(
                              children: [
                                IconButton(
                                    onPressed: () {
                                      cartProvider.removeFromCart(product);
                                    },
                                    icon: const Icon(Icons.remove)),
                                Text(
                                  '${product.quantity}',
                                  style: GoogleFonts.mitr(
                                    textStyle: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                                IconButton(
                                    onPressed: () async {
                                      DocumentSnapshot snapshot =
                                          await FirebaseFirestore.instance
                                              .collection('stock')
                                              .doc(product.id)
                                              .get();
                                      int currentQuantity =
                                          snapshot['quantity'];
                                      if (product.quantity < currentQuantity) {
                                        // ignore: use_build_context_synchronously
                                        Provider.of<CartProvider>(context,
                                                listen: false)
                                            .addToCart(product);
                                      } else {
                                        if (!isSnackBarVisible) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'There arent enough programmers right now.'),
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                          isSnackBarVisible = true;

                                          Timer(Duration(seconds: 2), () {
                                            isSnackBarVisible = false;
                                          });
                                        }
                                      }
                                    },
                                    icon: const Icon(Icons.add)),
                              ],
                            )),
                      ],
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (context, cartProvider, _) {
          int totalPrice = cartProvider.getTotalPrice();

          return BottomAppBar(
            height: 80,
            child: Container(
              padding: EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Container(
                    //HERE
                    width: MediaQuery.of(context).size.width * 0.35,
                    child: Text(
                      'Total: ${formatCurrency.format(totalPrice)} THB',
                      style: GoogleFonts.mitr(
                        textStyle: TextStyle(
                            color: Colors.black,
                            fontSize: MediaQuery.of(context).size.width * 0.03,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: Row(
                      children: [
                        Spacer(),
                        Container(
                          //HERE

                          child: ElevatedButton(
                            onPressed: () async {
                              DocumentSnapshot snapshot =
                                  await FirebaseFirestore.instance
                                      .collection('user')
                                      .doc(user_id)
                                      .get();
                              String name = snapshot['name'];
                              Provider.of<ConfirmCart>(context, listen: false)
                                  .confirmOrder(context);
                              for (var item in Provider.of<CartProvider>(
                                      context,
                                      listen: false)
                                  .items) {
                                DocumentSnapshot snapshot =
                                    await FirebaseFirestore.instance
                                        .collection('stock')
                                        .doc(item.id)
                                        .get();
                                addWaitCollection(Timestamp.now(), user.uid,
                                    item.name, item.quantity, name);
                                int currentQuantity = snapshot['quantity'];
                                if (currentQuantity >= item.quantity) {
                                  FirebaseFirestore.instance
                                      .collection('stock')
                                      .doc(item.id)
                                      .update({
                                    'quantity':
                                        FieldValue.increment(-item.quantity),
                                  });
                                }
                              }

                              Provider.of<CartProvider>(context, listen: false)
                                  .clearCart();
                            },
                            style: ButtonStyle(
                              padding:
                                  MaterialStateProperty.all<EdgeInsetsGeometry>(
                                EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 10),
                              ),
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  Color.fromARGB(255, 74, 172, 253)),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                ),
                              ),
                            ),
                            child: const Text('Confirm'),
                          ),
                        ),
                        Spacer(),
                        Container(
                          //HERE
                          width: MediaQuery.of(context).size.width * 0.2,
                          child: ElevatedButton(
                              style: ButtonStyle(
                                padding: MaterialStateProperty.all<
                                    EdgeInsetsGeometry>(
                                  EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 10),
                                ),
                                foregroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Color.fromARGB(255, 74, 172, 253)),
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                  ),
                                ),
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return Dialog(
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                1.5,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.6,
                                        child: Column(
                                          children: [
                                            Expanded(
                                              child: Consumer<ConfirmCart>(
                                                builder:
                                                    (context, cartConfirm, _) {
                                                  List<Product> cartItems =
                                                      cartConfirm.items;

                                                  if (cartItems.isEmpty) {
                                                    return const Center(
                                                      child: Text(
                                                          'There are no products in the cart.'),
                                                    );
                                                  } else {
                                                    return ListView.builder(
                                                      itemCount:
                                                          cartItems.length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        Product product =
                                                            cartItems[index];

                                                        return Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              1,
                                                          margin: EdgeInsets.all(
                                                              MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.04),
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          0)),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceAround,
                                                            children: [
                                                              Container(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.18,
                                                                child: Text(
                                                                  '${product.name}',
                                                                  style:
                                                                      GoogleFonts
                                                                          .mitr(
                                                                    textStyle: const TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontSize:
                                                                            10,
                                                                        fontWeight:
                                                                            FontWeight.w400),
                                                                  ),
                                                                ),
                                                              ),
                                                              Container(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.18,
                                                                child: Text(
                                                                  'Price: ${product.price} THB',
                                                                  style:
                                                                      GoogleFonts
                                                                          .mitr(
                                                                    textStyle: const TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontSize:
                                                                            10,
                                                                        fontWeight:
                                                                            FontWeight.w400),
                                                                  ),
                                                                ),
                                                              ),
                                                              Container(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.18,
                                                                child: Text(
                                                                  'จำนวณ: ${product.quantity}',
                                                                  style:
                                                                      GoogleFonts
                                                                          .mitr(
                                                                    textStyle: const TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontSize:
                                                                            10,
                                                                        fontWeight:
                                                                            FontWeight.w400),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  }
                                                },
                                              ),
                                            ),
                                            Center(
                                              child: Column(
                                                children: [
                                                  Consumer<ConfirmCart>(
                                                    builder: (context,
                                                        cartProvider, _) {
                                                      int totalPriceConfirm =
                                                          cartProvider
                                                              .getTotalPrice();
                                                      return Text(
                                                          "Total: ${formatCurrency.format(totalPriceConfirm)} THB");
                                                    },
                                                  ),
                                                  SizedBox(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.025),
                                                  ElevatedButton(
                                                    onPressed: () async {
                                                      // print(user_id);
                                                      if (Provider.of<
                                                                  ConfirmCart>(
                                                              context,
                                                              listen: false)
                                                          .items
                                                          .isNotEmpty) {
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) {
                                                            return Dialog(
                                                              child: SizedBox(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    1.2,
                                                                height: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height *
                                                                    0.2,
                                                                child: Center(
                                                                    child:
                                                                        Column(
                                                                  children: [
                                                                    Spacer(),
                                                                    Text(
                                                                      'Confirm to pay Yes or No',
                                                                      style: GoogleFonts
                                                                          .poppins(
                                                                        textStyle: Theme.of(context)
                                                                            .textTheme
                                                                            .titleLarge,
                                                                        fontSize:
                                                                            18,
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                        color: Colors
                                                                            .black,
                                                                      ),
                                                                    ),
                                                                    Spacer(),
                                                                    Row(
                                                                      children: [
                                                                        Spacer(),
                                                                        ElevatedButton(
                                                                          onPressed:
                                                                              () async {
                                                                            Navigator.pop(context);
                                                                          },
                                                                          style:
                                                                              ElevatedButton.styleFrom(
                                                                            shape:
                                                                                RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.circular(25),
                                                                            ),
                                                                            backgroundColor: Color.fromARGB(
                                                                                255,
                                                                                253,
                                                                                74,
                                                                                74),
                                                                            padding:
                                                                                const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                                                          ),
                                                                          child:
                                                                              const Text(
                                                                            'Cancel',
                                                                            style:
                                                                                TextStyle(
                                                                              color: Colors.white,
                                                                              fontSize: 16,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Spacer(),
                                                                        ElevatedButton(
                                                                          onPressed:
                                                                              () async {
                                                                            DocumentSnapshot
                                                                                snapshot =
                                                                                await FirebaseFirestore.instance.collection('user').doc(user_id).get();
                                                                            String
                                                                                name =
                                                                                snapshot['name'];
                                                                            addMenuCollection(
                                                                                user_id,
                                                                                Provider.of<ConfirmCart>(context, listen: false).getTotalPrice(),
                                                                                Provider.of<ConfirmCart>(context, listen: false),
                                                                                name);
                                                                            print(Provider.of<ConfirmCart>(context, listen: false).getTotalPrice());
                                                                            Provider.of<ConfirmCart>(context, listen: false).clearCart();
                                                                            Navigator.pop(context);
                                                                            Navigator.pop(context);
                                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                                              const SnackBar(
                                                                                content: Text('Please contact the staff.'),
                                                                                duration: Duration(seconds: 2),
                                                                              ),
                                                                            );
                                                                          },
                                                                          style:
                                                                              ElevatedButton.styleFrom(
                                                                            shape:
                                                                                RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.circular(25),
                                                                            ),
                                                                            backgroundColor: Color.fromARGB(
                                                                                255,
                                                                                74,
                                                                                172,
                                                                                253),
                                                                            padding:
                                                                                const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                                                          ),
                                                                          child:
                                                                              const Text(
                                                                            'Confirm',
                                                                            style:
                                                                                TextStyle(
                                                                              color: Colors.white,
                                                                              fontSize: 16,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Spacer()
                                                                      ],
                                                                    ),
                                                                    Spacer()
                                                                  ],
                                                                )),
                                                              ),
                                                            );
                                                          },
                                                        );
                                                      }
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(25),
                                                      ),
                                                      backgroundColor:
                                                          Color.fromARGB(255,
                                                              74, 172, 253),
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 10,
                                                          horizontal: 20),
                                                    ),
                                                    child: const Text(
                                                      'Pay',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.025),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Text('Bill summary')),
                        ),
                        Spacer(),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> addMenuCollection(
      String uid, int price, ConfirmCart confirmCart, String name) async {
    List<Map<String, dynamic>> itemsData = [];

    for (Product product in confirmCart.items) {
      Map<String, dynamic> productData = {
        'name': product.name,
        'price': product.price,
        'quantity': product.quantity,
      };
      itemsData.add(productData);
    }

    await FirebaseFirestore.instance.collection('income').add({
      'status': false,
      'receipt': price,
      'time': DateTime.now(),
      'uid': uid,
      'list': itemsData,
      'name': name,
    }).then((DocumentReference docRef) {
      String docId = docRef.id;
      FirebaseFirestore.instance.collection('income').doc(docId).update({
        'id': docId,
      });
      print('Already added income: $docId');
    }).catchError((error) {
      print(error);
    });
  }

  // Future<void> addWaitingOrder(
  //   String uid,
  //   int price,
  //   ConfirmCart confirmCart,
  // ) async {
  //   await FirebaseFirestore.instance.collection('income').add({
  //     'status': false,
  //     'receipt': price,
  //     'time': DateTime.now(),
  //     'uid': uid,
  //   }).then((DocumentReference docRef) {
  //     String docId = docRef.id;
  //     print('เพิ่มรายรับไปแล้ว: $docId');
  //   }).catchError((error) {
  //     print(error);
  //   });
  // }

  Future addWaitCollection(Timestamp init_time, String uid, String order,
      int orderQuantity, String name) async {
    var docWaiting =
        await FirebaseFirestore.instance.collection('waiting').doc(uid).get();

    if (docWaiting.exists) {
      int currentOrderQuantity = docWaiting.data()?[order] ?? 0;
      int updatedOrderQuantity = currentOrderQuantity + orderQuantity;
      await FirebaseFirestore.instance.collection('waiting').doc(uid).update(
        {
          'name': name,
          'init_time': init_time,
          'uid': uid,
          order: updatedOrderQuantity,
          'status': false,
        },
      );
    } else {
      await FirebaseFirestore.instance.collection('waiting').doc(uid).set(
        {
          'name': name,
          'init_time': init_time,
          'uid': uid,
          order: orderQuantity,
          'status': false,
        },
      );
    }
  }
}
