package main

import "core:fmt"
import "core:testing"
import "enc"
import "lexer"
import "sim"
import "token"

main :: proc() {

	filepath := "./listings/listing_0039_more_movs.txt"

	cpu := sim.create_8086()
	sim.decode_instructions(cpu, filepath)

}
