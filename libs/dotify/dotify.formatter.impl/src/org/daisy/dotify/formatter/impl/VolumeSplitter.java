package org.daisy.dotify.formatter.impl;

/**
 * Provides a volume splitter.
 * 
 * @author Joel Håkansson
 *
 */
interface VolumeSplitter {

	/**
	 * Sets the number of sheets to distribute.
	 * @param sheets the total number of sheets
	 */
	void updateSheetCount(int sheets);

	/**
	 * Gets the number of sheets in a volume.
	 * 
	 * @param volIndex volume index, one-based
	 * @return returns the number of sheets in the volume
	 */
	public int sheetsInVolume(int volIndex);

	/**
	 * Tells the splitter to adjust the volume count, if required.
	 * @param sheets the total number of sheets
	 */
	void adjustVolumeCount(int sheets);
	
	/**
	 * Gets the number of volumes required according to this splitter.
	 * @return returns the number of volumes required
	 */
	int getVolumeCount();
}
