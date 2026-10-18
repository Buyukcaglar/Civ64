# Brief: unit WL, the windowless play mode (design note, the implementer's proposal)

Written 2026-10-18 by session E4's WL implementer at the orchestrator's request ("Design note first ... written as
your proposal"). It is a proposal: every point marked **Decision** waits for the orchestrator's answer, and nothing
here is user consent. The unit lands after D8 and before X9 (STATUS, the user's order of 2026-10-16 about 07:05), so
X9's audit and the one Asan pass cover it.

## The user's direction (verbatim, STATUS "User directions", 2026-10-15 about 10:47 UTC)

```
take a note for the following feature task for to implement after DOS graphics implementation completed and
verified; Implement optional host application context menu selectable, on the fly change enabled, windowless play
mode for the actual gameplay, for both Windows and Dos graphics mode. This mode will essentially ditch windows
chrome around the three windows and stitch them together as single gameplay canvas.
```

The orchestrator's frame (its WL assignment): presentation only; the emulated windows keep their styles and
positions (P0); input maps back to the windows' client points; one menu item that fits HM's window menu
(`BRIEF-hm.md`, the user's fixed layout), recorded as a deviation from it.

## User direction of 2026-10-18 about 06:20 UTC (verbatim, relayed by the orchestrator; STATUS "User directions")

```
Map area does not need scroll bars it already can be scrollable in two ways; 1. In normal game player can click to
portions of mini-map (World Map) to scroll or jump to sections of play map 2. Left clicking on the play map area jumps
to to that section both are already implemented on host project. So your "joined into one picture without title
bars"'s 'play map' section shall be able to scroll (or rather jump) among the play area without scroll bars, so for
windowless play mode there shall be no scroll bars visible also.
```

It replaces the orchestrator's answer to Decision 2. **Decision 2 is settled by the user:** in windowless play no
scroll bars show, in either graphics, without condition; the fallback that kept them in the map piece when a graphics
had no other way to scroll is dropped. The play map moves only as it does today: by a click on the World Map and by a
left click on the play map. Both become WL user checks, and staging verifies both through WL's input mapping (the
World Map piece's click and a left click in the map piece) against the windowed points in the input pairs
(`ext-WL-record.md`).

Deferred to the next session by the user (2026-10-18 about 06:45 UTC), with the extras. The staged work and what
remains: `build/wl-stage/STATE.md`.

## Facts the design rests on

* **The three windows.** The core opens them once a game starts:
  * **The map window.** WdwMapOpen 1208:0AF1 creates it at 1208:0B4E with style 0x02FF0000. That is WS_CLIPCHILDREN
    plus WS_OVERLAPPEDWINDOW plus WS_HSCROLL and WS_VSCROLL: a caption, a system menu, a thick frame, the minimize and
    maximize boxes and both scroll bars. It is a top-level window of class "CIV", and the class menu is MENU 128, the
    game's only menu bar. Its handle is at g_mapWindowPort 12B0:0004 (+0). Default rectangle 165,0..W,H (12.4).
  * **The World Map window.** WdwSmMapOpen 1210:025B creates it at 1210:02A6 with style 0x80CC0000: WS_POPUP,
    WS_CAPTION, WS_SYSMENU and WS_THICKFRAME, with no menu and no scroll bars. Its handle is at g_worldMapWindowPort
    12B0:001C. Default rectangle 0,0..166,127.
  * **The Status window.** WdwStatusOpen 1218:0386 creates it at 1218:03D1 with the same style 0x80CC0000. Its handle
    is at g_statusWindowPort 12B0:0034. Default rectangle 0,126..166,458.
* **What the presentation can read.** Everything WL needs is already in the w16 query (w16_obs.h), so platform/w16
  stays unchanged:
  * `w16q_wnd`: the class, the style, the window and client rectangles in screen coordinates, and `shown`.
  * `w16q_wnd_first` and `w16q_wnd_next`: the top-level windows in z-order.
  * `w16q_wnd_client_vis`: the visible regions.
  * `w16q_menu_bar`: the bar's rectangle.
  * `w16q_menu_state` and `w16q_menu_saved`: the open popups, with their shadows.
  * `w16q_sys_track`: the move or size outline.

  pmap already reads the map window this way (pmap_inview.c `read_map`), and pdos_aplay.c reads the other two.
* **Frames.**
  * The Windows profile shows g_win: the RGB of the virtual screen, at the screen's size (640x480, or the game screen,
    F105).
  * In play, the DOS profile shows its A frame. That is the same Windows layout at the same size, with the DOS art
    composed at the windows' clients (D6e) and the DOS bar on the menu bar (D6fS-b). The captions, frames and scroll
    bars stay Windows (class W).
  * The DOS N frame (320x200: the city, leader and other DOS scenes) has no windows.
* **Mouse.** The window procedure calls `pi_arrive_mouse` (arrive.c). That goes through the zoom layer's
  classification first, then `present_view_point`, which applies the visible layout's inverse (scale.c
  `present_map_point`), giving a frame point (HostEvent.frame 0 Windows, 2 A). A press outside the image is not
  delivered (F100). host_sync.c later posts the point at virtual-screen coordinates.
* **The game screen.**
  * `present_game_screen` and `present_game_screen_follow` read only the 640x480 layout, the client and the options,
    never the visible frame (K1).
  * The game screen's size is an input of the run, because the map dissolve draws one random number per visible
    square (12.4).

## Proposal

### 1. The menu item

* **Proposed place: the top level, directly below "Full screen  Alt+Enter".** The item is a check item
  "&Windowless play" with the new id `SC_CIV_WINDOWLESS` 0x1110, the next free multiple of 16 after 0x1100 (the
  LP/HM audit rule).
* **Why there rather than Display:**
  * Like Full screen, it changes what the window holds, not how the picture is scaled. Display's items (scaling,
    filter, 4:3, and later CRT) all keep working under it.
  * The user asks for "on the fly" changes, and the top level reaches it with one click less.
