package org.daisy.dotify.formatter.impl.row;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import org.daisy.dotify.api.formatter.Marker;
import org.daisy.dotify.common.text.StringTools;
import org.daisy.dotify.formatter.impl.common.FormatterCoreContext;
import org.daisy.dotify.formatter.impl.search.DefaultContext;

public abstract class AbstractBlockContentManager implements BlockStatistics {
	//Immutable
	protected final int flowWidth;
	protected final RowDataProperties rdp;
	private final MarginProperties leftParent;
	private final MarginProperties rightParent;
	protected final MarginProperties leftMargin;
	protected final MarginProperties rightMargin;
	private final List<RowImpl> collapsiblePreContentRows;
	private final List<RowImpl> innerPreContentRows;
	private final List<RowImpl> postContentRows;
	private final List<RowImpl> skippablePostContentRows;
	private final int minWidth;
	
	//Mutable
	protected final FormatterCoreContext fcontext;
	
	AbstractBlockContentManager(int flowWidth, RowDataProperties rdp, FormatterCoreContext fcontext) {
		this(flowWidth, rdp, fcontext, null);
	}
	
	protected AbstractBlockContentManager(int flowWidth, RowDataProperties rdp, FormatterCoreContext fcontext, Integer minWidth) {
		this.flowWidth = flowWidth;
		this.leftParent = rdp.getLeftMargin().buildMarginParent(fcontext.getSpaceCharacter());
		this.rightParent = rdp.getRightMargin().buildMarginParent(fcontext.getSpaceCharacter());
		this.leftMargin = rdp.getLeftMargin().buildMargin(fcontext.getSpaceCharacter());
		this.rightMargin = rdp.getRightMargin().buildMargin(fcontext.getSpaceCharacter());
		this.fcontext = fcontext;
		this.rdp = rdp;
		this.collapsiblePreContentRows = makeCollapsiblePreContentRows(rdp, leftParent, rightParent);	
		this.innerPreContentRows = makeInnerPreContentRows();
		this.minWidth = minWidth==null ? flowWidth-leftMargin.getContent().length()-rightMargin.getContent().length() : minWidth;

		List<RowImpl> postContentRowsBuilder = new ArrayList<>();
		List<RowImpl> skippablePostContentRowsBuilder = new ArrayList<>();
		MarginProperties margin = new MarginProperties(leftMargin.getContent()+StringTools.fill(fcontext.getSpaceCharacter(), rdp.getTextIndent()), leftMargin.isSpaceOnly());
		if (rdp.getTrailingDecoration()==null) {
			if (leftMargin.isSpaceOnly() && rightMargin.isSpaceOnly()) {
				for (int i=0; i<rdp.getInnerSpaceAfter(); i++) {
					skippablePostContentRowsBuilder.add(rdp.configureNewEmptyRowBuilder(margin, rightMargin).build());
				}
			} else {
				for (int i=0; i<rdp.getInnerSpaceAfter(); i++) {
					postContentRowsBuilder.add(rdp.configureNewEmptyRowBuilder(margin, rightMargin).build());
				}
			}
		} else {
			for (int i=0; i<rdp.getInnerSpaceAfter(); i++) {
				postContentRowsBuilder.add(rdp.configureNewEmptyRowBuilder(margin, rightMargin).build());
			}
			postContentRowsBuilder.add(makeDecorationRow(flowWidth, rdp.getTrailingDecoration(), leftParent, rightParent));
		}
		
		if (leftParent.isSpaceOnly() && rightParent.isSpaceOnly()) {
			for (int i=0; i<rdp.getOuterSpaceAfter();i++) {
				skippablePostContentRowsBuilder.add(rdp.configureNewEmptyRowBuilder(leftParent, rightParent).build());
			}
		} else {
			for (int i=0; i<rdp.getOuterSpaceAfter();i++) {
				postContentRowsBuilder.add(rdp.configureNewEmptyRowBuilder(leftParent, rightParent).build());
			}
		}
		this.postContentRows = Collections.unmodifiableList(postContentRowsBuilder);
		this.skippablePostContentRows = Collections.unmodifiableList(skippablePostContentRowsBuilder);
	}
	
