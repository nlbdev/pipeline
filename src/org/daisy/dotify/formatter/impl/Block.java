package org.daisy.dotify.formatter.impl;

import java.util.Stack;

import org.daisy.dotify.api.formatter.BlockPosition;
import org.daisy.dotify.api.formatter.FormattingTypes;
import org.daisy.dotify.formatter.impl.Segment.SegmentType;

/**
 * <p>Provides a block of rows and the properties associated with it.<p>
 * <p><b>Note that this class does not map directly to OBFL blocks.</b> 
 * OBFL has hierarchical blocks, which is represented by multiple
 * Block objects in sequence, a new one is created on each block boundary
 * transition.</p>
 * 
 * @author Joel Håkansson
 */

class Block implements Cloneable {
	private final String blockId;
	private FormattingTypes.BreakBefore breakBefore;
	private FormattingTypes.Keep keep;
	private int keepWithNext;
	private int keepWithPreviousSheets;
	private int keepWithNextSheets;
	private String id;
	private final Stack<Segment> segments;
	private RowDataProperties rdp;
	private BlockContentManager rdm;
	private BlockPosition verticalPosition;
	private BlockContext context;

	private Integer metaVolume = null, metaPage = null;
	
	Block(String blockId, RowDataProperties rdp) {
		this.breakBefore = FormattingTypes.BreakBefore.AUTO;
		this.keep = FormattingTypes.Keep.AUTO;
		this.keepWithNext = 0;
		this.keepWithPreviousSheets = 0;
		this.keepWithNextSheets = 0;
		this.id = "";
		this.blockId = blockId;
		this.segments = new Stack<Segment>();
		this.rdp = rdp;
		this.rdm = null;
		this.verticalPosition = null;
	}
	
	public void addSegment(Segment s) {
		segments.add(s);
	}

	public void addSegment(TextSegment s) {
		if (segments.size() > 0 && segments.peek().getSegmentType() == SegmentType.Text) {
			TextSegment ts = ((TextSegment) segments.peek());
			if (ts.getTextProperties().equals(s.getTextProperties())) {
				// Logger.getLogger(this.getClass().getCanonicalName()).finer("Appending chars to existing text segment.");
				ts.setText(ts.getText() + "" + s.getText());
				return;
			}
		}
		segments.push(s);
	}
	
	public FormattingTypes.BreakBefore getBreakBeforeType() {
		return breakBefore;
	}
	
	public FormattingTypes.Keep getKeepType() {
		return keep;
	}
	
	public int getKeepWithNext() {
		return keepWithNext;
	}
	
	public int getKeepWithPreviousSheets() {
		return keepWithPreviousSheets;
	}
	
	public int getKeepWithNextSheets() {
		return keepWithNextSheets;
	}
	
	public String getIdentifier() {
		return id;
	}

	public BlockPosition getVerticalPosition() {
		return verticalPosition;
	}

	public void setBreakBeforeType(FormattingTypes.BreakBefore breakBefore) {
		this.breakBefore = breakBefore;
	}
	
	public void setKeepType(FormattingTypes.Keep keep) {
		this.keep = keep;
	}
	
	public void setKeepWithNext(int keepWithNext) {
		this.keepWithNext = keepWithNext;
	}
	
	public void setKeepWithPreviousSheets(int keepWithPreviousSheets) {
		this.keepWithPreviousSheets = keepWithPreviousSheets;
	}
	
	public void setKeepWithNextSheets(int keepWithNextSheets) {
		this.keepWithNextSheets = keepWithNextSheets;
	}
	
	public void setIdentifier(String id) {
		this.id = id;
	}

	/**
	 * Gets the vertical position of the block on page, or null if none is
	 * specified
	 */
	public void setVerticalPosition(BlockPosition vertical) {
		this.verticalPosition = vertical;
	}

	public String getBlockIdentifier() {
		return blockId;
	}
	
	public BlockContentManager getBlockContentManager(BlockContext context) {
		if (!context.equals(this.context)) {
			//invalidate, if existing
			rdm = null;
		}
		this.context = context;
		if (rdm==null || rdm.isVolatile()) {
			rdm = new BlockContentManager(context.getFlowWidth(), segments, rdp, context.getRefs(),
					DefaultContext.from(context.getContext()).metaVolume(metaVolume).metaPage(metaPage).build(),
					context.getFcontext());
		}
		return rdm;
	}

	public void setMetaVolume(Integer metaVolume) {
		this.metaVolume = metaVolume;
	}

	public void setMetaPage(Integer metaPage) {
		this.metaPage = metaPage;
	}
	
	public RowDataProperties getRowDataProperties() {
		return rdp;
	}
	
	public void setRowDataProperties(RowDataProperties value) {
		rdp = value;
	}

	@Override
	public Object clone() {
    	try {
	    	Block newObject = (Block)super.clone();
	    	/* Probably no need to deep copy clone segments
	    	if (this.segments!=null) {
	    		newObject.segments = (Stack<Segment>)this.segments.clone();
	    	}*/
	    	return newObject;
    	} catch (CloneNotSupportedException e) { 
    	    // this shouldn't happen, since we are Cloneable
    	    throw new InternalError();
    	}
    }

}
