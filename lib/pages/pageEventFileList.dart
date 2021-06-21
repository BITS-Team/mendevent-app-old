import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mend_doctor/models/modEvent.dart';
import 'package:mend_doctor/models/modEventProgramItem.dart';
import 'package:mend_doctor/models/modUser.dart';
import 'package:mend_doctor/pages/pagePdfFile.dart';
import 'package:mend_doctor/singletons/singletonEvent.dart';
import 'package:mend_doctor/utils/fetchApi.dart';
import 'package:mend_doctor/utils/notificationFirebase.dart';
import 'package:mend_doctor/utils/staticData.dart' as sData;
import 'package:mend_doctor/utils/staticUrl.dart';
import 'package:mend_doctor/utils/toast.dart';
import 'package:path_provider/path_provider.dart';

class EventFilePage extends StatefulWidget {
  static const routeName = '/eventFilePage';
  final Event event;
  final User user;
  final List<EventProgramItem> programs;
  EventFilePage({Key key, @required this.event, @required this.user, this.programs}) : super(key: key);
  @override
  EventFilePageState createState() {
    // TODO: implement createState
    return EventFilePageState(event, user, programs);
  }
}

class EventFilePageState extends State<EventFilePage> {
  Event event;
  User user;
  List<EventProgramItem> programs;

  EventFilePageState(this.event, this.user, this.programs);

  List<EventFile> mFiles = List();
  Map<int, EventProgramItem> mapPrograms = Map();
  bool isShowFile = false;
  bool _loading = true;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
    getFileList();
    mapPrograms = Map.fromIterable(programs, key: (p) => p.id, value: (p)=> p);
    super.initState();
  }

  _afterLayout(_) {
  }

  @override
  Widget build(BuildContext context) {
//    final UserParams params = ModalRoute.of(context).settings.arguments;
    return Scaffold(
//      appBar: AppBar(
//        title: Text("${event.name.substring(0, 34)}", style: TextStyle(
//            color: Colors.white,
//            fontSize: 15
//        ),),
////        backgroundColor: Color.fromARGB(255, 253, 185, 46),
//        backgroundColor: Color.fromARGB(255, 2, 24, 99),
//      ),
        body: ListView(children: <Widget>[
      Image.asset('assets/header_top.png'),
      Container(
          alignment: Alignment.center,
          margin: EdgeInsets.only(bottom: 30, top: 30, left: 30, right: 30),
          child: Text(
            'Эвэнтэд холбоотой файлууд',
            style: TextStyle(
              color: Color(0xff021863),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          )),
      _loading
          ? Container(
              child: Column(children: <Widget>[
              Text(
                'Ачааллаж байна...',
                style: TextStyle(
                  color: sData.StaticData.blueLogo,
                  fontSize: 15,
                ),
              ),
              Container(
                  width: 50,
                  height: 50,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 1,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xff021863)),
                    ),
                  )),
            ]))
          : drawBody(mFiles),
    ])

