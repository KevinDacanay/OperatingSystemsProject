/*
	crtn.s – C Runtime Termination
	- Contains the epilogue (end) of constructor sections.
	- Used to close out the .init and .fini sections started by crti.s.
 */
.section .init
    /* gcc will nicely put the contents of crtend.o's .init section here */
	popl %ebp
	ret

.section .fini 
    /* gcc will nicely put the contents of crtend.o's .fini section here */
	popl %ebp
	ret

 