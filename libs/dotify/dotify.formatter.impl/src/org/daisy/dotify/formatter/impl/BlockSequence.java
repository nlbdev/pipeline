package org.daisy.dotify.formatter.impl;

import org.daisy.dotify.api.formatter.FormatterSequence;
import org.daisy.dotify.api.formatter.SequenceProperties;

/**
 * Provides an interface for a sequence of block contents.
 * 
 * @author Joel Håkansson
 */
class BlockSequence extends FormatterCoreImpl implements FormatterSequence {
	private static final long serialVersionUID = -6105005856680272131L;
	private final LayoutMaster master;
	private final SequenceProperties props;
	
	public BlockSequence(FormatterContext fc, SequenceProperties props, LayoutMaster master) {
		super(fc);
		this.props = props;
		this.master = master;
	}

	/**
	 * Gets the layout master for this sequence
	 * @return returns the layout master for this sequence
	 */
	public LayoutMaster getLayoutMaster() {
		return master;
	}

	/**
	 * Get the initial page number, i.e. the number that the first page in the sequence should have
	 * @return returns the initial page number, or null if no initial page number has been specified
	 */
	public Integer getInitialPageNumber() {
		return props.getInitialPageNumber();
	}
	
	public SequenceProperties getSequenceProperties() {
		return props;
	}

}
