package org.daisy.dotify.formatter.impl;

import java.util.List;

import org.daisy.dotify.common.split.SplitPointDataList;
import org.daisy.dotify.common.split.SplitPointDataSource;
import org.daisy.dotify.common.split.Supplements;

class RowGroupDataSource implements SplitPointDataSource<RowGroup> {
	//for now, use a list internally
	private final SplitPointDataSource<RowGroup> source;
	
	RowGroupDataSource(List<RowGroup> group, Supplements<RowGroup> supplements) {
		this.source = new SplitPointDataList<>(group, supplements);
	}
	
	RowGroupDataSource(SplitPointDataSource<RowGroup> source) {
		this.source = source;
	}

	@Override
	public RowGroup get(int index) {
		return source.get(index);
	}

	@Override
	public List<RowGroup> head(int toIndex) {
		return source.head(toIndex);
	}

	@Override
	public List<RowGroup> getRemaining() {
		return source.getRemaining();
	}

	@Override
	public SplitPointDataSource<RowGroup> tail(int fromIndex) {
		return new RowGroupDataSource(source.tail(fromIndex));
	}

	@Override
	public boolean hasElementAt(int index) {
		return source.hasElementAt(index);
	}

	@Override
	public int getSize(int limit) {
		return source.getSize(limit);
	}

	@Override
	public boolean isEmpty() {
		return source.isEmpty();
	}

	@Override
	public Supplements<RowGroup> getSupplements() {
		return source.getSupplements();
	}

}
