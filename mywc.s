//---------------------------------------------------------------------------
// mywc.s
//----------------------------------------------------------------------------
	
	.section .rodata
	
outputString:
	.string "%7ld %7ld %7ld\n" 
	
//------------------------------------------------------------------

	.section .data
	
lLineCount:
	.quad 0
lWordCount:
	.quad 0
lCharCount:
	.quad 0
iInWord:
	.word 0
//-------------------------------------------------------------------------

	.section .bss

iChar:
	.skip 4
	
//------------------------------------------------------------------------

	.section .text
	
	//--------------------------------------------------------------------
	// Write to stdout counts of how many lines, words, and characters are
	// in stdin. A word is a sequence of non-whitespace characters.
	// Whitespace is defined by the isspace() function. Return 0.
	//-------------------------------------------------------------------

	// Must be a multiple of 16
	.equ MAIN_STACK_BYTECOUNT, 16

	.equ EOF, -1

	.equ FALSE, 0

	.equ TRUE, 1
	
	.global main

main:

	// Prologue
	sub sp, sp, MAIN_STACK_BYTECOUNT
	str x30, [sp]

theLoop:	
	
	// if ((iChar = getchar()) == EOF) goto endTheLoop;
	bl getchar
	adr x1, iChar
	strb w0, [x1]
	cmp w0, EOF
	beq endTheLoop

	// lCharCount++
	adr x0, lCharCount
	ldr x1, [x0]
	add x1, x1, 1
	str x1, [x0] 

	// if (! isspace(iChar)) goto else;
	adr x1, iChar
	ldrb  w0, [x1]
	bl isspace
	cmp w0, FALSE
	beq else

	// if (! iInWord) goto endif1;
	adr x1, iInWord
	ldr w2, [x1]
	cmp w2, FALSE
	beq endif1

	// lWordCount++;
	adr x0, lWordCount
	ldr x1, [x0]
	add x1, x1, 1
	str x1, [x0]

	// iInWord = FALSE;
	mov w1, FALSE
	adr x2, iInWord
	str w1, [x2]

	// goto endif1;
	b endif1
	
else:	

	// if (iInWord) goto endif1;
	adr x1, iInWord
	ldr w2, [x1]
	cmp w2, TRUE
	beq endif1

	// iInWord = TRUE;
	mov w1, TRUE
	adr x2, iInWord
	str w1, [x2]

endif1:

	// if (iChar != '\n') goto endif2;
	adr x1, iChar
	ldr w2, [x1]
	cmp w2, '\n'
	bne endif2

	// lLineCount++;
	adr x0, lLineCount
	ldr x1, [x0]
        add x1, x1, 1
        str x1, [x0]
	
endif2:

	// goto theLoop
	b theLoop 
	
endTheLoop:	
	
	// if (! iInWord) goto endif3
	adr x0, iInWord
	ldr w3, [x0]
	cmp w3, FALSE
	beq endif3

	// lWordCount++
	adr x0, lWordCount
	ldr x1, [x0]
	add x1, x1, 1
	str x1, [x0]
	
endif3:	
	
	// printf("%71d %71d %71d\n", lLineCount, lWordCount, lCharCount)
	adr x0, outputString
	adr x1, lLineCount
	ldr x1, [x1]
	adr x2, lWordCount
	ldr x2, [x2]
	adr x3, lCharCount
	ldr x3, [x3]
	bl printf

	// Epilogue and return 0
	mov w0, 0
	ldr x30, [sp]
	add sp, sp, MAIN_STACK_BYTECOUNT
	ret

	.size main, (. - main)
