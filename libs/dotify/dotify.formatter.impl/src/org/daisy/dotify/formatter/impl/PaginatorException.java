package org.daisy.dotify.formatter.impl;

/**
 * Indicates a pagination problem.
 * 
 * @author Joel Håkansson
 */
class PaginatorException extends RuntimeException {

	/**
	 * 
	 */
	private static final long serialVersionUID = 8015133306865945283L;

	PaginatorException() {
	}

	PaginatorException(String message) {
		super(message);
	}

	PaginatorException(Throwable cause) {
		super(cause);
	}

	PaginatorException(String message, Throwable cause) {
		super(message, cause);
	}

}
