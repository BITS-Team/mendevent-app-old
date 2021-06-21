class User {
  final int id;
  final String email;
  final String name;
  final String provider;
  final bool confirmed;
  final bool blocked;
  final int roleId;
  final int relatedId;

  String tmpPass;

  User(
      {
        this.email,
        this.id,
        this.name,
        this.provider,
        this.confirmed,
        this.blocked,
        this.roleId,
        this.relatedId,
      });

  factory User.fromJson(Map<String, dynamic> json) {
    final role = json.containsKey('role') ? json['role'] : null;

    return User(
        id: json['id'] ?? 0,
        email: json['email'] ?? '',
        name: json['username'] ?? '',
        provider: json['provider'] ?? '',
        confirmed: json['confirmed'] ?? false,
        blocked: json['blocked'] ?? false,
        roleId: role != null ? role['id'] : 0,
        relatedId: json.containsKey('related_id') ? json['related_id'] : 0
    );
  }

  Map<String, dynamic> toJson() => {
     'id': this.id,
     'email' : this.email,
     'name' : this.name,
     'provider': this.provider,
     'confirmed': this.confirmed,
     'blocked': this.blocked,
     'roleId' : this.roleId,
     'relatedId' : this.relatedId
  };

  void setPassword(String pass) {
    this.tmpPass = pass;
  }

  String getPassword() {
    return this.tmpPass;
  }
}