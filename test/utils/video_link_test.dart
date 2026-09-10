import 'package:crimpy/utils/video_link.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('videoLinkUri', () {
    test('takes an http and an https address', () {
      expect(
        videoLinkUri('https://example.com/pull-up').toString(),
        'https://example.com/pull-up',
      );
      expect(
        videoLinkUri('http://example.com/pull-up').toString(),
        'http://example.com/pull-up',
      );
    });

    test('trims what the coach typed', () {
      expect(
        videoLinkUri('  https://example.com/x  ').toString(),
        'https://example.com/x',
      );
    });

    // What a coach actually types: the field they type it into is not a form,
    // so nothing makes them write the scheme.
    test('reads a scheme-less address as https', () {
      expect(
        videoLinkUri('www.youtube.com/watch?v=abc').toString(),
        'https://www.youtube.com/watch?v=abc',
      );
      expect(videoLinkUri('youtu.be/abc').toString(), 'https://youtu.be/abc');
    });

    test('refuses prose, which is not an address missing its scheme', () {
      expect(videoLinkUri('ask me for the video'), isNull);
      expect(videoLinkUri('see the whiteboard'), isNull);
    });

    // The guard's real boundary: a sentence with a full stop in it is still a
    // sentence. Read as a host it percent-encodes into something that resolves
    // to nothing, and the athlete gets a WATCH DEMO onto a DNS error.
    test('refuses prose that happens to contain a full stop', () {
      expect(videoLinkUri('Ask me. I will show you'), isNull);
      expect(videoLinkUri('Voir la video sur mon tel. Demande moi'), isNull);
      expect(videoLinkUri('3 series de 10. Cf. la video'), isNull);
      expect(videoLinkUri('e.g. slowly'), isNull);
    });

    test('takes a scheme-less address that carries a port', () {
      expect(
        videoLinkUri('example.com:8080/v').toString(),
        'https://example.com:8080/v',
      );
      expect(
        videoLinkUri('192.168.1.5:8080/demo.mp4').toString(),
        'https://192.168.1.5:8080/demo.mp4',
      );
    });

    // The scheme-less path must not become a way back in for the schemes the
    // http check above refuses: Dart parses "javascript:alert(1)" as a scheme,
    // but it is the host shape test that has to reject it.
    test('refuses an obfuscated scheme through the scheme-less path', () {
      expect(videoLinkUri('javascript:void(0)//example.com/x'), isNull);
      expect(videoLinkUri('//evil.com/x'), isNull);
      expect(videoLinkUri('intent://example.com/x'), isNull);
      expect(videoLinkUri('data:text/html,<script>alert(1)</script>'), isNull);
    });

    test('keeps the case of a path, so a video id survives', () {
      expect(
        videoLinkUri('youtu.be/dQw4w9WgXcQ').toString(),
        'https://youtu.be/dQw4w9WgXcQ',
      );
    });

    test('refuses a host shaped like one but malformed', () {
      expect(videoLinkUri('.com/x'), isNull);
      expect(videoLinkUri('example./x'), isNull);
    });

    test('refuses a scheme a browser should not be handed', () {
      expect(videoLinkUri('javascript:alert(1)'), isNull);
      expect(videoLinkUri('file:///etc/passwd'), isNull);
      expect(videoLinkUri('mailto:coach@example.com'), isNull);
    });

    test('refuses an empty or missing link', () {
      expect(videoLinkUri(null), isNull);
      expect(videoLinkUri(''), isNull);
      expect(videoLinkUri('   '), isNull);
    });

    test('refuses an http address with no host', () {
      expect(videoLinkUri('https://'), isNull);
    });
  });

  test('isPlayableVideoLink answers what videoLinkUri could read', () {
    expect(isPlayableVideoLink('https://example.com/x'), isTrue);
    expect(isPlayableVideoLink('www.example.com/x'), isTrue);
    expect(isPlayableVideoLink('ask the coach'), isFalse);
    expect(isPlayableVideoLink(null), isFalse);
  });
}
