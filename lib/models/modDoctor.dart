class Doctor {
  final int id;
  final String firstName;
  final String lastName;
  final String description;
  final String registerNumber;
  final String licenseNumber;
  final bool isActive;
  final String title;
  final int workYear;
  final String avatarUrl;
  final List universities;
  final String hospital;
  final List professions;
  String token;

  Doctor({this.id, this.firstName, this.lastName, this.description, this.registerNumber, this.licenseNumber,
      this.isActive, this.title, this.workYear,
      this.avatarUrl, this.universities, this.hospital, this.professions});

  factory Doctor.fromJson(Map<String, dynamic> json){
    return Doctor(
      id: json['id'],
      firstName : json.containsKey('firstname') && json['firstname'] != null ? json['firstname'] : '',
      lastName: json.containsKey('lastname') && json['lastname'] != null ? json['lastname'] : '',
      description: json.containsKey('description') && json['description'] != null ? json['description'] : '',
      registerNumber: json.containsKey('register_number') && json['register_number'] != null ? json['register_number'] : '',
      licenseNumber: json.containsKey('license_number') && json['license_number'] != null ? json['license_number'] : '',
      isActive: json.containsKey('active') && json['active'] != null ? json['active'] : false,
      title: json.containsKey('title') && json['title'] != null ? json['title'] : '',
      workYear: json.containsKey('work_year') && json['work_year'] != null ? json['work_year'] : -1,
      avatarUrl: json.containsKey('avatar') ? json['avatar']['url'] : '',
      universities: [],
      hospital: '', //json.containsKey('hospital') && json['hospital'] != null ? json['hospital'] : '',
      professions: []
    );
  }

  void setToken(String token){
    this.token = token;
  }

  String getToken(){
    return this.token;
  }

  bool hasPic(){
    return avatarUrl != '';
  }

}