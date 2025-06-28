class Medication {
  final String id;
  final String name;
  final String dosage;
  final String frequency; // daily, weekly, as_needed
  final List<String> times; // ["08:00", "20:00"] for time-based
  final String? notes;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final String? doctorName;
  final String type; // pill, liquid, injection, etc.

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.times,
    this.notes,
    required this.startDate,
    this.endDate,
    this.isActive = true,
    this.doctorName,
    this.type = 'pill',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'times': times,
      'notes': notes,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isActive': isActive,
      'doctorName': doctorName,
      'type': type,
    };
  }

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      dosage: json['dosage'] ?? '',
      frequency: json['frequency'] ?? 'daily',
      times: List<String>.from(json['times'] ?? []),
      notes: json['notes'],
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      isActive: json['isActive'] ?? true,
      doctorName: json['doctorName'],
      type: json['type'] ?? 'pill',
    );
  }

  Medication copyWith({
    String? id,
    String? name,
    String? dosage,
    String? frequency,
    List<String>? times,
    String? notes,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    String? doctorName,
    String? type,
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      times: times ?? this.times,
      notes: notes ?? this.notes,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      doctorName: doctorName ?? this.doctorName,
      type: type ?? this.type,
    );
  }
}

class MedicationLog {
  final String id;
  final String medicationId;
  final DateTime takenAt;
  final bool wasTaken;
  final String? notes;
  final String? missedReason;

  MedicationLog({
    required this.id,
    required this.medicationId,
    required this.takenAt,
    required this.wasTaken,
    this.notes,
    this.missedReason,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicationId': medicationId,
      'takenAt': takenAt.toIso8601String(),
      'wasTaken': wasTaken,
      'notes': notes,
      'missedReason': missedReason,
    };
  }

  factory MedicationLog.fromJson(Map<String, dynamic> json) {
    return MedicationLog(
      id: json['id'] ?? '',
      medicationId: json['medicationId'] ?? '',
      takenAt: DateTime.parse(json['takenAt']),
      wasTaken: json['wasTaken'] ?? false,
      notes: json['notes'],
      missedReason: json['missedReason'],
    );
  }
}
