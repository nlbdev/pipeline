package org.daisy.dotify.formatter.impl.row;

public interface BlockStatistics {
	
	/**
	 * Gets the number of forced line breaks.
	 * @return the number of forced line breaks
	 */
	int getForceBreakCount();
	
	/**
	 * Gets the minimum width available for content (excluding margins)
	 * @return returns the available width, in characters
	 */
	int getMinimumAvailableWidth();
	
	/**
	 * Gets the number of rows produced.
	 * @return the number of rows produced
	 */
	int getRowCount();

}
