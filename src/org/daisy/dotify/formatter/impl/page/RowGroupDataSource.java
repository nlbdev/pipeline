package org.daisy.dotify.formatter.impl.page;

import java.util.Collections;
import java.util.List;

import org.daisy.dotify.common.splitter.DefaultSplitResult;
import org.daisy.dotify.common.splitter.SplitPointDataSource;
import org.daisy.dotify.common.splitter.SplitResult;
import org.daisy.dotify.common.splitter.Supplements;
import org.daisy.dotify.formatter.impl.core.Block;
import org.daisy.dotify.formatter.impl.core.BlockContext;
import org.daisy.dotify.formatter.impl.core.LayoutMaster;

class RowGroupDataSource implements SplitPointDataSource<RowGroup, RowGroupDataSource> {
	private static final Supplements<RowGroup> EMPTY_SUPPLEMENTS = new Supplements<RowGroup>() {
		@Override
		public RowGroup get(String id) {
			return null;
		}
	};
	private final LayoutMaster master;
	private final RowGroupData data;
	private final Supplements<RowGroup> supplements;
	private final VerticalSpacing vs;
	private final List<Block> blocks;
	private BlockContext bc;
	private int blockIndex;
	private boolean hyphenateLastLine;

	RowGroupDataSource(LayoutMaster master, BlockContext bc, List<Block> blocks, VerticalSpacing vs, Supplements<RowGroup> supplements) {
		this.master = master;
		this.bc = bc;
		this.data = new RowGroupData();
		this.blocks = blocks;
		this.supplements = supplements;
		this.vs = vs;
		this.blockIndex = 0;
		this.hyphenateLastLine = true;
	}
	
	RowGroupDataSource(RowGroupDataSource template) {
		this.master = template.master;
		this.bc = template.bc;
		this.data = new RowGroupData(template.data);
		this.blocks = template.blocks;
		this.supplements = template.supplements;
		this.vs = template.vs;
		this.blockIndex = template.blockIndex;
		this.hyphenateLastLine = template.hyphenateLastLine;
	}
	
	static RowGroupDataSource copyUnlessNull(RowGroupDataSource template) {
		return template==null?null:new RowGroupDataSource(template);
	}
	
	private RowGroupDataSource(LayoutMaster master, BlockContext bc, RowGroupData data, List<Block> blocks, Supplements<RowGroup> supplements, VerticalSpacing vs, int blockIndex) {
		this.master = master;
		this.bc = bc;
		this.data = data;
		if (supplements==null) {
			this.supplements = EMPTY_SUPPLEMENTS;
		} else {
			this.supplements = supplements;
		}
		this.vs = vs;
		this.blocks = blocks;
		this.blockIndex = blockIndex;
		this.hyphenateLastLine = true;
	}

	@Override
	public Supplements<RowGroup> getSupplements() {
		return supplements;
	}

	@Override
	public boolean hasElementAt(int index) {
		return ensureBuffer(index+1);
	}

	@Override
	public boolean isEmpty() {
		return this.data.size()==0 && blockIndex>=blocks.size() && !data.hasNextInBlock();
	}

	@Override
	public RowGroup get(int n) {
		if (!ensureBuffer(n+1)) {
			throw new IndexOutOfBoundsException("" + n);
		}
		return this.data.getList().get(n);
	}

	@Override
	public List<RowGroup> getRemaining() {
		ensureBuffer(-1);
		return this.data.getList().subList(0, data.size());
	}

	@Override
	public int getSize(int limit) {
		if (!ensureBuffer(limit))  {
			//we have buffered all elements
			return this.data.size();
		} else {
			return limit;
		}
	}

	VerticalSpacing getVerticalSpacing() {
		return vs;
	}
	
	BlockContext getContext() {
		return bc;
	}
	
	void setContext(BlockContext c) {
		this.bc = c;
	}
	
	void setHyphenateLastLine(boolean value) {
		this.hyphenateLastLine = value;
	}
	
	/**
	 * Ensures that there are at least index elements in the buffer.
	 * When index is -1 this method always returns false.
	 * @param index the index (or -1 to get all remaining elements)
	 * @return returns true if the index element was available, false otherwise
	 */
	private boolean ensureBuffer(int index) {
		while (index<0 || this.data.size()<index) {
			if (blockIndex>=blocks.size() && !data.hasNextInBlock()) {
				return false;
			}
			if (!data.hasNextInBlock()) {
				//get next block
				Block b = blocks.get(blockIndex);
				blockIndex++;
				data.loadBlock(master, b, bc);
			}
			data.processNextRowGroup(bc, !hyphenateLastLine && data.size()>=index-1);
		}
		return true;
	}

	@Override
	public SplitResult<RowGroup, RowGroupDataSource> splitInRange(int atIndex) {
		// TODO: rewrite this so that rendered tail data is discarded
		if (!ensureBuffer(atIndex)) {
			throw new IndexOutOfBoundsException("" + atIndex);
		}
		RowGroupDataSource tail = new RowGroupDataSource(master, bc, new RowGroupData(data, atIndex), blocks, supplements, vs, blockIndex);
		if (atIndex==0) {
			return new DefaultSplitResult<RowGroup, RowGroupDataSource>(Collections.emptyList(), tail);
		} else {
			return new DefaultSplitResult<RowGroup, RowGroupDataSource>(this.data.getList().subList(0, atIndex), tail);
		}
	}

	@Override
	public RowGroupDataSource createEmpty() {
		return new RowGroupDataSource(master, bc, Collections.emptyList(), vs, EMPTY_SUPPLEMENTS);
	}

	@Override
	public RowGroupDataSource getDataSource() {
		return this;
	}

}