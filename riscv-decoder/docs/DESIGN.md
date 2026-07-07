# Design Notes — RISC-V Decoder

## Structure

Three source files:
- memory.c — loads hex file into uint32_t array
- decoder.c — decodes each 32-bit word into fields
- main.c — CLI entry point, calls decoder, prints output

## Decoding Approach

Used shift-and-mask with EXTRACT_BITS macro from common.h.
Each instruction type has a different immediate encoding so
sign extension is handled per instruction type in decode_instruction().

## Immediate Encoding Notes

B-type and J-type immediates are scattered across the instruction word.
B-type: bits [12|10:5|4:1|11] reassembled manually.
J-type: bits [20|10:1|11|19:12] reassembled manually.
Both sign-extended using sign_extend() helper.

## Known Limitations

DEADBEEF decodes as JAL because opcode 0x6F is valid JAL encoding.
A true UNKNOWN requires an opcode not in the RV32I spec.