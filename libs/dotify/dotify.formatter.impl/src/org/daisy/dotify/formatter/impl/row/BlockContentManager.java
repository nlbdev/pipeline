package org.daisy.dotify.formatter.impl.row;

import static java.lang.Math.min;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.NoSuchElementException;
import java.util.regex.Pattern;

import org.daisy.dotify.api.formatter.Context;
import org.daisy.dotify.api.formatter.FormattingTypes;
import org.daisy.dotify.api.formatter.Marker;
import org.daisy.dotify.api.translator.BrailleTranslatorResult;
import org.daisy.dotify.api.translator.Translatable;
import org.daisy.dotify.api.translator.TranslationException;
import org.daisy.dotify.common.text.StringTools;
import org.daisy.dotify.formatter.impl.common.FormatterCoreContext;
import org.daisy.dotify.formatter.impl.search.CrossReferenceHandler;
import org.daisy.dotify.formatter.impl.search.DefaultContext;
import org.daisy.dotify.formatter.impl.segment.AnchorSegment;
import org.daisy.dotify.formatter.impl.segment.Evaluate;
import org.daisy.dotify.formatter.impl.segment.LeaderSegment;
import org.daisy.dotify.formatter.impl.segment.MarkerSegment;
import org.daisy.dotify.formatter.impl.segment.PageNumberReferenceSegment;
import org.daisy.dotify.formatter.impl.segment.Segment;
import org.daisy.dotify.formatter.impl.segment.Segment.SegmentType;
import org.daisy.dotify.formatter.impl.segment.TextSegment;

/**
 * BlockHandler is responsible for breaking blocks of text into rows. BlockProperties
 * such as list numbers, leaders and margins are resolved in the process. The input
 * text is filtered using the supplied StringFilter before breaking into rows, since
 * the length of the text could change.
 * 
 * @author Joel Håkansson
 */
public class BlockContentManager extends AbstractBlockContentManager {
	private static final Pattern softHyphenPattern  = Pattern.compile("\u00ad");
	private static final Pattern trailingWsBraillePattern = Pattern.compile("[\\s\u2800]+\\z");

	private final List<RowImpl> rows;
	private final CrossReferenceHandler refs;
	private final int available;
	private Context context;
	private final List<Segment> segments;
	private final LeaderManager leaderManager;

	private RowImpl.Builder currentRow;
	private ListItem item;
	private int forceCount;
	private int minLeft;
	private int minRight;
	private int segmentIndex;

	private AggregatedBrailleTranslatorResult.Builder layoutOrApplyAfterLeader;
	private String currentLeaderMode;
	private boolean seenSegmentAfterLeader;
	private int rowIndex;
	private final ArrayList<Marker> groupMarkers;
	private final ArrayList<String> groupAnchors;
	
	public BlockContentManager(int flowWidth, List<Segment> segments, RowDataProperties rdp, CrossReferenceHandler refs, Context context, FormatterCoreContext fcontext) {
		super(flowWidth, rdp, fcontext);
		this.groupMarkers = new ArrayList<>();
		this.groupAnchors = new ArrayList<>();
		this.refs = refs;
		this.available = flowWidth - rightMargin.getContent().length();
		this.context = context;
		this.segments = Collections.unmodifiableList(segments);
		this.rows = new ArrayList<>();
		this.leaderManager = new LeaderManager();
		initFields();
	}
	
	private BlockContentManager(BlockContentManager template) {
		super(template);
		this.groupAnchors = new ArrayList<>(template.groupAnchors);
		this.groupMarkers = new ArrayList<>(template.groupMarkers);
		this.rows = new ArrayList<>(template.rows);
		// Refs is mutable, but for now we assume that the same context should be used.
		this.refs = template.refs;
		this.available = template.available;
		// Context is mutable, but for now we assume that the same context should be used.
		this.context = template.context;
		this.segments = template.segments;
		this.currentRow = template.currentRow==null?null:new RowImpl.Builder(template.currentRow);
		this.leaderManager = new LeaderManager(template.leaderManager);
		this.item = template.item;
		this.forceCount = template.forceCount;
		this.minLeft = template.minLeft;
		this.minRight = template.minRight;
		this.segmentIndex = template.segmentIndex;
		this.layoutOrApplyAfterLeader = template.layoutOrApplyAfterLeader==null?null:new AggregatedBrailleTranslatorResult.Builder(template.layoutOrApplyAfterLeader);
		this.currentLeaderMode = template.currentLeaderMode;
		this.seenSegmentAfterLeader = template.seenSegmentAfterLeader;
		this.rowIndex = template.rowIndex;
	}
	
    private void initFields() {
		leaderManager.discardLeader();
		currentRow = null;
		item = rdp.getListItem();
		minLeft = flowWidth;
		minRight = flowWidth;
		segmentIndex = 0;
		layoutOrApplyAfterLeader = null;
		currentLeaderMode = null;
		seenSegmentAfterLeader = false;
		rowIndex = 0;
    }
	
