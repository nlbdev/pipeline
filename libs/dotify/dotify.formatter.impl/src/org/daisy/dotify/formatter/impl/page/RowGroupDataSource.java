package org.daisy.dotify.formatter.impl.page;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import org.daisy.dotify.common.splitter.DefaultSplitResult;
import org.daisy.dotify.common.splitter.SplitPointDataSource;
import org.daisy.dotify.common.splitter.SplitResult;
import org.daisy.dotify.common.splitter.Supplements;
import org.daisy.dotify.formatter.impl.core.Block;
import org.daisy.dotify.formatter.impl.core.BlockContext;
import org.daisy.dotify.formatter.impl.core.LayoutMaster;

class RowGroupDataSource extends BlockProcessor implements SplitPointDataSource<RowGroup, RowGroupDataSource> {
	private static final Supplements<RowGroup> EMPTY_SUPPLEMENTS = new Supplements<RowGroup>() {
		@Override
		public RowGroup get(String id) {
			return null;
		}
	};
	private final LayoutMaster master;
	private final Supplements<RowGroup> supplements;
	private final RowGroupSequenceStartPosition startPos;
	private final List<Block> blocks;
	private List<RowGroup> groups;
	private BlockContext bc;
	private int blockIndex;
	private boolean hyphenateLastLine;

	RowGroupDataSource(LayoutMaster master, BlockContext bc, List<Block> blocks, RowGroupSequenceStartPosition startPos, Supplements<RowGroup> supplements) {
		super();
		this.master = master;
		this.bc = bc;
		this.groups = null;
		this.blocks = blocks;
		this.supplements = supplements;
		this.startPos = startPos;
		this.blockIndex = 0;
		this.hyphenateLastLine = true;
	}

	RowGroupDataSource(RowGroupDataSource template) {
		this(template, 0);
	}
	
	RowGroupDataSource(RowGroupDataSource template, int offset) {
		super(template);
		this.master = template.master;
		this.bc = template.bc;
		if (template.groups==null) {
			this.groups = null;
		} else if (template.groups.size()>offset) {
			this.groups = new ArrayList<>(
					offset>0?template.groups.subList(offset, template.groups.size()):template.groups);
		} else {
			this.groups = new ArrayList<>();
		}
		this.blocks = template.blocks;
		this.supplements = template.supplements;
		this.startPos = template.startPos;
		this.blockIndex = template.blockIndex;
		this.hyphenateLastLine = template.hyphenateLastLine;
	}
	
	static RowGroupDataSource copyUnlessNull(RowGroupDataSource template) {
		return template==null?null:new RowGroupDataSource(template);
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
		return this.groupSize()==0 && blockIndex>=blocks.size() && !hasNextInBlock();
	}

	@Override
	public RowGroup get(int n) {
		if (!ensureBuffer(n+1)) {
			throw new IndexOutOfBoundsException("" + n);
		}
		return this.groups.get(n);
	}

	@Override
	public List<RowGroup> getRemaining() {
		ensureBuffer(-1);
		if (this.groups==null) {
			return Collections.emptyList();
		} else {
			return this.groups.subList(0, groupSize());
		}
	}

	@Override
	public int getSize(int limit) {
		if (!ensureBuffer(limit))  {
			//we have buffered all elements
			return this.groupSize();
		} else {
			return limit;
		}
	}

	RowGroupSequenceStartPosition getStartPosition() {
		return startPos;
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
		while (index<0 || this.groupSize()<index) {
			if (blockIndex>=blocks.size() && !hasNextInBlock()) {
				return false;
			}
			if (!hasNextInBlock()) {
				//get next block
				Block b = blocks.get(blockIndex);
				blockIndex++;
				loadBlock(master, b, bc);
			}
			processNextRowGroup(bc, !hyphenateLastLine && groupSize()>=index-1);
		}
		return true;
	}

	@Override
	public SplitResult<RowGroup, RowGroupDataSource> splitInRange(int atIndex) {
		// TODO: rewrite this so that rendered tail data is discarded
		if (!ensureBuffer(atIndex)) {
			throw new IndexOutOfBoundsException("" + atIndex);
		}
		RowGroupDataSource tail = new RowGroupDataSource(this, atIndex);
		tail.hyphenateLastLine = true;
		if (atIndex==0) {
			return new DefaultSplitResult<RowGroup, RowGroupDataSource>(Collections.emptyList(), tail);
		} else {
			return new DefaultSplitResult<RowGroup, RowGroupDataSource>(this.groups.subList(0, atIndex), tail);
		}
	}

	@Override
	public RowGroupDataSource createEmpty() {
		return new RowGroupDataSource(master, bc, Collections.emptyList(), startPos, EMPTY_SUPPLEMENTS);
	}

	@Override
	public RowGroupDataSource getDataSource() {
		return this;
	}

	@Override
	protected void newRowGroupSequence(RowGroupSequenceStartPosition startPos) {
		if (groups!=null) {
			throw new IllegalStateException();
		} else {
			groups = new ArrayList<>();
		}
	}

	@Override
	protected boolean hasSequence() {
		return groups!=null;
	}

	@Override
	protected boolean hasResult() {
		return hasSequence() && !groups.isEmpty();
	}

	@Override
	protected void addRowGroup(RowGroup rg) {
		groups.add(rg);
	}
	
	int groupSize() {
		return groups==null?0:groups.size();
	}
}
