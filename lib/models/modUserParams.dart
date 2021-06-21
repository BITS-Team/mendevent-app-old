class UserParams{
  final String token;
  final int doctorId;
  final String name;

  UserParams(this.token, this.doctorId, this.name);

  getToken(){
    return this.token;
  }
}