    @Override
	public void setContext(DefaultContext context) {
		this.context = context;
	}

	@Override
	public AbstractBlockContentManager copy() {
		return new BlockContentManager(this);
	}
	
	private boolean ensureBuffer(int index) {
		return ensureBuffer(index, false);
	}

	/**
	 * Ensures that the specified result index is available in the result list.
	 * Note that this function is modeled after {@link RowGroupDataSource}, but that it
	 * isn't used in the same way (yet).
	 * @param index the index to ensure
	 * @param testOnly if a row should actually be produced
	 * @return returns true if the specified index is available in the result list, false
	 * if the specified index cannot be made available (because the input doesn't contain
	 * the required amount of data).
	 */
	private boolean ensureBuffer(int index, boolean testOnly) {
		while (index<0 || rows.size()<index) {
			if (!hasMoreData()) {
				return false;
			}
			Segment s = segments.get(segmentIndex);
			if (testOnly) {
				switch (s.getSegmentType()) {
				case Marker:
				case Anchor:
					break;
				case Evaluate:
					if (!((Evaluate)s).getExpression().render(context).isEmpty()) {
						return true;
					} else {
						break;
					}
				default:
					return true;
				}
			}
			layoutSegment(s);
			segmentIndex++;
			if (!hasMoreData()) {
				layoutLeader();
				flushCurrentRow();
				if (rows.size()>0 && rdp.getUnderlineStyle() != null) {
					if (minLeft < leftMargin.getContent().length() || minRight < rightMargin.getContent().length()) {
						throw new RuntimeException("coding error");
					}
					rows.add(new RowImpl.Builder(StringTools.fill(fcontext.getSpaceCharacter(), minLeft - leftMargin.getContent().length())
					                     + StringTools.fill(rdp.getUnderlineStyle(), flowWidth - minLeft - minRight))
								.leftMargin(leftMargin)
								.rightMargin(rightMargin)
								.adjustedForMargin(true)
								.build());
				}
			}
		}
		return true;
	}
	
	private void layoutSegment(Segment s) {
		switch (s.getSegmentType()) {
			case NewLine:
				//flush
				layoutNewLine();
				break;
			case Text:
				layoutTextSegment((TextSegment)s);
				break;
			case Leader:
				layoutLeaderSegment((LeaderSegment)s);
				break;
			case Reference:
				layoutPageSegment((PageNumberReferenceSegment)s);
				break;
			case Evaluate:
				layoutEvaluate((Evaluate)s);
				break;
			case Marker:
				applyAfterLeader((MarkerSegment)s);
				break;
			case Anchor:
				applyAfterLeader((AnchorSegment)s);
				break;
		}		
	}

	private void layoutNewLine() {
		layoutLeader();
		flushCurrentRow();
		MarginProperties ret = new MarginProperties(leftMargin.getContent()+StringTools.fill(fcontext.getSpaceCharacter(), rdp.getTextIndent()), leftMargin.isSpaceOnly());
		currentRow = rdp.configureNewEmptyRowBuilder(ret, rightMargin);
	}
	
	private void layoutTextSegment(TextSegment ts) {
		layoutAfterLeader(
				Translatable.text(
						fcontext.getConfiguration().isMarkingCapitalLetters()?
						ts.getText():ts.getText().toLowerCase()
						).
				locale(ts.getTextProperties().getLocale()).
				hyphenate(ts.getTextProperties().isHyphenating()).
				attributes(ts.getTextAttribute()).build(),
				ts.getTextProperties().getTranslationMode());
	}
	
	private void layoutLeaderSegment(LeaderSegment ls) {
		if (leaderManager.hasLeader()) {
			layoutLeader();
		}
		leaderManager.setLeader(ls);
	}

	private void layoutPageSegment(PageNumberReferenceSegment rs) {
		Integer page = null;
		if (refs!=null) {
			page = refs.getPageNumber(rs.getRefId());
		}
		//TODO: translate references using custom language?
		if (page==null) {
			layoutAfterLeader(Translatable.text("??").locale(null).build(), null);
		} else {
			String txt = "" + rs.getNumeralStyle().format(page);
			layoutAfterLeader(Translatable.text(
					fcontext.getConfiguration().isMarkingCapitalLetters()?txt:txt.toLowerCase()
					).locale(null).attributes(rs.getTextAttribute(txt.length())).build(), null);
		}
	}
	
	private void layoutEvaluate(Evaluate e) {
		String txt = e.getExpression().render(context);
		if (!txt.isEmpty()) // Don't create a new row if the evaluated expression is empty
		                    // Note: this could be handled more generally (also for regular text) in layout().
			layoutAfterLeader(
					Translatable.text(fcontext.getConfiguration().isMarkingCapitalLetters()?txt:txt.toLowerCase()).
					locale(e.getTextProperties().getLocale()).
					hyphenate(e.getTextProperties().isHyphenating()).
					attributes(e.getTextAttribute(txt.length())).
					build(), 
					null);
	}
	