* **Mnemonics.** W is free at the top level: f, d, z, g, a and c are taken, and the system's own are r, m, s, n and x.
* **The orchestrator's default** (also workable) is the first item of Display, with a separator below it. W is free
  there too (Display's mnemonics are i, f, n, s and c).
* Either way, it is a recorded deviation from the user's HM layout:
  * the top level grows from 14 to 15 entries; or
  * Display grows from 7 to 9 entries, counting the separator.

  `test_hm`'s tables, counts and positions move with it (ext-HM-record.md, "a unit adding a window-menu item").
* **Decision 1:** the top level, or Display.
* **Behaviour.** The mark is kept by `hw_update_menu`: at start-up, after the command, from `--windowless` and from
  `civ64.cfg`. The item works the same in both graphics. Under `CIV_OBSERVER 0` the item is grayed and
  `--windowless 1` is refused (exit 2, naming the build, as `--zoom`), because WL needs the query. No chord is
  proposed; the user asked for the menu only.

### 2. When WL is active

The option is a presentation option like the scaling policy. It acts only while all of these hold:

* the option is on;
* the map window exists (12B0:0004, class "CIV"), is shown and is not iconic;
* the visible frame is the Windows frame or the DOS A frame.

Otherwise the picture is exactly today's. That covers the startup, intro, title, Birth and setup screens (before
WdwMapOpen), the DOS N scenes in play, the Birth synchronisation view and a minimized map window.

Switching the option on or off redraws the whole client, as a policy change does (`show_all`). WL then follows the
game at every core present and tick.

### 3. The menu bar and the scroll bars

* **Menu bar: kept.** It is the game's only menu (MENU 128). In the DOS graphics it carries D6fS-b's DOS bar. The bar
  piece is the bar's rectangle down to the client's top, including the line between them. It is placed directly above
  the map's client, at the client's width. The bar's part over the vertical scroll bar is cut. A test asserts that
  the bar's titles end inside the client's width at the smallest game screen (640x480). Not yet measured.
* **Scroll bars: dropped.** They are chrome, and DOS has none. Proposed justification, inference to be confirmed in
  staging: the map can still be scrolled by the game's other means:
  * the World Map click;
  * the centring keys;
  * the game's own map-edge scroll cursors (cursors 136..143).
* **Decision 2:** drop the scroll bars as proposed. The alternative keeps them: the map piece would then be the window
  less its caption and frame (bar, client, both bars and the corner box). **Settled by the user (2026-10-18 about
  06:20 UTC, above):** no scroll bars in windowless play, in either graphics, without condition; the play map jumps by
  a World Map click and by a left click on the play map. The centring keys and the edge cursors above are not needed
  for the decision.

