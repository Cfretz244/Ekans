draw:
call wipe       ; Black-out entire screen.
ld hl, D540     ; Prime HL with address of board model
ld bc, C3A0     ; Store address of current tile on screen.
ld d, h         ; Copy model address into de for efficiency purposes.
ld e, l         ; ""
ld a, 01        ; Initially seed accumulator with a 1.

begin_draw:
push af
and (hl)        ; Check if bit is set.
jr z, draw_2nd ; Jump to next draw if not.
ld h, b         ; Get address of current tile on screen.
ld l, c         ; ""
ld (hl), 00     ; Load 00 byte into current tile (White tile).

draw_2nd:
pop af
inc bc          ; Increment the current tile.
rlca            ; Shift the accumulator for bitmasking.
ld h, d         ; Load address of current board model byte.
ld l, e         ; ""
push af
and (hl)        ; Check if bit is set.
jr z, redraw   ; Jump to the increment logic if not.
ld h, b         ; Get address of current tile on screen.
ld l, c         ; ""
ld (hl), 00     ; Load 00 byte into current tile (white tile).

redraw:
inc bc          ; Increment the current tile.
pop af
ld h, d
ld l, e
rlca            ; Shift the accumulator for bitmasking.
jr c, inc_model ; Shift the model forward a byte if there was a carry.
jr begin_draw   ; Jump back to beginning if not.

inc_model:
inc de          ; Increment model forward one byte.
ld h, d
ld l, e
jr begin_draw   ; Jump back to beginning.

wipe:
ld bc, 0168     ; Set the number of bytes we're writing (320).
ld hl, C3A0     ; Set the base address (Screen I/O).
ld a, 10        ; Set data to write (black tile).
call 36E0       ; Call memcpy.
ret

RngGen:         ; Generates a "random" byte and stores it in the E register.
push af
ld hl, $DA45
ld a, FF
and (hl)
ld e, a
pop af
ret
