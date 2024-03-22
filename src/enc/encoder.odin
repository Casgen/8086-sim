package enc
//
import "../lexer"
import "../sim"
import "../token"
import "core:fmt"
import "core:io"
import "core:os"
import "core:reflect"
import "core:slice"
import "core:strings"


InstructionEncoder :: struct {
	lex:        ^lexer.Lexer,
	curr_token: token.Token,
	peek_token: token.Token,
	errors:     [dynamic]string,
	output:     [dynamic]u8,
}

create_encoder :: proc(filepath: ^string) -> ^InstructionEncoder {

	encoder := new(InstructionEncoder)
	encoder.lex = lexer.create_lexer(filepath^)
	encoder.output = {}

	read_token(encoder)
	read_token(encoder)

	return encoder
}

write_output_to_file :: proc(using encoder: ^InstructionEncoder, filepath: string) {
	fd, err := os.open(filepath, os.O_WRONLY)

	os.write_entire_file(filepath, output[:])

	assert(err == os.ERROR_NONE)

	os.close(fd)
}

encode :: proc(using encoder: ^InstructionEncoder) {

	for curr_token.type != token.TokenType.EOF {

		for byte in encode_instruction(encoder) {

			append(&output, byte)
		}
	}
}


encode_instruction :: proc(using encoder: ^InstructionEncoder) -> (bytes: [dynamic]u8) {

	if curr_token.type == .INSTRUCTION {

		switch curr_token.literal {
		case token.MOV:
			bytes := encode_mov(encoder)
			return bytes
		}
	}

	if curr_token.type == .BITS && peek_token.type == .INTEGER {
		read_token(encoder)
		read_token(encoder)
		return {}
	}

	append(
		&errors,
		fmt.aprintf("TokenType %s unrecognized!", reflect.enum_string(curr_token.type)),
	)

	read_token(encoder)

	return {}
}

encode_mov :: proc(
	using encoder: ^InstructionEncoder,
	use_d_field: bool = false,
) -> (
	bytes: [dynamic]u8,
) {

	// First byte encodes as 10001000 - Binary for 'mov'

	resize(&bytes, 2)



	bytes[0] = 0b10001000
	bytes[1] = 0

    if (use_d_field) {
	    bytes[0] |= 0b00000010
    }

	read_token(encoder)

	if curr_token.type == .OPERAND {
		register_encode, ok := sim.register_to_encoding_map[curr_token.literal]

		// TODO: Later parse it with getting data from memory (Maybe Casey has a video dedicated for it?)
		assert(ok)


		if register_encode.isWide {
			bytes[0] |= 0b00000001
		}

		bytes[1] |= 0b10000000

		if (use_d_field) {
			bytes[1] |= (register_encode.regField << 3)
		} else {
			bytes[1] |= register_encode.regField
		}
	}

	expect_peek(encoder, token.TokenType.COMMA)

	read_token(encoder)

	if curr_token.type == .OPERAND {
		register_encode, ok := sim.register_to_encoding_map[curr_token.literal]

		// TODO: Later parse it with getting data from memory (Maybe Casey has a video dedicated for it?)
		assert(ok)

		if register_encode.isWide {
			bytes[0] |= 0b00000001
		}

		bytes[1] |= 0b01000000
		if (use_d_field) {
			bytes[1] |= register_encode.regField
		} else {
			bytes[1] |= (register_encode.regField << 3)
		}
	}

	read_token(encoder)

	return bytes
}

read_token :: proc(using encoder: ^InstructionEncoder) {
	curr_token = peek_token
	peek_token = lexer.next_token(lex)
}

is_peek_token :: proc(using encoder: ^InstructionEncoder, tokType: token.TokenType) -> bool {
	return peek_token.type == tokType
}

expect_peek :: proc(using encoder: ^InstructionEncoder, tokType: token.TokenType) -> bool {

	if is_peek_token(encoder, tokType) {
		read_token(encoder)
		return true
	}

	append(
		&encoder.errors,
		fmt.aprintf(
			"Expected next token to be %s, got %s instead",
			reflect.enum_string(tokType),
			reflect.enum_string(peek_token),
		),
	)
	return false
}
