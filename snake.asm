setup:
ld bc, 12
ld hl, D540
ld a, 00
call 36E0
ld a, 08
ld (DAA0), a
ld (DAA1), a

input_tick:
ld hl, FFF8
push af
and (hl)
jr z, down_pressed
pop af
rrca
push af
and (hl)
jr z, up_pressed
pop af
rrca
push af
and (hl)

draw:
call wipe       ; Black-out entire screen.
xor a           ; Clear out the value in A.
ld (D53A), a    ; Write 0 to alternating byte.
ld hl, D540     ; Prime HL with address of board model
ld bc, C3A2     ; Store address of current tile on screen.
ld d, h         ; Copy model address into de for efficiency purposes.
ld e, l         ; ""
ld a, 01        ; Initially seed accumulator with a 1.

begin_draw:
push af         ; Push the accumulator value so when AND over-writes it, it's not awful.
and (hl)        ; Check if bit is set.
jr z, draw_loop ; Jump to next draw if not.
ld h, b         ; Get address of current tile on screen.
ld l, c         ; ""
ld (hl), 00     ; Load 00 byte into current tile (White tile).

draw_loop:
inc bc          ; Increment the current tile.
pop af          ; Restore accumulator value.
rlca            ; Shift the accumulator for bitmasking.
jr c, inc_model ; Shift the model forward a byte if there was a carry.
jr reload       ; Jump back to beginning if not.

inc_model:
inc de          ; Increment model forward one byte.
push af         ; Store accumulator value.
ld a, (D53A)    ; Get alternator value.
cp a, 01        ; Check if the alternating byte is set.
jr nz, nzero    ; Jump if it's not.
inc bc          ; Increment the drawing location
inc bc          ; ""
inc bc          ; ""
inc bc          ; ""
dec a           ; Decrement A to zero.
jr fix          ; Jump over set logic.

nzero:
inc a           ; Increment A to 1.

fix:
ld (D53A), a    ; Set the alteranting byte.
pop af          ; Restore the accumulator.

reload:
ld h, d         ; Update the model.
ld l, e         ; ""
jr begin_draw   ; Jump back to beginning.

wipe:
ld bc, 0168     ; Set the number of bytes we're writing (320).
ld hl, C3A0     ; Set the base address (Screen I/O).
ld a, 10        ; Set data to write (black tile).
call 36E0       ; Call memcpy.
ret
