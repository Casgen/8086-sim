package lexer

import "../sim"
import "../token"
import "core:os"
import "core:path/filepath"
import "core:strings"

Lexer :: struct {
	curr_char:     u8,
	next_pos: u32,
	curr_position: u32,
	input:   string,
}

create_lexer :: proc(filePath: string) -> ^Lexer {

	lexer := new(Lexer)

	data, ok := os.read_entire_file_from_filename(filePath)

    assert(ok)

	lexer.input = string(data)
	lexer.next_pos = 0
	lexer.curr_position = 0
	read_char(lexer)

	return lexer
}

read_char :: proc(using lexer: ^Lexer) {

	if next_pos >= u32(len(input)) {
		curr_char = 0
	} else {
        curr_char = input[next_pos]
	}

	curr_position = next_pos
	next_pos += 1
}

skip_whitespace :: proc(using lexer: ^Lexer) {
	for curr_char == ' ' || curr_char == '\t' || curr_char == '\n' || curr_char == '\r' {
		read_char(lexer)
	}
}

next_token :: proc(using lexer: ^Lexer) -> token.Token {

	tok: token.Token

	skip_whitespace(lexer)

	switch curr_char {

	case ',':
        tok = token.Token{token.TokenType.COMMA, token.COMMA}
	case ';':
        tok = token.Token{token.TokenType.SEMICOLON, token.SEMICOLON}
	case 0:
        tok = token.Token{token.TokenType.EOF, token.EOF}
	case:
		if is_letter(lexer.curr_char) {
			identifier := read_identifier(lexer)

			tokenType, ok := token.identifier_map[identifier]

			if tokenType, ok := token.identifier_map[identifier]; ok {
				return token.Token{tokenType, identifier}
			}

			return token.Token{token.TokenType.ILLEGAL, token.ILLEGAL}
		} else if is_digit(lexer.curr_char) {
            
            tok.literal = read_number(lexer)
            tok.type = token.TokenType.INTEGER

            return tok
        }
	}

    read_char(lexer)

	return tok
}


read_identifier :: proc(using lexer: ^Lexer) -> string {
	beginPosition := curr_position

	for is_letter(curr_char) {
		read_char(lexer)
	}

    return input[beginPosition:curr_position]

}

read_number :: proc(using lexer: ^Lexer) -> string {

	beginPosition := curr_position

	for is_digit(curr_char) {
		read_char(lexer)
	}

    return input[beginPosition:curr_position]
}

is_digit :: proc {
    is_digit_u8,
    is_digit_rune,
}


is_digit_u8 :: proc (char: u8) -> bool {
    return char >= '0' && char <= '9'
}

is_digit_rune :: proc (char: rune) -> bool {
    return char >= '0' && char <= '9'
}

is_letter :: proc {
	is_letter_u8,
	is_letter_rune,
}

is_letter_u8 :: proc(char: u8) -> bool {
	// This is a hack where we abuse the ascii tables organization of characters into columns
	// The uppercase characters begin at 65 and lowercase at 97.
	// If we abuse the fact that their offsetted by 32, we can use some bitmasking to mask
	// off the 4. bit (32) from the 97 and that bumps it down to 65. Therefore we should be
	// able to only do two comparisons. Not four. 0b00110000 & 11011111

	mask: u8 = char & (223)
	return (mask > 64 && mask < 91) || char == 95
}

is_letter_rune :: proc(char: rune) -> bool {

	// This is a hack where we abuse the ascii tables organization of characters into columns
	// The uppercase characters begin at 65 and lowercase at 97.
	// If we abuse the fact that their offsetted by 32, we can use some bitmasking to mask
	// off the 4. bit (32) from the 97 and that bumps it down to 65. Therefore we should be
	// able to only do two comparisons. Not four. 0b00110000 & 11011111

	mask := char & (223)
	return (mask > 64 && mask < 91) || char == 95
}
