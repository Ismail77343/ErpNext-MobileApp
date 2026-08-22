class LinkOption {
  final String value;
  final String label;
  final String description;

  const LinkOption({
    required this.value,
    required this.label,
    this.description = '',
  });
}