### 4. The stitched arrangement (both graphics alike)

* **Pieces.** Each piece is a rectangle of the visible frame, copied 1:1 in logical pixels to a place on a canvas:
  * **M**: the bar piece over the map's client.
  * **W**: the World Map's client.
  * **S**: the Status window's client.

  W and S are present only while their window is shown and not iconic.
* **Topology: fixed. Order: from the windows' current positions.**
  * W and S form one column.
  * The column stands left of M when the mean of the two windows' centres is left of the map window's centre, and
    right of it otherwise.
  * Inside the column, the window whose top is higher comes first.

  With the default and the usual civ.prf layouts, this gives the DOS game's own arrangement: the small map above the
  status panel at the left, the map at the right, the menu line on top.
* **Placement.**
  * Everything starts at canvas y 0, with no spacing between pieces.
  * The column's width is the wider client's, and each piece is left-aligned in it.
  * The canvas is (column width + M width) x max(W height + S height, M height).
  * What no piece covers is black, which is the desktop colour of F107.
  * Without a column the canvas is M alone.
* **What a piece copies.** A piece copies its rectangle, except where on the virtual screen another of the three
  windows or a float anchored elsewhere (section 5) covers it. Those parts are black, so nothing appears twice.
* **Size changes.** A change of the arrangement (a size, a hidden or shown column window, the game screen following
  the host, F110) gives a new canvas. Its size is laid out anew, as a new frame size is today (`relayout_due`).
* **Rejected: "from the windows' current positions" taken literally.** Collapsing the chrome strips out of the
  virtual screen is ill-defined for overlapping or spread windows, and it would not stitch.
* **Rejected: a fixed layout of fixed sizes.** The windows keep their sizes (P0), so the canvas has to take them.
* **Decision 3:** the arrangement as proposed.

### 5. Dialogs and popups over the canvas ("floats")

* **What a float is:** a rectangle drawn above the three windows.
  * **Windows profile:**
    * every shown top-level window other than the three and the desktop (the game's dialogs, message boxes and its
      other windows), by its window rectangle;
    * the menu loop's open popups, with their shadows (`w16q_menu_saved`);
    * the move or size outline.
  * **DOS profile:**
    * the Windows floats that the DOS graphics do not hide (`pdos_reskin_hidden_wnds`);
    * the A-canvas rectangles of the DOS boxes and DOS menu boxes it composes over the windows. A new profile callback
      reports them (profile.h, present-side).
* **Placement.** A float is moved by the translation of its anchor and then clamped inside the canvas. The anchor is
  the piece whose window holds the float's centre, or M when none does. So:
  * a popup of the bar opens under its title;
  * a dialog centred on the screen appears near the canvas's centre.
* **Drawing.** Floats are drawn whole, from the frame, over the pieces, in z-order.
* **Limit (recorded).** Where a float also covers a piece other than its anchor on the virtual screen, that piece's
  covered part has no pixels. The canvas shows it black beside the float: a strip at most as wide as the chrome
  removed between the two pieces. Example: about 27 rows where a dialog centred on a 640x480 screen also covers the
  Status window, whose canvas place is raised by the World Map's bottom frame and its own caption. Content behind a
  dialog is never invented. (Correction, staging: 24 rows at the default layout, S's translation -46 against M's
  -22; `tests/test_wl.c`.)
* **A float larger than the canvas.** Proposed: while it is shown, WL pauses (the frame as without WL, so nothing is
  cut) and resumes when it closes. This is expected only at small game screens, for windows close to the screen's
  size. The alternative clamps such a float to the canvas's top left and cuts it at the right and bottom.
* **Decision 4:** the float rules, and the pause for oversized floats.

### 6. Moving and resizing

* Under WL the three windows have no visible caption or border, so the mouse cannot move or size them. They keep
  their positions and sizes, and the game still writes them to civ.prf as today.
* Sizing the host window still sizes the game screen (F110, unchanged). The map window's edges follow it as today, and
  the canvas follows the windows.
