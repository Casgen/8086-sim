package token;

Token :: struct {
    type: TokenType,
    literal: string,
}

TokenType :: enum {
    INSTRUCTION,
    OPERAND,
    ILLEGAL,
    COMMA,
    EOF,
    SEMICOLON,
    BITS,
    INTEGER,
}

Instruction :: enum {
    MOV
}



identifier_map := map[string]TokenType {
    // Instructions
    "mov" = .INSTRUCTION,
    "bits" = .BITS,

    "ax" = .OPERAND,
    "bx" = .OPERAND,
    "cx" = .OPERAND,
    "dx" = .OPERAND,

    "al" = .OPERAND,
    "bl" = .OPERAND,
    "cl" = .OPERAND,
    "dl" = .OPERAND,

    "ah" = .OPERAND,
    "bh" = .OPERAND,
    "ch" = .OPERAND,
    "dh" = .OPERAND,

    "sp" = .OPERAND,
    "bp" = .OPERAND,
    "si" = .OPERAND,
    "di" = .OPERAND,
}

instruction_map := map[string]Instruction {
    "mov" = .MOV,
}



ILLEGAL :: "ILLEGAL"
MOV :: "mov"
COMMA :: ","
EOF :: "EOF"
SEMICOLON :: ";"
BITS :: "bits"



