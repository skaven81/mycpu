"""
Gradient: drag a vector; color ramps from the current ink at the start point
to `end_attr` at the end point, projected onto the drag direction.

Two behaviors (Ctrl toggles):
  * recolor -- change the color of existing cells in the drag's bounding box,
    keeping each glyph (the default; great for shading a title bar or a panel).
  * fill     -- stamp the current glyph across the box with the ramp color.

Blending is done in RGB level space and re-quantised to the nearest Odyssey
color, so the result bands across the four channel levels.  The BLINK bit of
the start ink is carried onto every cell.
"""

from studio.model.cell import Cell
from studio.model.palette import attr_to_rgb, rgb_to_odyssey
from studio.tools.base import MOD_CTRL, ShapeTool


class GradientTool(ShapeTool):
    key = "gradient"
    label = "Gradient"

    def __init__(self, fill=False, end_attr=0x00):
        super().__init__()
        self.fill = fill
        self.end_attr = int(end_attr) & 0xFF

    def _plot(self, ctx, col, row):
        ax, ay = self._anchor
        vx, vy = col - ax, row - ay
        denom = float(vx * vx + vy * vy)
        s_rgb = attr_to_rgb(ctx.attr)
        e_rgb = attr_to_rgb(self.end_attr)
        blink = ctx.attr & 0x80
        do_fill = self.fill ^ bool(self._mods & MOD_CTRL)

        x0, x1 = sorted((int(ax), int(col)))
        y0, y1 = sorted((int(ay), int(row)))
        for r in range(y0, y1 + 1):
            for c in range(x0, x1 + 1):
                if denom == 0.0:
                    t = 0.0
                else:
                    t = ((c - ax) * vx + (r - ay) * vy) / denom
                    t = 0.0 if t < 0.0 else 1.0 if t > 1.0 else t
                rgb = tuple(int(round(s + (e - s) * t))
                            for s, e in zip(s_rgb, e_rgb))
                attr = rgb_to_odyssey(*rgb) | blink
                if do_fill:
                    self._stage(c, r, Cell(ctx.glyph, attr))
                else:
                    cur = self._local_cell(c, r)
                    if cur is not None:
                        self._stage(c, r, Cell(cur.glyph, attr))
