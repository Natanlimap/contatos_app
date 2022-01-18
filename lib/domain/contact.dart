class Contact {
  static const String contactTable = "contactTable";
  static const String idColumn = "idColumn";
  static const String nameColumn = "nameColumn";
  static const String phoneColumn = "phoneColumn";
  static const String emailColumn = "emailColumn";
  static const String imgColumn = "imgColumn";

  int id = 0;
  String name = '';
  String email = '';
  String phone = '';
  String img = '';

  Contact();

  Contact.fromMap(Map map) {
    id = map[idColumn];
    name = map[nameColumn];
    email = map[emailColumn];
    phone = map[phoneColumn];
    img = map[imgColumn];
  }

  Map<String, Object?> toMap() {
    Map<String, Object?> map = {
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imgColumn: img
    };
    if (id != 0) map[idColumn] = id;

    return map;
  }

  @override
  String toString() {
    return "Contact(id: $id, name: $name, email: $email, phone: $phone, img: $img)";
  }
}
