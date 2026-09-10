// A coach types the demo video field by hand, so what reaches the athlete is
// whatever they typed. These read it without trusting it.

/// The url of a demo video, or null when the coach left the field empty or
/// filled it with something a browser cannot be sent to.
///
/// A link written without a scheme is read as https rather than dropped:
/// "www.youtube.com/watch?v=x" is what a coach types, and the field they type
/// it into does not make them add one.
Uri? videoLinkUri(String? link) {
  final trimmed = link?.trim() ?? '';
  if (trimmed.isEmpty) return null;

  final parsed = Uri.tryParse(trimmed);
  if (parsed == null) return null;
  if (parsed.scheme.isEmpty) return _schemeless(trimmed);
  if (parsed.scheme != 'http' && parsed.scheme != 'https') return null;
  return parsed.host.isEmpty ? null : parsed;
}

/// Reads a link with no scheme as https, but only when what stands where the
/// host would is actually host shaped. Without that check every stray sentence
/// in the field would become a url nothing can open.
Uri? _schemeless(String link) {
  final host = link.split('/').first.split('?').first;
  if (!host.contains('.') || host.startsWith('.') || host.endsWith('.')) {
    return null;
  }
  final parsed = Uri.tryParse('https://$link');
  return (parsed == null || parsed.host.isEmpty) ? null : parsed;
}

/// Whether [link] is something a browser can be sent to.
bool isPlayableVideoLink(String? link) => videoLinkUri(link) != null;
