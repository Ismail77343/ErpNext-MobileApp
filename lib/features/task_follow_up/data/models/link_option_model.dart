import '../../domain/entities/link_option.dart';

class LinkOptionModel extends LinkOption {
  const LinkOptionModel({
    required super.value,
    required super.label,
    super.description,
  });

  factory LinkOptionModel.fromDynamic(dynamic raw) {
    if (raw is String) return LinkOptionModel(value: raw, label: raw);
    if (raw is Map<String, dynamic>) {
      final value =
          raw['value']?.toString() ??
          raw['name']?.toString() ??
          raw['id']?.toString() ??
          '';
      final label =
          raw['label']?.toString() ??
          raw['description']?.toString() ??
          raw['value']?.toString() ??
          value;
      return LinkOptionModel(
        value: value,
        label: label,
        description: raw['description']?.toString() ?? '',
      );
    }
    final value = raw?.toString() ?? '';
    return LinkOptionModel(value: value, label: value);
  }
}
