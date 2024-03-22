package sim

InstructionInfo :: struct {
	byte, mask: u8,
}


InstructionType :: enum {
	// MOVs
	MOV_REG_OR_MEM_TO_REG, // Register/memory to/from register
	MOV_IMM_TO_REG_OR_MEM, // Immediate to register/memory 
	MOV_IMM_TO_REG, // Immediate to register/memory 

	// ADDs
	ADD_REG_OR_MEM_WITH_REG_TO_EITHER, // Register/memory with register either
	ADD_IMM_TI_REF_OR_MEM, // Immediate to register/memory
	ADD_IMM_TO_ACCU, // Immediate to register/memory

	// SUBs
	SUB_REG_OR_MEM_AND_REG_TO_EITHER, // Reg/memory and register to either
	SUB_IMM_FROM_REG_OR_MEM, // Immediate from register/memory
	SUB_IMM_FROM_ACCU, // immediate from accumulator

	// CMPs
	CMP_REG_OR_MEM_AND_REG, // Register/memory and register
	CMP_IMM_WITH_REG_OR_MEM, // Immediate with register/memory
	CMP_IMM_WITH_ACCU, // Immediate with accumulator
    
    // JMPs
	JUMP_ON, // This type serves as a base enum for all the instruction which do jumping based on a condition

    // Conditional JMPs
    JO, // Jump on overflow - 0b0111 0000
    JNO,// Jump on not overflow - 0b0111 0001
    JB_OR_JNAE, // Jump on below/not above or equal - 0b0111 0010
    JNB_OR_JAE,// Jump on not below/above or equal - 0b0111 0010
    JZ_OR_JE, // Jump on equal/zero - 0b0111 0100
    JNE_OR_JNZ,// jump on not equal/not zero - 0b0111 0101
    JL_OR_JNGE, // Jump on less/not greater or equal - 0b0111 1100
    JLE_OR_JNG,// Jump on less or equal/not greater - 0b0111 1110
    JBE_OR_JNA,// Jump on below or equal/not above - 0b0111 0110
    JP_OR_JPE, // Jump on parity/parity even - 0b0111 1010
    JS, // Jump on sign - 0b0111 1000
    JNL_OR_JGE,// Jump on not less/greater or equal - 0b0111 1101
    JNLE_OR_JG, // Jump on not less or equal/greater - 0b0111 1111
    JNBE_OR_JA, // jump on not below or equal/above - 0b0111
    JNP_OR_JPO,// Jump on not par/par odd - 0b0111
    JNS,// Jump on not sign - 0b0111
    JCXZ, // Jump on CX Zero. THIS ONE IS AN EXCEPTION. HAS DIFFERENT BITFIELD THAT PREVIOUS ONES.

    // LOOPs
    LOOP, // Loop CX times
    LOOPZ_OR_LOOPE, // Loop while zero/equal
    LOOPNZ_OR_LOOPNE, // Loop while not zero/equal
}



// Lookup table containing bit field values of a first byte of different instructions.
Instruction_Bytes :: [InstructionType]InstructionInfo {
	// MOVs
	.MOV_REG_OR_MEM_TO_REG             = InstructionInfo{0b10001000, 0b11111100},
	.MOV_IMM_TO_REG_OR_MEM             = InstructionInfo{0b11000110, 0b11111110},
	.MOV_IMM_TO_REG                    = InstructionInfo{0b10110000, 0b11110000},

	// ADDs
	.ADD_REG_OR_MEM_WITH_REG_TO_EITHER = InstructionInfo{0b00000000, 0b11111100},
	.ADD_IMM_TI_REF_OR_MEM             = InstructionInfo{0b10000000, 0b11111100},
	.ADD_IMM_TO_ACCU                   = InstructionInfo{0b00000100, 0b11111110},

	// SUBs
	.SUB_REG_OR_MEM_AND_REG_TO_EITHER  = InstructionInfo{0b00101000, 0b11111100},
	.SUB_IMM_FROM_REG_OR_MEM           = InstructionInfo{0b10000000, 0b11111100},
	.SUB_IMM_FROM_ACCU                 = InstructionInfo{0b00101100, 0b11111110},

	// CMPs
	.CMP_REG_OR_MEM_AND_REG            = InstructionInfo{0b00111000, 0b11111100},
	.CMP_IMM_WITH_REG_OR_MEM           = InstructionInfo{0b10000000, 0b11111100},
	.CMP_IMM_WITH_ACCU                 = InstructionInfo{0b00111100, 0b11111110},
	.JUMP_ON                           = InstructionInfo{0b00111100, 0b11111110},
}

instruction_bytes := Instruction_Bytes

is_byte_instruction_type :: proc(byte: u8, type: InstructionType) -> bool {
	info := instruction_bytes[type]
	return (byte & info.mask) == info.byte
}