//      drawBody(context, params)
        );
  }

  Column drawBody(List<EventFile> files) {
    List<Widget> lst = List<Widget>();
    int index = 1;
    for (EventFile ff in files) {
      lst.add(GestureDetector(
        onTap: () {
          setState(() {
            isShowFile = true;
          });
          createFileOfPdfUrl(ff).then((f) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PdfFilePageState(
                          event,
                          user,
                          ff.fileName,
                          f.path,
                        )));
            isShowFile = false;
          });
        },
        child: Container(
            margin: EdgeInsets.only(left: 30, right: 30, top: 5, bottom: 5),
            padding: EdgeInsets.only(left: 10, top: 20, right: 20, bottom: 20),
            decoration: BoxDecoration(
              color: Color(0x20000000),
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                        alignment: Alignment.centerRight,
                        margin: EdgeInsets.only(right: 20, bottom: 0),
                        width: 40,
                        child: Text(
                          '$index',
                          style: TextStyle(
                            color: sData.StaticData.blueLogo,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        )),
                    Expanded(
                      flex: 1,
                      child: Container(
                          margin: EdgeInsets.only(right: 20, bottom: 0),
                          alignment: Alignment.centerLeft,
                          width: 40,
                          child: Text(
                            '${ff.fileName}',
                            style: TextStyle(
                              color: sData.StaticData.blueLogo,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          )),
                    ),
                  ],
                ),
                ff.eventProgramId != 0
                    ? Container(
                        height: 1,
                        color: Color(0xff021863),
                        margin: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
                      )
                    : Container(),
                ff.eventProgramId != 0
                    ? Container(
                        padding: EdgeInsets.only(left: 20, right: 20),
                        child: Text(
//                        '${eventData.lstProgramsByEvent[event.id][ff.eventProgramId].title}',
                        '${mapPrograms[ff.eventProgramId].getOpenTime()} : ${mapPrograms[ff.eventProgramId].title}',
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          color: sData.StaticData.blueLogo,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ))
                    : Container(),
              ],
            )),

      ));

      index++;
    }
    if (lst.length == 0) {
      lst.add(Container(
          child: Text(
        'Холбоотой файлууд олдсонгүй...',
        style: TextStyle(
          color: sData.StaticData.blueLogo,
          fontSize: 15,
        ),
      )));
    }
    return !isShowFile
        ? Column(children: lst)
        : Column(children: <Widget>[
            Container(
                child: Center(
                    child: CircularProgressIndicator(
              strokeWidth: 1,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xff021863)),
            )))
          ]);
  }

  showMsg() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Уучлаарай!!"),
          content: new Text("Одоогоор татах боломжгүй байна.."),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<File> createFileOfPdfUrl(EventFile ff) async {
    final url = StaticUrl.getDomainPort() + ff.filePath;
    final filename = ff.fileName;
    String dir = (await getApplicationDocumentsDirectory()).path;

    if(FileSystemEntity.typeSync('$dir/$filename.pdf') == FileSystemEntityType.notFound){
      File file = new File('$dir/$filename.pdf');
      var request = await HttpClient().getUrl(Uri.parse(url));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
//    File file = new File('$dir/$filename.pdf');
      await file.writeAsBytes(bytes);
      return file;
    } else {
      File file = File('$dir/$filename.pdf');
      return file;
    }

  }

  Future<void> getFileList() async {
    mFiles.clear();
    Map<String, dynamic> params = {"event": event.id};
    String url = '${StaticUrl.getEventFilesUrlwithDomain()}/list';

    dynamic res = await api.get(url, params: params);
    if(res['code'] == 1000){
      res['data'].forEach((item) {
        mFiles.add(EventFile.fromJson(item));
      });
      setState(() {
        _loading = false;
      });
    } else {
      toast.show(res['message']);
    }
  }
}

class EventFile {
  final int id;
  final String fileName;
  final String fileDesc;
  final bool isDownloadable;
  final int eventId;
  final int eventProgramId;
  final String filePath;

  EventFile(
      {this.id, this.fileName, this.fileDesc, this.isDownloadable, this.eventId, this.eventProgramId, this.filePath});
  factory EventFile.fromJson(Map<String, dynamic> json) {
    return EventFile(
        id: json.containsKey('id') && json['id'] != null ? json['id'] : 0,
        fileName: json.containsKey('name') && json['name'] != null ? json['name'] : 'filename',
        fileDesc: json.containsKey('description') && json['description'] != null ? json['description'] : '',
        isDownloadable: json.containsKey('downloadable') && json['downloadable'] != null ? json['downloadable'] : false,
        eventId: json.containsKey('event') && json['event'] != null ? json['event'] : 0,
        eventProgramId:
            json.containsKey('event_program') && json['event_program'] != null ? json['event_program'] : 0,
        filePath: json.containsKey('file') && json['file'] != null ? json['file'] : '');
  }
}
