from xml.sax.saxutils import escape
from typing import Union, List, Tuple, Any

AST_Element = Union[str, Tuple[str, Any, ...], List[Any]]


def convert_ast_to_xml(ast: AST_Element) -> str:
    """
    Recursively converts a Structured Text (ST) Abstract Syntax Tree (AST)
    represented by tuples and strings into a basic XML string.

    The conversion logic is as follows:
    1. String: Escapes special characters and returns as XML content.
    2. Tuple: Interpreted as an XML element, where the first element is the
       tag name (underscores replaced by hyphens) and subsequent elements are children.
    3. Other Iterable (e.g., List): Interpreted as a sequence of sibling
       elements, which are processed sequentially.

    Args:
        ast: The AST element to convert. Can be a string (content), a tuple
             (XML element/node), or an iterable (list of sibling elements).

    Returns:
        The resulting XML fragment as a string.
    """
    # 1. Handle String (Content)
    if isinstance(ast, str):
        # Escape special characters (<, >, &, ", ') for safe inclusion in XML
        return escape(ast)

    # 2. Handle Tuple (XML Element/Node)
    if isinstance(ast, tuple):
        # The first element is the tag name. Replace underscores with hyphens.
        tag_name = ast[0].replace("_", "-")
        result = "<" + tag_name + ">"

        # Recursively process children (elements after the tag name)
        for child in ast[1:]:
            result += convert_ast_to_xml(child)

        # Close the XML element
        result += "</" + tag_name + ">"
        return result

    # 3. Handle Other Iterable (Sibling Container, e.g., List)
    else:
        result = ""
        for sibling_element in ast:
            result += convert_ast_to_xml(sibling_element)
        return result
