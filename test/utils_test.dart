import 'dart:typed_data';

import 'package:echo/src/utils.dart';

import 'package:test/test.dart';
import 'package:xml/xml.dart' as xml;

void main() {
  // group('XHTML Attribute Validation Test', () {
  //   test('Must return valid attribute true', () {
  //     expect(Echotils.isAttributeValid('a', 'href'), isTrue);
  //     expect(Echotils.isAttributeValid('img', 'src'), isTrue);
  //     expect(Echotils.isAttributeValid('cite', 'style'), isTrue);
  //   });

  //   test('Must return invalid attribute false', () {
  //     expect(Echotils.isAttributeValid('a', 'class'), isFalse);
  //     expect(Echotils.isAttributeValid('img', 'href'), isFalse);
  //     expect(Echotils.isAttributeValid('cite', 'value'), isFalse);
  //   });
  // });

  // group('XHTML CSS Validation Test', () {
  //   test('Must return valid CSS true', () {
  //     final result = Echotils.isCSSValid('color: red');
  //     expect(result, isTrue);
  //   });
  //   test('Must return invalid CSS style false', () {
  //     final result = Echotils.isCSSValid('foo: 100%');
  //     expect(result, isFalse);
  //   });
  // });
  group(
    'XHTML Tag Validation Test',
    () => {
      test('Must return valid Tag true', () {
        final result = Echotils.isTagValid('img');
        expect(result, isTrue);
      }),
      test('Must return invalid Tag false', () {
        final result = Echotils.isTagValid('style');
        expect(result, isFalse);
      })
    },
  );

  group('XHTML xmlEscape Test', () {
    test('Must return true while valid replace escape', () {
      const text = 'This is a test <test> & testing "XML" escaping';
      const expected =
          'This is a test &lt;test&gt; &amp; testing &quot;XML&quot; escaping';
      final result = Echotils.xmlEscape(text);
      expect(result, equals(expected));
    });

    test('Must return valid output', () {
      const text = 'This is a &lt;tag&gt;';
      const expected = 'This is a &amp;lt;tag&amp;gt;';
      expect(Echotils.xmlEscape(text), expected);
    });
  });

  group('XHTML isTagEqual Test', () {
    test('Must return true if tags are equal', () {
      final element = xml.XmlElement(xml.XmlName('child1'));
      final result = Echotils.isTagEqual(element, 'child1');
      expect(result, isTrue);
    });
    test('Must return false if tags are different', () {
      final element = xml.XmlElement(xml.XmlName('tag'));
      final result = Echotils.isTagEqual(element, 'differentOne');
      expect(result, isFalse);
    });
  });

  group('XHTML getText Test', () {
    test('Must return valid text', () {
      final element =
          xml.XmlDocument.parse('<root>Text content</root>').rootElement;
      final result = Echotils.getText(element);
      expect(result, equals('Text content'));
    });

    test('Must return valid text', () {
      final element = xml.XmlDocument.parse(
        '<description>This is <b>bold</b> text.</description>',
      ).rootElement;
      final result = Echotils.getText(element);
      expect(result, 'This is bold text.');
    });
  });

  group('forEachChild Method Test', () {
    xml.XmlElement? element;

    setUp(
      () => {
        element = xml.XmlElement(xml.XmlName('test'), [], [
          xml.XmlElement(xml.XmlName('child1')),
          xml.XmlElement(xml.XmlName('child2')),
          xml.XmlElement(xml.XmlName('child3')),
        ])
      },
    );
    test('Without children must return 0', () {
      final element = xml.XmlElement(xml.XmlName('test'));
      int count = 0;
      Echotils.forEachChild(element, null, (node) => count++);
      expect(count, 0);
    });
    test('With children must return exact count of children', () {
      int count = 0;

      Echotils.forEachChild(element, null, (node) => count++);

      expect(count, 3);
    });

    test('With name filter must return exact count', () {
      int count = 0;
      Echotils.forEachChild(element, 'child3', (node) => count++);
      expect(count, 1);
    });

    test('With non-matching name but with children must return 0', () {
      int count = 0;
      Echotils.forEachChild(element, 'child4', (node) => count++);
      expect(count, 0);
    });
  });

  group('serialize', () {
    test('must return null if element is null', () {
      final result = Echotils.serialize(null);
      expect(result, isNull);
    });
    test('Must return correct serialization', () {
      final result = Echotils.serialize(xml.XmlElement(xml.XmlName('div')));
      expect(result, '<div/>');
    });

    test('Must return correct serialization with two attributes set', () {
      final element = xml.XmlElement(xml.XmlName('a'));
      element.setAttribute('href', 'https://example.com');
      element.setAttribute('target', '_blank');
      final result = Echotils.serialize(element);
      const expected = '<a href="https://example.com" target="_blank"/>';
      expect(result, expected);
    });

    test('Must return valid serialization when there is CDATA section', () {
      final document = xml.XmlDocument.parse(
        '<book><![CDATA[This is some <CDATA> content.]]></book>',
      );
      final result = Echotils.serialize(document.rootElement);
      const expected = '<book><![CDATA[This is some <CDATA> content.]]></book>';
      expect(result, expected);
    });
  });

  group('copyElement Method Test', () {
    test(
        'Must return correct deep copy if element copies with attributes and children',
        () {
      final element = xml.XmlElement(xml.XmlName('test'));
      element.setAttribute('attr1', 'value1');
      element.setAttribute('attr2', 'value2');
      element.children.add(xml.XmlElement(xml.XmlName('child1')));
      element.children.add(xml.XmlElement(xml.XmlName('child2')));

      /// Create a copy of the given XML
      final copy = Echotils.copyElement(element);

      expect((copy as xml.XmlElement).name.local, equals('test'));
      expect(copy.attributes.length, equals(2));
      expect(copy.getAttribute('attr2'), equals('value2'));
      expect((copy.children[0] as xml.XmlElement).name.local, equals('child1'));
    });

    test('Must return valid copy from provided xmlString', () {
      const xmlString =
          '<book id="123"><title>GPT-3.5</title><author>OpenAI</author></book>';
      final document = xml.XmlDocument.parse(xmlString);
      final originalElement = document.getElement('book');
      final copy = Echotils.copyElement(originalElement!);
      const expected =
          '<book id="123"><title>GPT-3.5</title><author>OpenAI</author></book>';
      expect(copy.toString(), expected);
    });

    test('Must return copied text element type correctly', () {
      final element = xml.XmlText('test');
      final copy = Echotils.copyElement(element);

      expect(copy.nodeType, equals(xml.XmlNodeType.TEXT));
    });

    test('Must throw an error for unsupported node type', () {
      final element = xml.XmlComment('test');
      expect(() => Echotils.copyElement(element), throwsArgumentError);
    });
  });

  group('xmlElement() Method Test', () {
    test('Must return correct text with valid inputs', () {
      final xmlNode = Echotils.xmlElement('test');
      expect(xmlNode.toString(), '<test/>');

      final xmlNodeWithAttr =
          Echotils.xmlElement('test', attributes: {'attr1': 'value1'});
      expect(xmlNodeWithAttr.toString(), '<test attr1="value1"/>');

      final xmlNodeWithMapAttr = Echotils.xmlElement(
        'test',
        attributes: {'attr1': 'value1'},
        text: 'Hello, blya!',
      );
      expect(
        xmlNodeWithMapAttr.toString(),
        '<test attr1="value1">Hello, blya!</test>',
      );
    });

    test('Must return null with invalid inputs', () {
      final xmlNode = Echotils.xmlElement('');
      expect(xmlNode, null);

      final xmlNodeWithAttr =
          Echotils.xmlElement('test', attributes: 'invalid');
      expect(xmlNodeWithAttr, null);
    });

    test('Must return valid output with element name and attributes', () {
      final element = Echotils.xmlElement(
        'book',
        attributes: {'author': 'Vsev', 'year': '2023'},
      );
      expect(Echotils.serialize(element), '<book author="Vsev" year="2023"/>');
    });
  });

  // group('xmlTextNode() Method Test', () {
  //   test('Must return a text node with the given text', () {
  //     final node = Echotils.xmlTextNode('Hello, blya!');
  //     expect(node.nodeType, equals(xml.XmlNodeType.TEXT));
  //     expect(node.children.length, equals(0));
  //     expect(node.children.first.root.innerText, equals('Hello, blya!'));
  //   });
  // });

  group('getBareJIDFromJID Method Test', () {
    test('Must return the bare JID when the JID contains a resource', () {
      const jid = 'user@example.com/resource';
      final result = Echotils().getBareJIDFromJID(jid);
      expect(result, 'user@example.com');
    });

    test('Must return the input JID when it does not contain a resource', () {
      const jid = 'user@example.com';
      final result = Echotils().getBareJIDFromJID(jid);
      expect(result, equals(jid));
    });

    test('Must return null when the input JID is an empty string', () {
      const jid = '';
      final result = Echotils().getBareJIDFromJID(jid);
      expect(result, isNull);
    });
  });

  group('getNodeFromJID Method Test', () {
    test('Must return node of the passed JID', () {
      const jid = 'user@example.com/resource';
      expect(Echotils().getNodeFromJID(jid), equals('user'));
    });

    test('Must return null if there is not any "@" sign', () {
      const jid = 'user';
      expect(Echotils().getNodeFromJID(jid), isNull);
    });

    test('Must return null from jid that contains "@" and whitespace', () {
      const jid = 'user ';
      expect(Echotils().getNodeFromJID(jid), isNull);
    });
  });

  group('getResourceFromJID Method Test', () {
    test('Must return resource from the given JID', () {
      const jid = 'user@example.com/resource';
      final result = Echotils().getResourceFromJID(jid);
      expect(result, equals('resource'));
    });
    test('Must return null if JID does not containing resource part', () {
      const jid = 'user@example.com';
      final result = Echotils().getResourceFromJID(jid);
      expect(result, isNull);
    });
  });

  group('getDomainFromJID Method Test', () {
    test('Must return domain for valid bare JID input', () {
      expect(Echotils().getDomainFromJID('example.com'), 'example.com');
      expect(Echotils().getDomainFromJID('jabber.org'), 'jabber.org');
    });

    test('must return domain for valid full JID input', () {
      expect(Echotils().getDomainFromJID('user@example.com'), 'example.com');
      expect(
        Echotils().getDomainFromJID('user@jabber.org/resource'),
        'jabber.org',
      );
    });
  });

  group('base64ToArrayBuffer Method Test', () {
    test('Must return a valid array buffer', () {
      const input = 'SGVsbG8gV29ybGQ=';
      final output = Echotils.base64ToArrayBuffer(input);
      expect(output, isA<Uint8List>());
    });

    test('Must return expected output', () {
      const input = 'YmFzZTY0IGlzIGEgdGVzdA==';
      final output = Echotils.base64ToArrayBuffer(input);
      expect(
        output,
        equals(
          Uint8List.fromList([
            98,
            97,
            115,
            101,
            54,
            52,
            32,
            105,
            115,
            32,
            97,
            32,
            116,
            101,
            115,
            116
          ]),
        ),
      );
    });
  });

  group('stringToArrayBuffer Method Test', () {
    test('Must return a buffer from a provided string', () {
      const value = 'Hello, world!';
      final result = Echotils.stringToArrayBuffer(value);
      expect(
        result,
        Uint8List.fromList(
          [72, 101, 108, 108, 111, 44, 32, 119, 111, 114, 108, 100, 33],
        ),
      );
    });
  });

  group('arrayBufferToBase64 Method Test', () {
    test('must return base64 from array buffer', () {
      final buffer = Uint8List.fromList([104, 101, 108, 108, 111]);
      final result = Echotils.arrayBufferToBase64(buffer);

      expect(result, equals('aGVsbG8='));
    });
  });

  group('escapeNode Method Test', () {
    test('Must return valid output when there is a space in the node', () {
      const node = 'Salam brat!';
      expect(Echotils.escapeNode(node), equals('Salam\\20brat!'));
    });

    test(
      'Must return valid output when there is a forward slash in the node',
      () {
        const node = 'Example / node';
        expect(Echotils.escapeNode(node), equals('Example\\20\\2f\\20node'));
      },
    );
  });

  group('btoa Method Test', () {
    test('Must return correct result based on input', () {
      const input = '12345';
      final result = Echotils.btoa(input);
      expect(result, 'MTIzNDU=');
    });

    test('Must return valid output when input is long text', () {
      const input =
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec a diam lectus. Sed sit amet ipsum mauris. Maecenas congue ligula ac quam viverra nec consectetur ante hendrerit.';
      final result = Echotils.btoa(input);
      const expected =
          'TG9yZW0gaXBzdW0gZG9sb3Igc2l0IGFtZXQsIGNvbnNlY3RldHVyIGFkaXBpc2NpbmcgZWxpdC4gRG9uZWMgYSBkaWFtIGxlY3R1cy4gU2VkIHNpdCBhbWV0IGlwc3VtIG1hdXJpcy4gTWFlY2VuYXMgY29uZ3VlIGxpZ3VsYSBhYyBxdWFtIHZpdmVycmEgbmVjIGNvbnNlY3RldHVyIGFudGUgaGVuZHJlcml0Lg==';
      expect(result, expected);
    });
  });
}
