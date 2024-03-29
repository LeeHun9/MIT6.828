	.text

/* Switch from current_thread to next_thread. Make next_thread
 * the current_thread, and set next_thread to 0.
 * Use eax as a temporary register; it is caller saved.
 */
	.globl thread_switch
thread_switch:
	/* YOUR CODE HERE */
	// save current thread state 
	pushal
	movl current_thread, %eax
	movl %esp, (%eax)

	// restore next_thread, set esp by next_thread
	movl next_thread, %eax
	movl %eax, current_thread
	movl (%eax), %esp
	popal

	movl $0, next_thread

	ret				/* pop return address from stack */