import 'package:mend_doctor/models/modAppointment.dart';

class AppointmentsList {
  final List<Appointment> appointments;

  AppointmentsList({this.appointments});

  factory AppointmentsList.fromJson(List<dynamic> json) {
//    print(json);
    List<Appointment> _appointments = new List<Appointment>();
    print(json);
    print(json.length);

//    for(int i =0; i < json.length; i++){
//      print(json[i]);
//      try {
//        Appointment appo = Appointment.fromJson(json[i]);
//        _appointments.add(appo);
//      } catch (e){
//        print(e);
//    }
//
//
//    }

    try {
      _appointments = json.map((i) => Appointment.fromJson(i)).toList();
    } catch (e){
      print(e);
    }
    print('length = ' + _appointments.length.toString());
//    for (int i = 0; i < _appointments.length; i++) {
//      print(_appointments[i].name);
//    }
    return new AppointmentsList(appointments: _appointments);
  }
}
