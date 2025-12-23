class Task {
  final int? id;
  final String title;
  final String description;
  final String category; // 'Travail', 'Personnel', 'Urgent'
  final bool completed;
  final DateTime createdAt;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    this.completed = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convertir Task en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'completed': completed ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Créer Task depuis Map
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      category: map['category'],
      completed: map['completed'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  // Créer une copie avec modifications
  Task copyWith({
    int? id,
    String? title,
    String? description,
    String? category,
    bool? completed,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}