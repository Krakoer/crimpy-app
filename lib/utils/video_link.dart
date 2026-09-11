// A coach types the demo video field by hand and nothing validates it on write,
// so what reaches the athlete is whatever they typed: an address, a sentence, or
// a scheme no browser should be handed. These read it without trusting it.

/// A dotted name ending in a letters-only suffix, or a dotted quad, each with an
/// optional port. This is what tells an address from a sentence: prose that
/// happens to contain a full stop is not host shaped, and neither is a scheme
/// with something after the colon that is not a port.
final RegExp _hostAndPort = RegExp(
  r'^(?:'
  r'[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?'
  r'(?:\.[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?)*'
  r'\.[A-Za-z]{2,}'
  r'|'
  r'(?:\d{1,3}\.){3}\d{1,3}'
  r')(?::\d{1,5})?$',
);

/// The url of a demo video, or null when the coach left the field empty or
/// filled it with something a browser cannot be sent to.
///
/// A link written without a scheme is read as https rather than dropped:
/// "www.youtube.com/watch?v=x" is what a coach types, and the field they type it
/// into does not make them add one.
Uri? videoLinkUri(String? link) {
  final trimmed = link?.trim() ?? '';
  if (trimmed.isEmpty) return null;
  // An address has no whitespace in it. A sentence does, and Uri would happily
  // percent-encode one into a host that resolves to nothing.
  if (trimmed.contains(RegExp(r'\s'))) return null;

  final lower = trimmed.toLowerCase();
  if (lower.startsWith('http://') || lower.startsWith('https://')) {
    final parsed = Uri.tryParse(trimmed);
    return (parsed == null || parsed.host.isEmpty) ? null : parsed;
  }

  // Anything else is only an address if what stands where the host would is
  // host shaped. Read that way rather than from what Uri calls the scheme,
  // because Dart's scheme grammar allows dots: "example.com:8080/v" parses with
  // a scheme of "example.com", and "javascript:alert(1)" has to be refused by
  // the same test that lets that one through.
  return _schemeless(trimmed);
}

Uri? _schemeless(String link) {
  final authority = link.split(RegExp(r'[/?#]')).first;
  if (!_hostAndPort.hasMatch(authority)) return null;
  final parsed = Uri.tryParse('https://$link');
  return (parsed == null || parsed.host.isEmpty) ? null : parsed;
}

/// Whether [link] is something a browser can be sent to.
bool isPlayableVideoLink(String? link) => videoLinkUri(link) != null;
