import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mend_doctor/models/modEvent.dart';
import 'package:mend_doctor/models/modEventProgramItem.dart';
import 'package:mend_doctor/utils/fetchApi.dart';
import 'package:mend_doctor/utils/staticData.dart';
import 'package:mend_doctor/utils/staticUrl.dart';
import 'package:mend_doctor/utils/toast.dart';

class EventInvoicePage extends StatefulWidget {
  static const routeName = '/eventInvoicePage';
  final Event event;
  EventInvoicePage({Key key, @required this.event}) : super(key: key);
  @override
  EventInvoicePageState createState() {
    // TODO: implement createState
    return EventInvoicePageState(event);
  }
}

class EventInvoicePageState extends State<EventInvoicePage> {
  Event event;
  EventInvoicePageState(this.event);
  List<Package> mPackages;
  List<Invoice> mInvoices;
  List<EventProgramItem> programs;
  bool loadOwnInvoices = false;
  bool tapInvoiceButton = false;
  Map<int, bool> checkedList = Map();
  int totalAmount = 0;
  bool creating = false;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
    programs = List();
    mInvoices = List();
    mPackages = List();
    super.initState();
    getOwnInvoices();
  }

  _afterLayout(_) {}

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${event.name}",
          maxLines: 1,
          overflow: TextOverflow.fade,
          style: TextStyle(color: Colors.white, fontSize: 15),
        ),
        backgroundColor: Color.fromARGB(255, 2, 24, 99),
      ),
      body: Column(children: [
        SizedBox(
          height: 20,
        ),
        // Container(child: Text('Төлбөрийн мэдээлэл', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: StaticData.blueLogo))),
        Container(
            margin: EdgeInsets.only(left: 30, right: 20),
            alignment: Alignment.center,
            child: Center(
                child: Text(
                    '(Та эвэнтийн багцуудаас сонгон, '
                    'НЭХЭМЖЛЭХ '
                    'үүсгэн '
                    'төлснөөр таны '
                    'бүртгэл '
                    'баталгаажна)',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: Colors.grey)))),
        SizedBox(
          height: 10,
        ),
        Container(
            margin: EdgeInsets.only(left: 30),
            alignment: Alignment.centerLeft,
            child: Text('Таны нэхэмжлэхүүд', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: StaticData.blueLogo))),
        drawOwnInvoices(),
        !tapInvoiceButton
            ? Container(
                margin: EdgeInsets.only(right: 40, top: 20),
                alignment: Alignment.centerRight,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
                  color: StaticData.yellowLogo,
                  child: Text("Нэхэмжлэх үүсгэх", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                  onPressed: () {
                    createInvoice();
                  },
                ))
            : drawCreateInvoice(),
        drawBody()
      ]),
    );
  }

  createInvoice() {
    setState(() {
      tapInvoiceButton = true;
    });
  }

  saveInvoice() async {
    Map<String, dynamic> params = {"packages": jsonEncode(checkedList.keys.toList()), "event": event.id};

    String url = StaticUrl.getEventInvoicesUrlwithDomain();
    dynamic res = await api.post(url, params: params);
    if (res['code'] == 1000) {
      if (res['data']['success']) {
        Invoice invoice = Invoice.fromJson(res['data']['invoice']);
        mInvoices.add(invoice);
        checkedList.clear();
        totalAmount = 0;

        setState(() {
          tapInvoiceButton = false;
        });
      } else {
        toast.show(res['data']['message']);
      }
    } else {
      toast.show(res['message']);
    }
  }

  deleteInvoice(invoice) async {
    Map<String, dynamic> params = {};
    String url = StaticUrl.getEventInvoicesUrlwithDomain() + '/' + invoice.id.toString();
    dynamic json = await api.delete(url);
    if (json['code'] == 1000) {
      toast.show('Амжилттай устгалаа.');
      setState(() {
        mInvoices.removeWhere((item) => item.id == invoice.id);
      });
    } else {
      toast.show(json['message']);
    }
  }

  Container drawOwnInvoices() {
    ///TODO: add to paid status on API
    List<Widget> invoices = List();

    mInvoices.forEach((element) {
      List<Widget> packages = List();
      element.packages.forEach((pack) {
        packages.add(Container(
            margin: EdgeInsets.only(left: 50, top: 5, right: 80),
            child: Row(
              children: [
                Expanded(child: Text(pack.name, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: StaticData.blueLogo))),
                Text(pack.amount.toString(), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: StaticData.blueLogo))
              ],
            )));
        packages.add(Container(
          height: 1,
        ));
      });
      invoices.add(Container(
          padding: EdgeInsets.only(right: 0, top: 20),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                      flex: 1, child: Text(element.invoiceNumber, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: StaticData.blueLogo))),
                  Text(element.amount.toString() + '₮', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: StaticData.blueLogo)),
                  SizedBox(
                    width: 20,
                  ),
                  element.paid
                      ? Container(
                          height: 20,
                          width: 50,
                        )
                      : SizedBox(
                          height: 20,
                          width: 45,
                          child: IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              // onPressed: deleteInvoice(element))
                              onPressed: () {
                                deleteInvoice(element);
                              }),
                        )
                ],
              ),
              Container(margin: EdgeInsets.only(left: 50), alignment: Alignment.centerLeft, child: Text('Багцууд:')),
              ListView.builder(
                  shrinkWrap: true,
                  itemCount: packages.length,
                  itemBuilder: (BuildContext ctxt, int index) {
                    return packages[index];
                  }),
              // ListView(
              //   shrinkWrap: true,
              //   children: packages,
              // ),
              // Column(
              //   children: packages,
              // ),
              Container(
                margin: EdgeInsets.only(top: 5),
                height: 1,
                color: Colors.grey,
              )
            ],
          )));
    });
    return mInvoices.length > 0
        ? Container(
            margin: EdgeInsets.only(left: 30, right: 30),
            child: ListView(
              shrinkWrap: true,
              children: invoices,
            ))
        : Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.only(top: 30, left: 30, right: 30),
            child: Text('Нэхэмжлэх үүсгээгүй байна. Та '
                'нэхэмжлэх үүсгэнэ үү'));
  }

  Container drawCreateInvoice() {
    getEventPackages();
    List<Widget> list = List();
    if (mPackages.length > 0) {
      list.add(Text('Багцуудаас сонгоно уу'));
      list.add(Container(
        height: 1,
        color: Colors.grey,
      ));
      list.add(SizedBox(
        height: 20,
      ));
      mPackages.forEach((element) {
        list.add(Row(
          children: [
            Expanded(flex: 5, child: Text(element.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
            Expanded(flex: 2, child: Text(element.amount.toString(), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
            Checkbox(
              value: checkedList[element.id] ?? false,
              onChanged: (val) => {toggleCheck(element, val)},
              activeColor: StaticData.blueLogo,
            )
          ],
        ));
      });
      list.add(totalAmount > 0
          ? Container(
              margin: EdgeInsets.only(right: 80),
              alignment: Alignment.centerRight,
              child: Text('НИЙТ:  ' + totalAmount.toString(), style: TextStyle(color: StaticData.blueLogo, fontSize: 16, fontWeight: FontWeight.w600)))
          : Container());
      list.add(totalAmount > 0
          ? Container(
              alignment: Alignment.centerRight,
              child: RaisedButton(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
                color: StaticData.yellowLogo,
                child: !creating
                    ? Text("Нэхэмжлэх үүсгэх", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500))
                    : Container(
                        width: 18,
                        height: 18, //contextHeight / 13 - 4,
                        child: CircularProgressIndicator(
                          strokeWidth: 1,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xffFFFFFF)),
                        )),
                onPressed: () {
                  saveInvoice();
                },
              ))
          : Container());
    }
    return Container(
        margin: EdgeInsets.only(top: 40, left: 40, right: 40),
        child: ListView(
          shrinkWrap: true,
          children: list,
        ));
  }

  toggleCheck(package, val) {
    if (val) {
      totalAmount += package.amount;
    } else {
      totalAmount -= package.amount;
    }
    ;
    setState(() {
      checkedList[package.id] = val;
    });
  }

  Container drawBody() {
    return new Container(
        // height: MediaQuery.of(context).size.height,
        margin: EdgeInsets.only(top: 20),
        child: Container());
  }

  Future<void> getOwnInvoices() async {
    mInvoices.clear();
    Map<String, dynamic> params = {"event": event.id};
    String url = StaticUrl.getEventInvoicesUrlwithDomain() + '/invoices';
    dynamic json = await api.post(url, params: params);
    if (json['code'] == 1000) {
      if (json['data']['success']) {
        List<dynamic> invoices = json['data']['list'];
        List<Invoice> invoiceList = List();
        invoices.forEach((element) {
          invoiceList.add(Invoice.fromJson(element));
        });
        setState(() {
          mInvoices.addAll(invoiceList);
        });
      } else {
        toast.show(json['data']['message']);
      }
    } else {
      toast.show(json['message']);
    }
  }

  Future<void> getEventPackages() async {
    if (mPackages.length > 0) {
      return;
    }
    Map<String, dynamic> params = {"eventId": event.id};
    String url = StaticUrl.getEventPackagesUrlwithDomain() + '/list';
    dynamic res = await api.get(url, params: params);
    if (res['code'] == 1000) {
      List<Package> packs = List();
      res['data'].forEach((e) {
        packs.add(Package.fromJson(e));
      });
      setState(() {
        mPackages.addAll(packs);
      });
    } else {
      toast.show(res['message']);
    }
  }
}

class Invoice {
  final int id;
  final int amount;
  final String invoiceNumber;
  final DateTime created_at;
  final List<dynamic> packages;
  bool paid = false;

  Invoice({this.id, this.amount, this.invoiceNumber, this.created_at, this.packages, this.paid});
  factory Invoice.fromJson(Map<String, dynamic> json) {
    List<Package> packs = List();
    (json['packages'] ?? []).forEach((p) => {packs.add(Package.fromJson(p))});
    return Invoice(
        id: json['id'] ?? 0,
        amount: json['amount'] ?? 0,
        invoiceNumber: json['invoice_number'] ?? '',
        created_at: DateTime.parse(json['created_at']) ?? DateTime.now(),
        packages: packs,
        paid: json['paid'] ?? false);
  }
}

class Package {
  int id;
  int amount;
  String name;
  String description;
  Package({this.id, this.amount, this.name, this.description});
  factory Package.fromJson(Map<String, dynamic> json) {
    return Package(id: json['id'] ?? 0, name: json['name'] ?? '', description: json['description'] ?? '', amount: json['amount'] ?? 0);
  }
  String toString() {
    return '{"id": ${this.id}, "amount":${this.amount}, "name":${this.name}, "description":${this.description}}';
  }
}
