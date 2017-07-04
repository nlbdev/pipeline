package org.daisy.dotify.formatter.impl;

import java.util.ArrayList;
import java.util.List;

/**
 * Provides a manager for sheet groups (consecutive sheets without manual volume breaks
 * inside).
 * 
 * @author Joel Håkansson
 */
class SheetGroupManager {
	private final SplitterLimit splitterLimit;
	private final List<SheetGroup> groups;
	private int indexInGroup = 0;
	private int index = 0;
	
	/**
	 * Creates a new sheet group manager
	 * @param splitterLimit the splitter limit
	 */
	SheetGroupManager(SplitterLimit splitterLimit) {
		this.groups = new ArrayList<>();
		this.splitterLimit = splitterLimit;
	}

	
	/**
	 * Creates a new sheet group, adds it to the manager and returns it.
	 * @return returns the new sheet group
	 */
	SheetGroup add() {
		SheetGroup ret = new SheetGroup();
		ret.setSplitter(new EvenSizeVolumeSplitter(new SplitterLimit() {
			private final int groupIndex = groups.size();
			
			@Override
			public int getSplitterLimit(int volume) {
				int offset = 0;
				for (int i=0; i<groupIndex; i++) {
					offset += groups.get(i).getSplitter().getVolumeCount();
				}
				return splitterLimit.getSplitterLimit(volume + offset);
			}
		}));
		groups.add(ret);
		return ret;
	}
		
	/**
	 * Gets the sheet group at the given index, zero based.
	 * @param index, zero based
	 * @return returns the sheet group
	 */
	SheetGroup atIndex(int index) {
		return groups.get(index);
	}
	
	/**
	 * Gets the number of groups in the manager.
	 * @return the size
	 */
	int size() {
		return groups.size();
	}
	
	/**
	 * Gets the currently active group.
	 * @return returns the current group
	 */
	SheetGroup currentGroup() {
		return groups.get(index);
	}

	/**
	 * Informs the manager that a new volume has started. If the current group's splitter
	 * has reached its target number of volumes (as counted by previous calls to this method),
	 * the group following that is activated. 
	 * 
	 */
	void nextVolume() {
		if (indexInGroup+1>=currentGroup().getSplitter().getVolumeCount()) {
			nextGroup();
			indexInGroup = 0;
		} else {
			indexInGroup++;
		}
	}
	
	private void nextGroup() {
		index++;
		if (groups.size()<index) {
			throw new IllegalStateException("No more groups.");
		}
	}

	/**
	 * Returns true if the current volume is the last according to the current group's splitter.
	 * @return returns true if the current volume is the last, false otherwise
	 */
	boolean lastInGroup() {
		return indexInGroup==currentGroup().getSplitter().getVolumeCount();
	}

	/**
	 * Gets the number of sheets in the current volume, according the the group's splitter.
	 * @return
	 */
	int sheetsInCurrentVolume() {
		return currentGroup().getSplitter().sheetsInVolume(1+indexInGroup);
	}
	
	/**
	 * Resets the state of this manager.
	 */
	void resetAll() {
		for (SheetGroup g : groups) {
			g.reset();
		}
		index = 0;
		indexInGroup = 0;
	}
	
	/**
	 * Returns true if there is content left or left behind.
	 * @return returns true if the manager has content, false otherwise
	 */
	boolean hasNext() {
		for (SheetGroup g : groups) {
			if (g.hasNext()) {
				return true;
			}
		}
		return false;
	}
	
	/**
	 * Updates the sheet count in every group.
	 */
	void updateAll() {
		for (SheetGroup g : groups) {
			g.getSplitter().updateSheetCount(g.countTotalSheets());
		}
	}
	
	/**
	 * Adjusts the volume count in every group (if needed).
	 */
	void adjustVolumeCount() {
		for (SheetGroup g : groups) {
			if (g.hasNext()) {
				g.getSplitter().adjustVolumeCount(g.countTotalSheets());
			}
		}
	}
	
	/**
	 * Counts the total number of sheets.
	 * @return returns the sheet count
	 */
	int countTotalSheets() {
		int ret = 0;
		for (SheetGroup g : groups) {
			ret += g.countTotalSheets();
		}
		return ret;
	}
	
	/**
	 * Counts the remaining sheets.
	 * @return returns the number of remaining sheets
	 */
	int countRemainingSheets() {
		int ret = 0;
		for (SheetGroup g : groups) {
			ret += g.getUnits().size();
		}
		return ret;
	}
	
	/**
	 * Counts the remaining pages.
	 * @return returns the number of remaining pages
	 */
	int countRemainingPages() {
		int ret = 0;
		for (SheetGroup g : groups) {
			ret += VolumeProvider.countPages(g.getUnits());
		}
		return ret;
	}
	
	/**
	 * Gets the total number of volumes.
	 * @return returns the total number of volumes
	 */
	int getVolumeCount() {
		int ret = 0;
		for (SheetGroup g : groups) {
			ret += g.getSplitter().getVolumeCount();
		}
		return ret;
	}

}