* The keyboard keeps the game's keys: Alt, Alt+Space and F10 stay the game's, and the emulated system menu appears as
  a float. A keyboard Move or Size of a window changes the virtual screen, and the canvas follows by the topology rule.
* To rearrange the windows, the player switches WL off, arranges them and switches it on again.
* Dialogs keep their own captions and can be moved as before; their outline is a float.

### 7. Full screen, scaling, 4:3, filters, cursor

* **The canvas is laid out like any frame.**
  * Integer: a whole factor.
  * Fit: one real factor, with the nearest or sharp filter.
  * The 4:3 item never acts on the canvas, which is not 320x200. N frames keep it as today.
* **Full screen** is independent of WL, and the two combine.
* **The game screen does not change.** `present_game_screen` and `_follow` keep reading only the 640x480 layout.
  * The game screen fills the client at the windowed scale (F105/F110), and the canvas is smaller than the screen by
    the chrome. So under integer, the canvas is centred at the game screen's factor, with black borders of about the
    removed chrome times the factor.
  * Under fit, the canvas fills the client in one direction.
  * Growing the game screen to fill the client under WL would change the core: more squares, so more of the
    dissolve's random draws. It is therefore not proposed: the core's outputs must stay equal with WL on and off.
  * **Decision 5:** confirm this consequence (integer borders under WL).
* **The game's cursor and the DOS pointer** take their factors from the canvas's layout. The Windows layout used by
  `present_pointer_factors` becomes the canvas's while WL is active.

### 8. Zoom

* The map layer (12.9) follows M. pmap's geometry gets two things:
  * the canvas's layout, in place of `pmap_core_layout`'s core-size layout;
  * the map client in canvas coordinates, with its visible region and cuts moved by M's translation.
* Its event points stay in virtual-screen coordinates (`pmap_layer_point` keeps `m->cx`, `m->cy`).
* The draw gate at pmap_layer.c:523 compares with the canvas's layout while WL is active.
* MZW's World Map patch lives in g_win, and the DOS World Map in the A frame, so W carries both.
* The wheel works over M. The chords and the Map zoom items are unchanged.

### 9. The input mapping

* **The mapping.**
  1. A host point maps to a canvas point through the canvas's layout (`present_map_point`).
  2. The canvas point goes to the topmost float holding it, or else to the piece holding it.
  3. The frame point is the canvas point less that translation. `present_view_point` returns 1.
* **Elsewhere** (black areas, gaps and the borders), the point maps to the nearest pixel of the nearest piece and
  returns 0. A press there is therefore not delivered, as on the black borders today (F100), and a move is clamped.
* **A delivered press keeps its piece.** The arrival stage's latch records the piece, and the press's moves and its
  release map through that piece's translation, extended beyond it and clamped to the frame. This is what Windows'
  capture gives a window outside its client. It keeps drags continuous.
* HostEvent.frame stays 0 or 2. The DOS adapters (area C) receive virtual-screen points as today. Keys are unchanged.
* **Threading.** The arrangement (pieces, floats, translations) is read inside the observer's guard, at each core
  present and tick, as pmap's `read_map` does, and cached. `present_view_point` and the host's redraws run from the
  window procedure, outside the guard, and use only the cache.

### 10. Persistence and options

* **civ64.cfg key `windowless`.** Values 1 or 0; anything else reads as absent, which means off. `civ64_cfg_windowless`
  and `civ64_cfg_set_windowless` follow `wheel_zoom`'s pattern: the key is written only after the player's change
  through the menu, by a hook, and at the following saves.
* **civ64's `--windowless 0|1`** wins for its run and is never written, as `--graphics` and `--zoom`.
* **The harness.**
  * The option `--windowless 0|1`, in harness_main.c with an HhOptions field.
  * The script command `windowless on|off`, in harness.c `load_command` and `commands_apply`. harness.c is CRLF.

### 11. Where the code goes (P0)

* **New `present/wl.c` and `present/wl.h`** (portable C, prefix `pwl_`). They hold the option, the cached arrangement,
  the canvas buffer, the damage translation (a frame damage rectangle split over the pieces and floats it meets) and
  the inverse map.
* **present.c.** Where the visible profile's `frame()` or `peek()` is taken (`shown`, `show_all`,
  `present_core_frame`, the tick), the frame passes through `pwl_frame` while WL is active, so the layout, scaler and
  show see the canvas. `present_shown_frame` then returns the canvas, and `present_core_xrgb` stays g_win.
