class Appointment {
  final int id;
  final String name;
  final DateTime appointmentDate;
  final DateTime appointmentTime;
  final bool isActive;
  final int doctorId;
  final int patientId;
  final DateTime bookingDate;
  final bool isPaid;
  final int ehrId;
  final String uzlegType;
  Appointment(
      {this.id,
      this.name,
      this.bookingDate,
      this.appointmentDate,
          this.appointmentTime,
      this.isActive,
      this.doctorId,
      this.patientId,
      this.isPaid,
      this.ehrId,
      this.uzlegType});
  factory Appointment.fromJson(Map<String, dynamic> json) {
    final _doctor = json['doctor'];
    final _patient = json['patient'];
    final _ehr = json['ehr'];
    print(_patient['id']);
//    print(_ehr['id']);
    return new Appointment(
        id: json['id'],
        name: json['name'],
        bookingDate: DateTime.parse(json['appt_date']),
        appointmentDate: DateTime.parse(json['appointment_date']),
        appointmentTime: DateTime.parse(json['appointment_time']),
        isActive: json['active'],
        doctorId: _doctor['id'],
        patientId: _patient['id'],
        isPaid: json['paid'],
        ehrId: _ehr==null ? -1 : _ehr['id'],
        uzlegType: json['uzleg_type']
    );
  }
}
