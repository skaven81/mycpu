"""Undo/redo: CellEditCommand restores exact state, redo clears, depth caps."""

from studio.model.cell import Cell
from studio.model.document import Document
from studio.model.history import CellEditCommand, History
from studio.model.layers import BlankLayer


def _doc_with_one_layer():
    doc = Document()
    doc.add_layer(BlankLayer(name="L"))
    return doc


def test_cell_edit_command_do_undo_redo():
    doc = _doc_with_one_layer()
    layer = doc.layers[0]
    layer.set_local(1, 1, Cell(ord("a"), 0x01))  # pre-existing cell

    changes = {
        (0, 0): (None, Cell(ord("X"), 0x30)),          # create
        (1, 1): (Cell(ord("a"), 0x01), Cell(ord("b"), 0x02)),  # modify
        (2, 2): (None, Cell(ord("Z"), 0x0C)),          # create
    }
    hist = History(doc)
    hist.push(CellEditCommand(0, changes))

    assert layer.get_local(0, 0) == Cell(ord("X"), 0x30)
    assert layer.get_local(1, 1) == Cell(ord("b"), 0x02)
    assert layer.get_local(2, 2) == Cell(ord("Z"), 0x0C)

    assert hist.undo()
    assert layer.get_local(0, 0) is None
    assert layer.get_local(1, 1) == Cell(ord("a"), 0x01)
    assert layer.get_local(2, 2) is None

    assert hist.redo()
    assert layer.get_local(0, 0) == Cell(ord("X"), 0x30)
    assert layer.get_local(1, 1) == Cell(ord("b"), 0x02)


def test_redo_stack_cleared_on_new_push():
    doc = _doc_with_one_layer()
    hist = History(doc)
    hist.push(CellEditCommand(0, {(0, 0): (None, Cell(1, 1))}))
    hist.push(CellEditCommand(0, {(1, 0): (None, Cell(2, 2))}))
    hist.undo()
    assert hist.can_redo()
    hist.push(CellEditCommand(0, {(2, 0): (None, Cell(3, 3))}))
    assert not hist.can_redo()
    assert not hist.redo()


def test_can_undo_can_redo_and_clear():
    doc = _doc_with_one_layer()
    hist = History(doc)
    assert not hist.can_undo() and not hist.can_redo()
    hist.push(CellEditCommand(0, {(0, 0): (None, Cell(1, 1))}))
    assert hist.can_undo()
    hist.undo()
    assert hist.can_redo() and not hist.can_undo()
    hist.clear()
    assert not hist.can_undo() and not hist.can_redo()


def test_undo_on_empty_returns_false():
    hist = History(_doc_with_one_layer())
    assert hist.undo() is False
    assert hist.redo() is False


def test_depth_cap_respected():
    doc = _doc_with_one_layer()
    hist = History(doc, depth=5)
    for i in range(20):
        hist.push(CellEditCommand(0, {(i, 0): (None, Cell(i % 256, 0))}))
    assert len(hist._undo) == 5
    # only the last 5 pushes remain undoable
    undone = 0
    while hist.undo():
        undone += 1
    assert undone == 5


def test_history_without_doc_uses_call_arg():
    doc = _doc_with_one_layer()
    hist = History()  # no bound doc
    hist.push(CellEditCommand(0, {(0, 0): (None, Cell(9, 9))}), doc=doc)
    assert doc.layers[0].get_local(0, 0) == Cell(9, 9)
    hist.undo(doc=doc)
    assert doc.layers[0].get_local(0, 0) is None