	protected AbstractBlockContentManager(AbstractBlockContentManager template) {
		this.flowWidth = template.flowWidth;
		this.rdp = template.rdp;
		this.leftParent = template.leftParent;
		this.rightParent = template.rightParent;
		this.leftMargin = template.leftMargin;
		this.rightMargin = template.rightMargin;
		this.collapsiblePreContentRows = template.collapsiblePreContentRows;
		this.innerPreContentRows = template.innerPreContentRows;
		this.postContentRows = template.postContentRows;
		this.skippablePostContentRows = template.skippablePostContentRows;
		this.minWidth = template.minWidth;
		// FIXME: fcontext is mutable, but mutating is related to DOM creation, and we assume for now that DOM creation is NOT going on when rendering has begun.
		this.fcontext = template.fcontext;
	}
	
	public abstract AbstractBlockContentManager copy();
	
	public abstract void setContext(DefaultContext context);
    
    /**
     * Returns true if the manager has more rows.
     * @return returns true if there are more rows, false otherwise
     */
    public abstract boolean hasNext();
    
    /**
     * Gets the next row from the manager with the specified width
     * @return returns the next row
     */
    public abstract RowImpl getNext();

	/**
	 * Returns true if this manager supports rows with variable maximum
	 * width, false otherwise.
	 * @return true if variable maximum width is supported, false otherwise
	 */
	public abstract boolean supportsVariableWidth();

    /**
     * Resets the state of the content manager to the first row.
     */
    public abstract void reset();

	private static List<RowImpl> makeCollapsiblePreContentRows(RowDataProperties rdp, MarginProperties leftParent, MarginProperties rightParent) {
		List<RowImpl> ret = new ArrayList<>();
		for (int i=0; i<rdp.getOuterSpaceBefore();i++) {
			RowImpl row = new RowImpl.Builder("").leftMargin(leftParent).rightMargin(rightParent)
					.rowSpacing(rdp.getRowSpacing())
					.adjustedForMargin(true)
					.build();
			ret.add(row);
		}
		return Collections.unmodifiableList(ret);
	}
	
	private List<RowImpl> makeInnerPreContentRows() {
		ArrayList<RowImpl> ret = new ArrayList<>();
		if (rdp.getLeadingDecoration()!=null) {
			ret.add(makeDecorationRow(flowWidth, rdp.getLeadingDecoration(), leftParent, rightParent));
		}
		for (int i=0; i<rdp.getInnerSpaceBefore(); i++) {
			MarginProperties margin = new MarginProperties(leftMargin.getContent()+StringTools.fill(fcontext.getSpaceCharacter(), rdp.getTextIndent()), leftMargin.isSpaceOnly());
			ret.add(rdp.configureNewEmptyRowBuilder(margin, rightMargin).build());
		}
		return Collections.unmodifiableList(ret);
	}
	
	protected RowImpl makeDecorationRow(int flowWidth, SingleLineDecoration d, MarginProperties leftParent, MarginProperties rightParent) {
		int w = flowWidth - rightParent.getContent().length() - leftParent.getContent().length();
		int aw = w-d.getLeftCorner().length()-d.getRightCorner().length();
		RowImpl row = new RowImpl.Builder(d.getLeftCorner() + StringTools.fill(d.getLinePattern(), aw) + d.getRightCorner())
				.leftMargin(leftParent)
				.rightMargin(rightParent)
				.alignment(rdp.getAlignment())
				.rowSpacing(rdp.getRowSpacing())
				.adjustedForMargin(true)
				.build();
		return row;
	}

	public MarginProperties getLeftMarginParent() {
		return leftParent;
	}

	public MarginProperties getRightMarginParent() {
		return rightParent;
	}

	public List<RowImpl> getCollapsiblePreContentRows() {
		return collapsiblePreContentRows;
	}
	
	public boolean hasCollapsiblePreContentRows() {
		return !collapsiblePreContentRows.isEmpty();
	}

	public List<RowImpl> getInnerPreContentRows() {
		return innerPreContentRows;
	}
	
	public boolean hasInnerPreContentRows() {
		return !innerPreContentRows.isEmpty();
	}

	public List<RowImpl> getPostContentRows() {
		return postContentRows;
	}
	
	public boolean hasPostContentRows() {
		return !postContentRows.isEmpty();
	}
	
	public List<RowImpl> getSkippablePostContentRows() {
		return skippablePostContentRows;
	}
	
	public boolean hasSkippablePostContentRows() {
		return !skippablePostContentRows.isEmpty();
	}
	
	@Override
	public int getMinimumAvailableWidth() {
		return minWidth;
	}

	/**
	 * Get markers that are not attached to a row, i.e. markers that proceeds any text contents
	 * @return returns markers that proceeds this FlowGroups text contents
	 */
	public abstract List<Marker> getGroupMarkers();
	
	public abstract List<String> getGroupAnchors();
	
}
