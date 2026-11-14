# Tessellio
Tessellated binary puzzle game

This project was started to see if it was possible to make a Takuzu/binary puzzle work on a an irregular and semi-regular tiled grids.  As evidenced by its existence, it is possible, so long as the tiling patterns meet certain criteria.  The included puzzles are just the tip of the iceberg of what is possible with the format.





## Rules


Rules are listed by in-game reveal order.

1. Every row/column has an equal number of tiles in each state.

2. The set of tiles that are in the same place in each copy of the tiling pattern has an equal number of tiles in each state.

3. A regular tile's value is the number of adjacent tiles that match its state.

5. An even line indicates a column/row with an equal number of grid cells in each state.  A tilted line indicates an inequality.

9. The inequality icon points to the underlying tile with the lower value.

8. Values of tiles under the equal icon are equal.

13. The row/column has exactly one tile with a value equal to the displayed number in the border ccell.

14. The values of the row/column total to the displayed number in the border cell.

7. Values of tiles under the square icon are the square/square root of each other.

11. Tiles under the Renban icon are a set of contiguous values.  Spaces under the Nabner icon are a set of non-contiguous values.  No repeat values.

10. Exactly one tile under the number has the displayed value.

6. Values of tiles under a ratio icon have the displayed ratio.

4. A stable tile is the *n*th of its state to appear, in every row/column it occupies, read from top-to-botton/left-to-right. Its value is *n*.

12.Total values of each state, for tiles under the balance, are equal.  Must involve more than one state.

15. Grid cells containing multiple tiles always count the top a dividing line first.
