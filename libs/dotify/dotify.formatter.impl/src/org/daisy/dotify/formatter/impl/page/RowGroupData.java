package org.daisy.dotify.formatter.impl.page;

import java.util.ArrayList;
import java.util.List;

class RowGroupData extends BlockProcessor {
	private List<RowGroup> data;
	
	RowGroupData() {
		this.data = null;
	}
	
	RowGroupData(RowGroupData template) {
		super(template);
		this.data = template.data==null?null:new ArrayList<>(template.data);
	}

	RowGroupData(RowGroupData template, int offset) {
		super(template);
		if (template.data==null) {
			this.data = null;
		} else if (template.data.size()>offset) {
			this.data = new ArrayList<>(template.data.subList(offset, template.data.size()));
		} else {
			this.data = new ArrayList<>();
		}
	}

	@Override
	protected void newRowGroupSequence(VerticalSpacing vs) {
		if (data!=null) {
			throw new IllegalStateException();
		} else {
			data = new ArrayList<>();
		}
	}

	@Override
	protected boolean hasSequence() {
		return data!=null;
	}

	@Override
	protected boolean hasResult() {
		return hasSequence() && !data.isEmpty();
	}

	@Override
	protected void addRowGroup(RowGroup rg) {
		data.add(rg);
	}
	
	List<RowGroup> getList() {
		return data;
	}
	
	int size() {
		return data==null?0:data.size();
	}
	
}