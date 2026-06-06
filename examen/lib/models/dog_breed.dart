class DogBreed {
  final int? id;
  final String name;
  final String origin;
  final String size;
  final int lifeExpectancy;
  final String description;

  const DogBreed({
    this.id,
    required this.name,
    required this.origin,
    required this.size,
    required this.lifeExpectancy,
    required this.description,
  });

  DogBreed copyWith({
    int? id,
    String? name,
    String? origin,
    String? size,
    int? lifeExpectancy,
    String? description,
  }) {
    return DogBreed(
      id: id ?? this.id,
      name: name ?? this.name,
      origin: origin ?? this.origin,
      size: size ?? this.size,
      lifeExpectancy: lifeExpectancy ?? this.lifeExpectancy,
      description: description ?? this.description,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'origin': origin,
      'size': size,
      'lifeExpectancy': lifeExpectancy,
      'description': description,
    };
  }

  factory DogBreed.fromMap(Map<String, Object?> map) {
    return DogBreed(
      id: map['id'] as int?,
      name: (map['name'] ?? '') as String,
      origin: (map['origin'] ?? '') as String,
      size: (map['size'] ?? '') as String,
      lifeExpectancy: (map['lifeExpectancy'] ?? 0) as int,
      description: (map['description'] ?? '') as String,
    );
  }

  @override
  String toString() {
    return 'DogBreed(id: $id, name: $name, origin: $origin, size: $size, '
        'lifeExpectancy: $lifeExpectancy, description: $description)';
  }
}