	private boolean hasMoreData() {
		return segmentIndex<segments.size();
	}

	private void flushCurrentRow() {
		if (currentRow!=null) {
			if (rows.isEmpty()) {
				// Clear group anchors and markers (since we have content, we don't need them)
				currentRow.addAnchors(0, groupAnchors);
				groupAnchors.clear();
				currentRow.addMarkers(0, groupMarkers);
				groupMarkers.clear();
			}
			RowImpl r = currentRow.build();
			rows.add(r);
			//Make calculations for underlining
			int width = r.getChars().length();
			int left = r.getLeftMargin().getContent().length();
			int right = r.getRightMargin().getContent().length();
			int space = flowWidth - width - left - right;
			left += r.getAlignment().getOffset(space);
			right = flowWidth - width - left;
			minLeft = min(minLeft, left);
			minRight = min(minRight, right);
			currentRow = null;
		}
	}
	
	private void layoutAfterLeader(Translatable spec, String mode) {
		if (leaderManager.hasLeader()) {
			if (layoutOrApplyAfterLeader == null) {
				layoutOrApplyAfterLeader = new AggregatedBrailleTranslatorResult.Builder();
				// use the mode of the first following segment to translate the leader pattern (or
				// the mode of the first preceding segment)
				if (!seenSegmentAfterLeader) {
					currentLeaderMode = mode;
					seenSegmentAfterLeader = true;
				}
			}
			try {
				layoutOrApplyAfterLeader.add(fcontext.getTranslator(mode).translate(spec));
			} catch (TranslationException e) {
				throw new RuntimeException(e);
			}
		} else {
			layout(spec, mode);
		}
	}
	
	private void applyAfterLeader(MarkerSegment marker) {
		if (leaderManager.hasLeader()) {
			if (layoutOrApplyAfterLeader == null) {
				layoutOrApplyAfterLeader = new AggregatedBrailleTranslatorResult.Builder();
			}
			layoutOrApplyAfterLeader.add(marker);
		} else {
			if (currentRow==null) {
				groupMarkers.add(marker);
			} else {
				currentRow.addMarker(marker);
			}
		}
	}
	
	private void applyAfterLeader(final AnchorSegment anchor) {
		if (leaderManager.hasLeader()) {
			if (layoutOrApplyAfterLeader == null) {
				layoutOrApplyAfterLeader = new AggregatedBrailleTranslatorResult.Builder();
			}
			layoutOrApplyAfterLeader.add(anchor);
		} else {
			if (currentRow==null) {
				groupAnchors.add(anchor.getReferenceID());
			} else {
				currentRow.addAnchor(anchor.getReferenceID());
			}
		}
	}
	
	private void layoutLeader() {
		if (leaderManager.hasLeader()) {
			// layout() sets currentLeader to null
			if (layoutOrApplyAfterLeader == null) {
				layout("", null, null);
			} else {
				layout(layoutOrApplyAfterLeader.build(), currentLeaderMode);
				layoutOrApplyAfterLeader = null;
				seenSegmentAfterLeader = false;
			}
		}
	}

	@Override
	public int getRowCount() {
		ensureBuffer(-1);
		return rows.size();
	}
	
	@Override
	public boolean supportsVariableWidth() {
		return true;
	}
	
    @Override
	public void reset() {
    	groupAnchors.clear();
    	groupMarkers.clear();
    	rows.clear();
    	initFields();
    }

    @Override
    public boolean hasNext() {
        return ensureBuffer(rowIndex+1, true);
    }

    @Override
    public RowImpl getNext() {
    	ensureBuffer(rowIndex+1);
        try {
            RowImpl ret = rows.get(rowIndex);
            rowIndex++;
            return ret;
        } catch (IndexOutOfBoundsException e) {
            throw new NoSuchElementException();
        }
    }

	private void layout(String c, String locale, String mode) {
		layout(Translatable.text(fcontext.getConfiguration().isMarkingCapitalLetters()?c:c.toLowerCase()).locale(locale).build(), mode);
	}
	
	private void layout(Translatable spec, String mode) {
		try {
			layout(fcontext.getTranslator(mode).translate(spec), mode);
		} catch (TranslationException e) {
			throw new RuntimeException(e);
		}
	}

