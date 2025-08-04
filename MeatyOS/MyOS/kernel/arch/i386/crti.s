/*
	crti.s – C Runtime Initialization
	- Contains the prologue (start) of constructor sections.
	- Used to mark the beginning of init sections such as:
		.init: Initialization code section
		.fini: Finalization code section
 */

.section .init
.global _init
.type _init, @function
_init:
	push %ebp
	movl %esp, %ebp
	/* gcc will nicely put the contents of crtbegin.o's .init section here. */

.section .fini
.global _fini
.type _fini, @function
_fini:
	push %ebp
	movl %esp, %ebp
	/* gcc will nicely put the contents of crtbegin.o's .fini section here. */