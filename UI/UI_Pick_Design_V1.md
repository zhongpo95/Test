# UI Pick Design V1

## Goal

Implement the hero pick screen only after the static design is accepted.
This pass replaces the v3-v6 trial-and-error layout with a fixed target design
for a 1600x900 screenshot baseline.

No JASS coordinate changes should be made from this document until the target
layout is approved.

## Decision Update

The pick UI is allowed to cover the lower Warcraft interface.

The top Hero Select title/header strip is removed. B, C, and D are moved upward so the removed title area does not leave the top of the window feeling empty. The card grid and preview panel should carry the screen identity without a separate title label.

Reason: this screen appears at game start while the player is choosing a
character. The normal in-game command/status interface is not needed during this
moment, so preserving that lower screen area should not constrain the design.

The separate A portrait column remains removed.

Reason: each character card already shows the character image and the save/load
choice is per character. A second large portrait repeats the same information
and consumes space that is better used by the card list.

B character cards are now square.

Reason: character images will be unified as TGA or BLP assets, and square source
images preserve quality better than stretching them into rectangular card slots.
The card frame should match that square image ratio so the art does not look
blurred or distorted.

C no longer shows a selected name or text strip. It is only a selected image
preview plus the final confirm button. The name can stay on the B card itself if
needed, but C should not repeat it.

The previous purple block under C Confirm was only a temporary placeholder. It
is removed from the design.

The layout now has three primary parts:

- B: main square character card grid
- D: scroll lane attached to B
- C: selected character image preview and confirmation panel

## Reference Read

The target reference is not mainly about color. Its structure is the important
part:

- One large translucent overlay sitting on top of the game view.
- A larger modal-like pick window, allowed to cover the lower game interface.
- A central grid of square character image cards and a scroll lane.
- A right panel that previews the clicked character image without duplicate name
  text.
- Strong separation between layout areas, but weak separation inside each area.

The current trial layout fails because:

- The old window was too shallow because it tried to preserve the lower UI.
- Rectangular card slots would stretch square TGA/BLP character art.
- The right panel repeated text that is not needed when B already identifies the
  card.
- The purple placeholder in C looked like an unexplained functional block.
- The background panel and actual JASS frames are not designed from the same
  pixel grid.

## Layout Baseline

Canvas: `1600 x 900`

Main overlay:

| Area | X | Y | W | H | Purpose |
| --- | ---: | ---: | ---: | ---: | --- |
| Main panel | 70 | 60 | 1460 | 760 | Whole pick UI; can cover lower interface |
| B card grid | 115 | 110 | 900 | 670 | Main square character card grid |
| D scroll lane | 1035 | 135 | 30 | 610 | Scroll indicator attached to B |
| C preview confirm | 1100 | 105 | 390 | 675 | Large selected image and action |

Card layout inside B:

| Item | X | Y | W | H |
| --- | ---: | ---: | ---: | ---: |
| Card 1 | 160 | 170 | 240 | 240 |
| Card 2 | 445 | 170 | 240 | 240 |
| Card 3 | 730 | 170 | 240 | 240 |
| Card 4 | 160 | 475 | 240 | 240 |
| Card 5 | 445 | 475 | 240 | 240 |
| Card 6 | 730 | 475 | 240 | 240 |

B spacing is now corrected inside the existing B panel: horizontal gaps are 45px on the left, between columns, and on the right; vertical gaps are balanced as 60px / 65px / 65px within the B panel.

C layout:

| Item | X | Y | W | H |
| --- | ---: | ---: | ---: | ---: |
| Preview image | 1130 | 155 | 330 | 520 |
| Confirm button | 1210 | 715 | 170 | 46 |

This keeps the 3x2 browsing model, but the B cards are now square so imported
character images can be authored as square TGA/BLP files without stretching. C
uses the space only for the enlarged selected image and confirm action.

## Interaction Rules

- Clicking an unlocked character card selects that character.
- The selected card gets the gold border state.
- C preview image updates to the selected character image immediately after the
  click.
- The C confirm button finalizes the currently previewed character.
- Before any card is selected, C can be empty, dimmed, or show a neutral
  placeholder frame only.
- Locked cards stay visible in B but do not update C.
- C does not show name/status text.

## Visual Rules

Palette:

- Base panel: dark navy with 62-72% opacity.
- Inner panel: blue-violet tint with 35-45% opacity.
- Primary line: cyan.
- Active/selected line: warm gold.
- Secondary line: muted lavender.
- Danger/locked state: desaturated purple-gray.

Shape language:

- Main panel corners can stay rounded, but inner cards should be sharper.
- B card frames must be square to match square character image assets.
- Avoid thick nested borders. Use one outer glow line and one subtle inner line.
- Card selection should be shown by gold border + brighter image, not by making
  the whole card yellow.
- Locked cards should remain in the grid but be visually quieter than unlocked
  cards.
- C image preview should be the largest single image on the screen.

Density:

- Use the added height to reduce crowding, not to add unrelated elements.
- B is the primary browsing area.
- C is large because it has a real preview role.
- Put the action button inside the C panel, aligned to the bottom.
- Keep the scroll lane attached to B, not floating between B and C.

## Asset Split

Use separate resources so the static background and live frames do not fight:

| Asset | Purpose |
| --- | --- |
| `UI_Pick_Backdrop.tga` | Main translucent panel and section guides only |
| `UI_Pick_Card_Normal.tga` | Normal square card frame |
| `UI_Pick_Card_Selected.tga` | Selected square card frame |
| `UI_Pick_Card_Locked.tga` | Locked square card frame |
| `UI_Pick_Confirm.tga` | C panel frame only |
| `UI_Pick_Button_Normal.tga` | Select/confirm button normal |
| `UI_Pick_Button_Hover.tga` | Select/confirm button hover |

Do not bake the hero card art, button text, or selectable state into the
backdrop. Those must remain controlled by `UI/UI_Pick.j`.

## Implementation Gate

Before touching `UI/UI_Pick.j`, confirm this design direction:

1. The pick window can cover the lower Warcraft interface.
2. Main panel stays a modal-like `1460 x 760` window.
3. No separate A portrait column.
4. B uses a 3x2 grid of square `240 x 240` card slots.
5. Character art should be prepared as square TGA/BLP files.
6. C shows only the selected image preview and confirm button.
7. C does not show duplicate character name/status text.
8. The top Hero Select title/header strip is removed.
9. B/C/D are moved upward so the modal top does not feel empty.
10. The unexplained purple placeholder below C Confirm is removed.
11. Scroll lane belongs to B.
12. v3-v6 resource experiments are treated as discarded prototypes.

After approval, the next implementation pass should happen in this order:

1. Build the static resource set from this pixel grid.
2. Convert the pixel rectangles to Warcraft frame coordinates.
3. Apply the coordinate table once in `UI/UI_Pick.j`.
4. Test with the user-provided screenshot loop.