	private void layout(BrailleTranslatorResult btr, String mode) {
		// process first row, is it a new block or should we continue the current row?
		if (currentRow==null) {
			// add to left margin
			if (item!=null) { //currentListType!=BlockProperties.ListType.NONE) {
				String listLabel;
				try {
					listLabel = fcontext.getTranslator(mode).translate(Translatable.text(fcontext.getConfiguration().isMarkingCapitalLetters()?item.getLabel():item.getLabel().toLowerCase()).build()).getTranslatedRemainder();
				} catch (TranslationException e) {
					throw new RuntimeException(e);
				}
				if (item.getType()==FormattingTypes.ListStyle.PL) {
					newRow(btr, listLabel, 0, rdp.getBlockIndentParent(), mode);
				} else {
					newRow(btr, listLabel, rdp.getFirstLineIndent(), rdp.getBlockIndent(), mode);
				}
				item = null;
			} else {
				newRow(btr, "", rdp.getFirstLineIndent(), rdp.getBlockIndent(), mode);
			}
		} else {
			newRow(new RowInfo("", currentRow, available), btr, rdp.getBlockIndent(), mode);
		}
		while (btr.hasNext()) { //LayoutTools.length(chars.toString())>0
			newRow(btr, "", rdp.getTextIndent(), rdp.getBlockIndent(), mode);
		}
		if (btr.supportsMetric(BrailleTranslatorResult.METRIC_FORCED_BREAK)) {
			forceCount += btr.getMetric(BrailleTranslatorResult.METRIC_FORCED_BREAK);
		}
	}
	
	private void newRow(BrailleTranslatorResult chars, String contentBefore, int indent, int blockIndent, String mode) {
		flushCurrentRow();
		currentRow = rdp.configureNewEmptyRowBuilder(leftMargin, rightMargin);
		newRow(new RowInfo(getPreText(contentBefore, indent, blockIndent), currentRow, available), chars, blockIndent, mode);
	}
	
	private String getPreText(String contentBefore, int indent, int blockIndent) {
		int thisIndent = Math.max(
				// There is one known cause for this calculation to become < 0. That is when an ordered list is so long
				// that the number takes up more space than the indent reserved for it.
				// In that case it is probably best to push the content instead of failing altogether.
				indent + blockIndent - StringTools.length(contentBefore),
				0);
		return contentBefore + StringTools.fill(fcontext.getSpaceCharacter(), thisIndent);
	}

	//TODO: check leader functionality
	private void newRow(RowInfo m, BrailleTranslatorResult btr, int blockIndent, String mode) {
		// [margin][preContent][preTabText][tab][postTabText] 
		//      preContentPos ^
		String tabSpace = "";
		if (leaderManager.hasLeader()) {
			int leaderPos = leaderManager.getLeaderPosition(available);
			int offset = leaderPos-m.preTabPos;
			int align = leaderManager.getLeaderAlign(btr.countRemaining());
			
			if (m.preTabPos>leaderPos || offset - align < 0) { // if tab position has been passed or if text does not fit within row, try on a new row
				MarginProperties _leftMargin = currentRow.getLeftMargin();
				flushCurrentRow();
				currentRow = rdp.configureNewEmptyRowBuilder(_leftMargin, rightMargin);
				m = new RowInfo(StringTools.fill(fcontext.getSpaceCharacter(), rdp.getTextIndent()+blockIndent), currentRow, available);
				//update offset
				offset = leaderPos-m.preTabPos;
			}
			try {
				tabSpace = leaderManager.getLeaderPattern(fcontext.getTranslator(mode), offset - align);
			} finally {
				// always discard leader
				leaderManager.discardLeader();
			}
		}
		breakNextRow(m, btr, tabSpace);
	}

	private static void breakNextRow(RowInfo m, BrailleTranslatorResult btr, String tabSpace) {
		int contentLen = StringTools.length(tabSpace) + m.preTabTextLen;
		boolean force = contentLen == 0;
		//don't know if soft hyphens need to be replaced, but we'll keep it for now
		String next = softHyphenPattern.matcher(btr.nextTranslatedRow(m.maxLenText - contentLen, force)).replaceAll("");
		if ("".equals(next) && "".equals(tabSpace)) {
			m.row.text(m.preContent + trailingWsBraillePattern.matcher(m.preTabText).replaceAll(""));
		} else {
			m.row.text(m.preContent + m.preTabText + tabSpace + next);
			m.row.leaderSpace(m.row.getLeaderSpace()+tabSpace.length());
		}
		if (btr instanceof AggregatedBrailleTranslatorResult) {
			AggregatedBrailleTranslatorResult abtr = ((AggregatedBrailleTranslatorResult)btr);
			m.row.addMarkers(abtr.getMarkers());
			m.row.addAnchors(abtr.getAnchors());
			abtr.clearPending();
		}
	}

	@Override
	public int getForceBreakCount() {
		ensureBuffer(-1);
		return forceCount;
	}

	@Override
	public List<Marker> getGroupMarkers() {
		return groupMarkers;
	}
	
	@Override
	public List<String> getGroupAnchors() {
		return groupAnchors;
	}

}
