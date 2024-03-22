package sim

import "../token"
import "core:bytes"
import "core:fmt"
import "core:os"

RegisterFieldEncoding :: struct {
	identifier: [2]u8,
	isWide:     bool,
	regField:   u8,
}

register_to_encoding_map := map[string]RegisterFieldEncoding {

	// wide registers
	"ax" = {"ax", true, 0x0},
	"cx" = {"cx", true, 0x1},
	"dx" = {"dx", true, 0x2},
	"bx" = {"bx", true, 0x3},
	"sp" = {"sp", true, 0x4},
	"bp" = {"bp", true, 0x5},
	"si" = {"si", true, 0x6},
	"di" = {"di", true, 0x7},

	// non-wide registers
	"al" = {"al", false, 0x0},
	"cl" = {"cl", false, 0x1},
	"dl" = {"dl", false, 0x2},
	"bl" = {"bl", false, 0x3},
	"ah" = {"ah", false, 0x4},
	"ch" = {"ch", false, 0x5},
	"dh" = {"dh", false, 0x6},
	"bh" = {"bh", false, 0x7},
}


registers_string_slice: [16]string =  {
	"ax",
	"cx",
	"dx",
	"bx",
	"sp",
	"bp",
	"si",
	"di",
	"al",
	"cl",
	"dl",
	"bl",
	"ah",
	"ch",
	"dh",
	"bh",
}

eac_array: [8]string = {"bx + si", "bx + di", "bp + si", "bp + di", "si", "di", "bp", "bx"}


find_register_string :: proc(reg_bits: u8, is_wide: bool) -> string {

	assert(reg_bits <= 7)

	offset := u8(!is_wide) * 8
	return registers_string_slice[reg_bits + offset]
}


Sim8086 :: struct {
	// Registers
	ax: u16,
	bx: u16,
	cx: u16,
	dx: u16,
	sp: u16,
	bp: u16,
	si: u16,
	di: u16,
}


create_8086 :: proc() -> ^Sim8086 {

	sim := new(Sim8086)

	sim.ax = 0
	sim.bx = 0
	sim.cx = 0
	sim.dx = 0

	sim.sp = 0
	sim.bp = 0
	sim.si = 0
	sim.di = 0

	return sim
}

decode_instructions :: proc(using cpu: ^Sim8086, filepath: string) {

	fd, ok_open := os.open(filepath)

	assert(ok_open == os.ERROR_NONE, "Failed to open a file!")

	loop: for {

		first_byte := read_byte(fd)

		if first_byte == 0 {
			break loop
		}

		switch {
		case is_byte_instruction_type(first_byte, .MOV_REG_OR_MEM_TO_REG):
			{
				fmt.print("mov ")

				opt_field := read_byte(fd)

				mod_field := (opt_field & 0b11000000) >> 6

				is_wide: bool = (first_byte & 0b00000001) == 0b00000001
				is_d: bool = (first_byte & 0b000000010) == 0b00000010 // if D bit if true, the instruction destination is in REG field

				reg := (opt_field & 0b00111000) >> 3
				r_m := (opt_field & 0b00000111)

				is_only_reg: bool = mod_field == 3

				// if MOD field equals 0b11 then movement is being done only between registers
				if is_only_reg {


					if is_d {
						fmt.printf("%s,", find_register_string(reg, is_wide))
						fmt.printf("%s\n", find_register_string(r_m, is_wide))
					} else {
						fmt.printf("%s,", find_register_string(r_m, is_wide))
						fmt.printf("%s\n", find_register_string(reg, is_wide))
					}
					break
				}

				is_no_disp := mod_field == 0

				// This one is an exception when R/M = 110. If this is true,
				// 16-bit displacement with a direct address follows
				if is_no_disp && r_m == 6 {

					disp_value := read_word(fd)

					if is_d {

						fmt.printf("%s,", find_register_string(reg, is_wide))
						fmt.printf("[%s]\n", disp_value)
						break
					}

					fmt.printf("[%s]", disp_value)
					fmt.printf("%s\n", find_register_string(reg, is_wide))
					break
				}


				if is_d {
					fmt.printf("%s, ", find_register_string(reg, is_wide))
					fmt.printf("[%s", eac_array[r_m])
					// If MOD field is equal 0b01, then 8-bit displacement follows
					if mod_field == 2 {
						fmt.printf(" + %d]\n", read_word(fd))
						break
					} else if mod_field == 1 {
						fmt.printf(" + %d]\n", read_byte(fd))
						break
					}
					fmt.println("]")
					break
				}

				fmt.printf("[%s", eac_array[r_m])

				if mod_field == 2 {
					fmt.printf(" + %d]\n", read_word(fd))
					break
				} else if mod_field == 1 {
					fmt.printf(" + %d]\n", read_byte(fd))
					break
				}

				fmt.printf("], %s\n", find_register_string(reg, is_wide))

			}
		case is_byte_instruction_type(first_byte, .MOV_IMM_TO_REG):
			{
				fmt.print("mov ")

				is_wide: bool = (first_byte & 0b00001000) == 0b00001000
				reg := first_byte & 0b00000111

				fmt.printf("%s, ", find_register_string(reg, is_wide))


				if is_wide {
					value := read_word(fd)
					fmt.printf("%d\n", value)
					break
				}

				value := read_byte(fd)
				fmt.printf("%d\n", value)
				break

			}
		}


	}

}

decode_mov_reg_or_mem_to_reg :: proc()

read_byte :: proc(fd: os.Handle) -> u8 {
	byte: []u8 = {0}
	n, ok := os.read_full(fd, byte)

	assert(ok == os.ERROR_NONE)

	return byte[0]
}


read_word :: proc(fd: os.Handle) -> u16 {
	byte: []u8 = {0, 0}
	n, ok := os.read_full(fd, byte)

	assert(ok == os.ERROR_NONE)

	// Transmute the 2 byte slice into u16
	return (transmute(^u16)&byte[0])^
}
