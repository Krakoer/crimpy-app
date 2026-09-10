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
