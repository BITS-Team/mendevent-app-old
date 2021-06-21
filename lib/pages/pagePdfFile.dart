import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_full_pdf_viewer/full_pdf_viewer_scaffold.dart';
import 'package:mend_doctor/models/modEvent.dart';
import 'package:mend_doctor/models/modUser.dart';

//class PdfFilePage extends StatefulWidget {
//  static const routeName = '/eventFilePage';
//  final Event event;
//  final User user;
//  final String fileName;
//  final String filePath;
//  PdfFilePage({Key key, @required this.event, @required this.user, @required this.fileName, this.filePath}) : super(key: key);
//  @override
//  PdfFilePageState createState() {
//    // TODO: implement createState
//    return PdfFilePageState(event, user, fileName, filePath);
//  }
//}

//class PdfFilePageState extends State<PdfFilePage> {
class PdfFilePageState extends StatelessWidget {
  final Event event;
  final User user;
  final String fileName;
  final String filePath;
  PdfFilePageState(this.event, this.user, this.fileName, this.filePath);

//  @override
//  void initState() {
//    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
//    super.initState();
//
//  }
//
//  _afterLayout(_) {
//  }

  @override
  Widget build(BuildContext context) {
//    final UserParams params = ModalRoute.of(context).settings.arguments;
    return PDFViewerScaffold(
        appBar: AppBar(
          title: Container(
            child: Text('$fileName',
              maxLines: 1,
              softWrap: false,

              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,

              ),
            ),
          ) ,

            backgroundColor: Color(0xff021863),
//          actions: <Widget>[
//            IconButton(
//              icon: Icon(Icons.share),
//              onPressed: () {},
//            ),
//          ],
        ),
        path: '$filePath');
  }

//  Future<File> createFileOfPdfUrl(EventFile ff) async {
//    final url = StaticUrl.getDomain() + ff.filePath;
//    final filename = ff.fileName;
//    var request = await HttpClient().getUrl(Uri.parse(url));
//    var response = await request.close();
//    var bytes = await consolidateHttpClientResponseBytes(response);
//    String dir = (await getApplicationDocumentsDirectory()).path;
//    File file = new File('$dir/$filename');
//    await file.writeAsBytes(bytes);
//    return file;
//  }

}