* **profile.h.** The float callback. profile_win.c and pdos_profile.c implement it.
* **pmap.** The geometry seam.
* **arrive.c.** The latched piece.
* **host_win32.c.** The item, `civ_command` and the hook.
* **win64.** The option and the cfg key.
* **The harness and the tests.**
* **Unchanged:** core, rt and platform/w16. No `w16_present` is added, removed or delayed, no random number is drawn,
  and the game screen is unchanged. No present or DOS file includes input.h or <stdio.h> beyond today's.

### 12. Tests

* **Portable** (test_present, or a new tests/test_wl.c in the test build):
  * the arrangement for the default layout, the column at the right, the order, a hidden or iconic column window, an
    iconic map, a maximized map, and no map window;
  * the canvas size;
  * piece copies equal to the frame translated, and black elsewhere;
  * floats: anchor, clamp, black strips, and the pause;
  * damage translation;
  * the inverse map: pieces, floats, gaps returning 0, and a latched press;
  * integer, fit and sharp layouts of the canvas;
  * the bar's width at 640x480;
  * that WL is inactive on N frames and before the map window.
* **Headless.**
  * With `--windowless 1 --presented 1`, a WL relation: every shown canvas pixel equals its source pixel of the
    frame, or is black where nothing is placed. presented.log gets `wl` fields and the end line a `wl_mismatches`
    count, which must be 0.
  * The existing relation keeps checking g_win against the screen. Its size condition (`w == f->w`) compares against
    the canvas while WL is active.
* **P0 variations** (ext_p0.py), with the core outputs compared with V0 as today:
  * V9: `--windowless 1`.
  * V9d: V9 with `--dos-data build\dosdata --switch-every 997`.
  * V9t: script commands every 1,103 ms cycling `windowless on`, `zoom +1`, `windowless off`, `zoom reset`, with
    `--host-size 1920x1440`.
* **Input pairs** (shaped like ext_adapt.py's pairs, in W16_TIMING_SCRIPT with `--host-input --core-input-log 1`):
  * One run takes host-form clicks and drags at canvas points with `--windowless 1`. The other takes the same actions
    at the corresponding windowed host points without WL.
  * Covered: map squares, a World Map click, a Status click, a bar menu choice, a dialog button, a drag that leaves
    its piece, and a press in a gap (not delivered).
  * Pass: `coreinput.log`, frames, state and events are equal, in both graphics.
* **Win32-headless** (test_host_win32.c):
  * `test_hm`'s tables with the new item;
  * the mark after the command and at start-up from `--windowless` and the cfg;
  * the cfg key written only after a change;
  * `--windowless` parsing;
  * the grayed item under `CIV_OBSERVER 0` (the NoObs build).
* **Agent check.** A private civ64.exe with `--windowless 1`, in both graphics. It is started with
  `--multi-instance`, a data copy under build/, and a private USERPROFILE and LOCALAPPDATA. D6g's agentui.py method
  (ext-D6g-record.md) is the model: PrintWindow of the client, and SendInput only while that civ64 is in front.
  * Covered: the default and a larger game screen, a bar menu open, a message box, a dialog over the Status column,
    zoom +1 and -1, and switching WL on and off.
  * Screenshots of that civ64 window only, under claude/port/build/wl-agent/. The user's civ64 and its civ64.cfg are
    never touched.
* **The user's visual check** follows. The orchestrator writes the checklist items.

## Open points for the orchestrator (summary)

1. The menu item's place: the top level below Full screen (proposed), or the first item of Display (the default).
2. Scroll bars: dropped (proposed), or kept in the map piece. Settled by the user on 2026-10-18 about 06:20 UTC:
   dropped, without condition (see "User direction of 2026-10-18 about 06:20 UTC").
3. The arrangement: a fixed topology, with the column's side and order taken from the current positions (proposed).
4. Floats: the anchor and clamp rule, the black-strip limit, and the pause for a float larger than the canvas
   (proposed), or the cut.
5. The game screen stays independent of WL (P0 equality). Under integer scaling, the canvas therefore has black
   borders of about the removed chrome times the factor.
