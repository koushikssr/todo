class Task {
  int id;
  String name;

  Task({this.id, this.name});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name};
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(id: map['id'], name: map['name']);
  }
}
