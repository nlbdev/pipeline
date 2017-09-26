package org.daisy.dotify.formatter.impl;

import java.util.HashMap;
import java.util.logging.Logger;
import java.util.Map;

class EvenSizeVolumeSplitter implements VolumeSplitter {
	private static final Logger logger = Logger.getLogger(EvenSizeVolumeSplitter.class.getCanonicalName());
	private EvenSizeVolumeSplitterCalculator sdc;
	private final SplitterLimit splitterMax;
	int volumeOffset = 0;
	
	/*
	 * Assuming that updateSheetCount() is called after each iteration, and that adjustVolumeCount()
	 * is called if and only if some sheets did not fit within the predetermined volumes. This
	 * allows us to keep track of which split suggestions resulted in a successful split. We make
	 * use of this information in order to not get into an endless loop while looking for the
	 * optimal number of volumes.
	 */
	private boolean sheetsFitInVolumes;
	private Map<EvenSizeVolumeSplitterCalculator,Boolean> previouslyTried = new HashMap<>();
	
	EvenSizeVolumeSplitter(SplitterLimit splitterMax) {
		this.splitterMax = splitterMax;
	}
	
	@Override
	public void updateSheetCount(int sheets) {
		if (sdc == null) {
			sdc = new EvenSizeVolumeSplitterCalculator(sheets, splitterMax, volumeOffset);
		} else {
			previouslyTried.put(sdc, sheetsFitInVolumes);
			if (!sheetsFitInVolumes) {
			
				// Try with adjusted number of sheets
				EvenSizeVolumeSplitterCalculator esc = new EvenSizeVolumeSplitterCalculator(sheets, splitterMax, volumeOffset);
				if (!previouslyTried.containsKey(esc) || previouslyTried.get(esc)) {
					sdc = esc;
				} else {
				
					// Try increasing the volume count
					volumeOffset++;
					sdc = new EvenSizeVolumeSplitterCalculator(sheets, splitterMax, volumeOffset);
				}
			} else if (volumeOffset > 0) {
			
				// Try decreasing the volume count again
				EvenSizeVolumeSplitterCalculator esc = new EvenSizeVolumeSplitterCalculator(sheets, splitterMax, volumeOffset - 1);
				if (!previouslyTried.containsKey(esc)) {
					volumeOffset--;
					sdc = esc;
				}
			}
		}
		sheetsFitInVolumes = true;
	}
	
	@Override
	public void adjustVolumeCount(int sheets) {
		sheetsFitInVolumes = false;
	}

	@Override
	public int sheetsInVolume(int volIndex) {
		return sdc.sheetsInVolume(volIndex);
	}

	@Override
	public int getVolumeCount() {
		return sdc.getVolumeCount();
	}
}
