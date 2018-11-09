package org.daisy.dotify.api.embosser;

/**
 * Provides an unsupported paper exception
 * @author Joel Håkansson
 */
public class UnsupportedPaperException extends EmbosserFactoryException {

	/**
	 * 
	 */
	private static final long serialVersionUID = 2070661857330277739L;

	/**
	 * Constructs a new exception with {@code null} as its detail message.
	 * The cause is not initialized, and may subsequently be initialized by a
	 * call to {@link #initCause}.
	 */
	public UnsupportedPaperException() {
		super();
	}

	/**
	 * Constructs a new exception with the specified detail message.  The
	 * cause is not initialized, and may subsequently be initialized by
	 * a call to {@link #initCause}.
	 *
	 * @param   message   the detail message. The detail message is saved for
	 *          later retrieval by the {@link #getMessage()} method.
	 */
	public UnsupportedPaperException(String message) {
		super(message);
	}

	/**
	 * Constructs a new exception with the specified cause and a detail
	 * message of <code>(cause==null ? null : cause.toString())</code> (which
	 * typically contains the class and detail message of <code>cause</code>).
	 *
	 * @param  cause the cause (which is saved for later retrieval by the
	 *         {@link #getCause()} method).  (A <code>null</code> value is
	 *         permitted, and indicates that the cause is nonexistent or
	 *         unknown.)
	 */
	public UnsupportedPaperException(Throwable cause) {
		super(cause);
	}

	/**
	 * Constructs a new exception with the specified detail message and
	 * cause.  <p>Note that the detail message associated with
	 * {@code cause} is <i>not</i> automatically incorporated in
	 * this exception's detail message.
	 *
	 * @param  message the detail message (which is saved for later retrieval
	 *         by the {@link #getMessage()} method).
	 * @param  cause the cause (which is saved for later retrieval by the
	 *         {@link #getCause()} method).  (A <code>null</code> value is
	 *         permitted, and indicates that the cause is nonexistent or
	 *         unknown.)
	 */
	public UnsupportedPaperException(String message, Throwable cause) {
		super(message, cause);
	}

	/**
	 * Constructs a new exception with the specified detail message,
	 * cause, suppression enabled or disabled, and writable stack
	 * trace enabled or disabled.
	 *
	 * @param  message the detail message.
	 * @param cause the cause.  (A {@code null} value is permitted,
	 * and indicates that the cause is nonexistent or unknown.)
	 * @param enableSuppression whether or not suppression is enabled
	 *                          or disabled
	 * @param writableStackTrace whether or not the stack trace should
	 *                           be writable
	 */
	public UnsupportedPaperException(String message, Throwable cause, boolean enableSuppression, boolean writableStackTrace) {
		super(message, cause, enableSuppression, writableStackTrace);
	}

}
