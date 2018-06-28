package org.daisy.dotify.formatter.impl.page;

import java.util.ArrayList;
import java.util.List;

import org.daisy.dotify.formatter.impl.core.Block;

class RowGroupSequence {
	private final List<Block> blocks;
	private final List<RowGroup> group;
	private final RowGroupSequenceStartPosition startPosition;

	public RowGroupSequence(RowGroupSequenceStartPosition startPosition) {
		this.blocks = new ArrayList<>();
		this.group = new ArrayList<RowGroup>();
		this.startPosition = startPosition;
	}
	
	/**
	 * Creates a deep copy of the supplied instance
	 * @param template the instance to copy
	 */
	RowGroupSequence(RowGroupSequence template) {
		this.blocks = new ArrayList<>(template.blocks);
		this.group = new ArrayList<>();
		for (RowGroup rg : template.group) {
			group.add(new RowGroup(rg));
		}
		this.startPosition = template.startPosition;
	}

	@Deprecated
	public List<RowGroup> getGroup() {
		return group;
	}
	
	List<Block> getBlocks() {
		return blocks;
	}

	RowGroup currentGroup() {
		if (group.isEmpty()) {
			return null;
		} else {
			return group.get(group.size()-1);
		}
	}
	
	RowGroupSequenceStartPosition getStartPosition() {
		return startPosition;
	}
}
