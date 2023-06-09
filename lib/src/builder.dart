import 'package:echo/src/constants.dart';
import 'package:echo/src/utils.dart';

import 'package:xml/xml.dart' as xml;

/// This class represents a builder for creating XML elements using [Echotils]
/// helper methods. It provides methods for constructing the XML tree and
/// manipulating the current node.
class EchoBuilder {
  /// Creates a new instance of the [EchoBuilder] class with the given name
  /// and optional attributes.
  EchoBuilder(
    /// [String] representation of the name of an XML element that is being
    /// constructed by the builder.
    this.name, [
    /// [Map] representation of attribute key-value pairs for the XML element
    /// being constructed.
    this.attributes,
  ]) {
    /// Sets correct namespace for jabber:client elements.
    if (name == 'presence' || name == 'message' || name == 'iq') {
      if (attributes != null && attributes!['xmlns'] == null) {
        attributes!['xmlns'] = ns['CLIENT'];
      } else {
        attributes ??= {'xmlns': ns['CLIENT']};
      }
    }

    /// Holds the tree being built.
    nodeTree = Echotils.xmlElement(name, attributes: attributes);

    /// Points to the current operation node.
    _node = nodeTree;
  }

  /// Creates an [EchoBuilder] with a <message/> element as the root.
  factory EchoBuilder.message({Map<String, dynamic>? attributes}) =>
      EchoBuilder('message', attributes);

  /// Creates an [EchoBuilder] with an <iq/> element as the root.
  factory EchoBuilder.iq({Map<String, dynamic>? attributes}) =>
      EchoBuilder('iq', attributes);

  /// Creates an [EchoBuilder] with a <presence/> element as the root.
  factory EchoBuilder.pres({Map<String, dynamic>? attributes}) =>
      EchoBuilder('presence', attributes);

  /// [String] representation of the name of an XML element that is being
  /// constructed by the builder.
  final String name;

  /// [Map] representation of attribute key-value pairs for the XML element
  /// being constructed.
  Map<String, dynamic>? attributes;

  xml.XmlElement? nodeTree;
  xml.XmlNode? _node;

  /// This function returns a String serialiation of the current DOM tree. It is
  /// often used internally to pass data to a Request object.
  @override
  String toString() => Echotils.serialize(nodeTree)!;

  /// Sets the current node to its parent node.
  ///
  /// * @return [EchoBuilder] object;
  EchoBuilder up() {
    _node = _node!.parent;
    return this;
  }

  /// Sets the current node to the root node.
  void root() => _node = nodeTree;

  /// Allows for adding or modifying the attributes of the current element.
  /// It takes a [Map] of key-value pairs as an argument, which are iterated
  /// over, and each attribute is either added or modified in the current
  /// element based on whether the key exists or not in the Map.
  ///
  /// * @return [EchoBuilder] object.
  EchoBuilder addAttributes(Map<String, String> attributes) {
    /// Iterates all attribute in the attributes [Map].
    for (final attribute in attributes.keys) {
      /// Checks if attributes contain key for verification.
      if (attributes.containsKey(attribute)) {
        if (attributes[attribute] == null) {
          /// If null, then remove attribute from node.
          _node!.removeAttribute(attribute);
        } else {
          _node!.setAttribute(attribute, attributes[attribute].toString());
        }
      }
    }
    return this;
  }

  /// Adds a child element to the current element being built. It takes the
  /// child element's name as the first argument and an optional `attributes`
  /// Map and `text` string.
  ///
  /// * @return [EchoBuilder] object.
  EchoBuilder c(
    String name, {
    Map<String, String>? attributes,
    String? text,
  }) {
    /// Creates child using `Echotils.xmlElement`.
    final child = Echotils.xmlElement(name, attributes: attributes, text: text);

    /// Add created child to nodes.
    _node!.children.add(child!);
    if (text.runtimeType != String) {
      _node = child;
    }
    return this;
  }

  /// This method is similar to the method of `c` method, but instead of
  /// passing the name and attributes, it takes an existing `xml.XmlElement`
  /// object and adds it as a child to the current element being built.
  ///
  /// * @return [EchoBuilder] object.
  EchoBuilder cnode(xml.XmlElement element) {
    final node = Echotils.copyElement(element);
    _node!.children.add(node);
    _node = node;
    return this;
  }

  /// Add a child text element.
  ///
  /// This does not make the child the new current element since there are no
  /// children of text elements.
  ///
  /// * @return [EchoBuilder] object.
  EchoBuilder t(String text) {
    /// Create text node.
    final child = Echotils.xmlTextNode(text);

    /// Add created text node to current nodes.
    _node!.children.add(child);
    return this;
  }
}
