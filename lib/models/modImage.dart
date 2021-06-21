import 'package:mend_doctor/sqliteHelper/databaseHelper.dart';
import 'package:sqflite/sqflite.dart';

class ImageMorph {
  final String relatedType;
  final int relatedId;
  final String field;
  final String imgPath;

  int tableId;
  ImageMorph({
    this.relatedType,
    this.relatedId,
    this.field,
    this.imgPath
  });


  /// SQLite helper

  Map<String, dynamic> toMap(){
    var map = <String, dynamic> {
      'related_type': this.relatedType,
      'related_id': this.relatedId,
      'field': this.field,
      'img_path': this.imgPath
    };
    return map;
  }
  factory ImageMorph.fromMap(Map<String, dynamic> map){
    return ImageMorph(
      relatedType: map['related_type'],
      relatedId: map['related_id'],
      field: map['field'],
      imgPath: map['img_path'],
    );
  }
  Future<ImageMorph> insert(ImageMorph image) async {
    Database db = await SQLiteHelper.instance.getDb();
    image.tableId = await db.insert('images', image.toMap());
    return image;
  }

}