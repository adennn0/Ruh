/// A deterministic 31-bit hash for seeds persisted or compared across runs.
/// Dart's Object.hash is intentionally not stable between program executions.
int stableHashParts(Iterable<Object?> parts) {
  final value = parts.map((part) => part?.toString() ?? '').join('\u001f');
  var hash = 0x811c9dc5;
  for (final unit in value.codeUnits) {
    hash = ((hash ^ unit) * 0x01000193) & 0x7fffffff;
  }
  return hash;
}
