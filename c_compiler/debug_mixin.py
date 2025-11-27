from io import StringIO

class DebugMixin():
    """
    Extra functions for getting debug info when visiting a node
    """
    
    def get_source_snippet(self, node):
        """Get source code snippet for a node"""
        if not hasattr(node, 'coord') or not node.coord or not self.context.source_lines:
            return ""
        
        coord = node.coord
        if coord.line:
            line = self.context.source_lines[coord.line - 1].rstrip()
            return f"Source: {line}"
        return ""
    
    def get_debug(self, node):
        """
        Returns node info if debugging is enabled.
        """
        ret = ""
        f = StringIO(ret)
        print(self.get_source_snippet(node), file=f)
        node.show(buf=f, attrnames=True, nodenames=True, showcoord=True)
        ret = f.getvalue()
        f.close()
        return ret
