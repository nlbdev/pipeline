package org.daisy.dotify.formatter.impl;

import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

import org.daisy.dotify.api.formatter.CompoundField;
import org.daisy.dotify.api.formatter.CurrentPageField;
import org.daisy.dotify.api.formatter.Field;
import org.daisy.dotify.api.formatter.FieldList;
import org.daisy.dotify.api.formatter.FormattingTypes;
import org.daisy.dotify.api.formatter.Marker;
import org.daisy.dotify.api.formatter.MarkerReferenceField;
import org.daisy.dotify.api.formatter.NoField;
import org.daisy.dotify.api.formatter.PageAreaProperties;
import org.daisy.dotify.api.translator.BrailleTranslator;
import org.daisy.dotify.api.translator.DefaultTextAttribute;
import org.daisy.dotify.api.translator.TextBorderStyle;
import org.daisy.dotify.api.translator.Translatable;
import org.daisy.dotify.api.translator.TranslationException;
import org.daisy.dotify.api.writer.Row;
import org.daisy.dotify.common.text.StringTools;
import org.daisy.dotify.formatter.impl.search.CrossReferenceHandler;
import org.daisy.dotify.formatter.impl.search.PageDetails;
import org.daisy.dotify.writer.impl.Page;


//FIXME: scope spread is currently implemented using document wide scope, i.e. across volume boundaries. This is wrong, but is better than the previous sequence scope.
/**
 * Provides a page object.
 * 
 * @author Joel Håkansson
 */
class PageImpl implements Page {
	private static final Pattern trailingWs = Pattern.compile("\\s*\\z");
	private static final Pattern softHyphen = Pattern.compile("\u00ad");
	private final CrossReferenceHandler crh;
	private final PageDetails details;
	private final LayoutMaster master;
	private final FormatterContext fcontext;
	private final List<RowImpl> before;
	private final List<RowImpl> after;
    private final ArrayList<RowImpl> rows;
    private final ArrayList<RowImpl> pageArea;
    private final ArrayList<String> anchors;
    private final ArrayList<String> identifiers;
	private final int pageIndex;
	private final int pagenum;
	private final int flowHeight;
	private final PageTemplate template;
	private final int pageMargin;
	private final TextBorderStyle borderStyle;
	private final TextBorder border;

	private boolean isVolBreakAllowed;
	private int keepPreviousSheets;
	private Integer volumeBreakAfterPriority;
	
	public PageImpl(CrossReferenceHandler crh, PageDetails details, LayoutMaster master, FormatterContext fcontext, int pageIndex, List<RowImpl> before, List<RowImpl> after) {
		this.crh = crh;
		this.details = details;
		this.master = master;
		this.fcontext = fcontext;
		this.rows = new ArrayList<>();
		this.before = before;
		this.after = after;

		this.pageArea = new ArrayList<>();
		this.anchors = new ArrayList<>();
		this.identifiers = new ArrayList<>();
		this.pageIndex = pageIndex;
		this.pagenum = pageIndex + 1;
		this.template = master.getTemplate(pageIndex+1);
        this.flowHeight = master.getPageHeight() - 
                (int)Math.ceil(getHeight(template.getHeader(), master.getRowSpacing())) -
                (int)Math.ceil(getHeight(template.getFooter(), master.getRowSpacing())) -
                (master.getBorder() != null ? (int)Math.ceil(distributeRowSpacing(null, false).spacing*2) : 0);
		this.isVolBreakAllowed = true;
		this.keepPreviousSheets = 0;
		this.volumeBreakAfterPriority = null;
		this.pageMargin = ((pagenum % 2 == 0) ? master.getOuterMargin() : master.getInnerMargin());
		this.borderStyle = master.getBorder()!=null?master.getBorder():TextBorderStyle.NONE;
		this.border = buildBorder();
	}
	
	private static float getHeight(List<FieldList> list, float def) {
		return (float)list.stream().mapToDouble(f -> f.getRowSpacing()!=null?f.getRowSpacing():def).sum();
	}

	void addToPageArea(List<RowImpl> block) {
		pageArea.addAll(block);
	}
	
	void newRow(RowImpl r) {
		if (rowsOnPage()==0) {
			details.startsContentMarkers();
		}
		rows.add(r);
		details.getMarkers().addAll(r.getMarkers());
		anchors.addAll(r.getAnchors());
	}
	
	/**
	 * Gets the number of rows on this page
	 * @return returns the number of rows on this page
	 */
	private int rowsOnPage() {
		return rows.size();
	}
	
	void addMarkers(List<Marker> m) {
		details.getMarkers().addAll(m);
	}
	
	List<String> getAnchors() {
		return anchors;
	}
	
	void addIdentifier(String id) {
		identifiers.add(id);
	}
	
	List<String> getIdentifiers() {
		return identifiers;
	}
	
	/**
	 * Gets the page space needed to render the rows. 
	 * @param rows
	 * @param defSpacing a value >= 1.0
	 * @return returns the space, in rows
	 */
	private static float rowsNeeded(Iterable<? extends Row> rows, float defSpacing) {
		float ret = 0;
		if (defSpacing < 1) {
			defSpacing = 1;
		}
		for (Row r : rows) {
			if (r.getRowSpacing()!=null && r.getRowSpacing()>=1) {
				ret += r.getRowSpacing();
			} else {
				ret += defSpacing;
			}
		}
		return ret;
	}
	
	private float spaceNeeded() {
		return 	pageAreaSpaceNeeded() +
				rowsNeeded(rows, master.getRowSpacing());
	}
	
	float staticAreaSpaceNeeded() {
		return rowsNeeded(before, master.getRowSpacing()) + rowsNeeded(after, master.getRowSpacing());
	}
	
	float pageAreaSpaceNeeded() {
		return (!pageArea.isEmpty() ? staticAreaSpaceNeeded() + rowsNeeded(pageArea, master.getRowSpacing()) : 0);
	}
	
	int spaceUsedOnPage(int offs) {
		return (int)Math.ceil(spaceNeeded()) + offs;
	}
	
	private List<RowImpl> buildPageRows() throws PaginatorException {
		ArrayList<RowImpl> ret = new ArrayList<>();
		{
			PageTemplate t = master.getTemplate(pagenum);
			BrailleTranslator filter = fcontext.getDefaultTranslator();
            ret.addAll(renderFields(t.getHeader(), filter));
            if (master.getPageArea()!=null && master.getPageArea().getAlignment()==PageAreaProperties.Alignment.TOP && !pageArea.isEmpty()) {
				ret.addAll(before);
				ret.addAll(pageArea);
				ret.addAll(after);
			}
            ret.addAll(rows);
            float headerHeight = getHeight(t.getHeader(), master.getRowSpacing());
            if (!t.getFooter().isEmpty() || borderStyle != TextBorderStyle.NONE || (master.getPageArea()!=null && master.getPageArea().getAlignment()==PageAreaProperties.Alignment.BOTTOM && !pageArea.isEmpty())) {
                float areaSize = (master.getPageArea()!=null && master.getPageArea().getAlignment()==PageAreaProperties.Alignment.BOTTOM ? pageAreaSpaceNeeded() : 0);
                while (Math.ceil(rowsNeeded(ret, master.getRowSpacing()) + areaSize) < getFlowHeight() + headerHeight) {
					ret.add(new RowImpl());
				}
				if (master.getPageArea()!=null && master.getPageArea().getAlignment()==PageAreaProperties.Alignment.BOTTOM && !pageArea.isEmpty()) {
					ret.addAll(before);
					ret.addAll(pageArea);
					ret.addAll(after);
				}
                ret.addAll(renderFields(t.getFooter(), filter));
			}
		}
		return ret;
	}
	
	private TextBorder buildBorder() {
		int fsize = borderStyle.getLeftBorder().length() + borderStyle.getRightBorder().length();
		int w = master.getFlowWidth() + fsize + pageMargin;
		return new TextBorder.Builder(w, fcontext.getSpaceCharacter()+"")
				.style(borderStyle)
				.outerLeftMargin(pageMargin)
				.padToSize(!TextBorderStyle.NONE.equals(borderStyle))
				.build();
	}

	/*
	 * The assumption is made that by now all pages have been added to the parent sequence and volume scopes
	 * have been set on the page struct.
	 */
	@Override
	public List<Row> getRows() {
		try {
            ArrayList<Row> ret2 = new ArrayList<>();
			{
				if (!TextBorderStyle.NONE.equals(borderStyle)) {
					RowImpl r = new RowImpl(border.getTopBorder());
					DistributedRowSpacing rs = distributeRowSpacing(master.getRowSpacing(), true);
					r.setRowSpacing(rs.spacing);
					ret2.add(r);
				}
	            List<RowImpl> ret = buildPageRows();
	            DistributedRowSpacing rs = null;
	            RowImpl r2 = null;
				for (RowImpl row : ret) {
					//does the previous row require additional processing?
                    if (rs!=null) {
						RowImpl s = null;
						for (int i = 0; i < rs.lines-1; i++) {
							s = new RowImpl(border.addBorderToRow(r2.getLeftMargin().getContent(), r2.getRightMargin().getContent()));
							s.setRowSpacing(rs.spacing);
							ret2.add(s);
						}
					}

					r2 = addBorders(row);
					ret2.add(r2);
					Float rs2 = row.getRowSpacing();
					if (!TextBorderStyle.NONE.equals(borderStyle)) {
						//distribute row spacing
						rs = distributeRowSpacing(rs2, true);
						r2.setRowSpacing(rs.spacing);
					} else {
						r2.setRowSpacing(rs2);
					}
				}
				if (!TextBorderStyle.NONE.equals(borderStyle)) {
                    ret2.add(new RowImpl(border.getBottomBorder()));
				}
			}
            if (ret2.size()>0) {
                RowImpl last = ((RowImpl)ret2.get(ret2.size()-1));
				if (master.getRowSpacing()!=1) {
					//set row spacing on the last row to 1.0
					last.setRowSpacing(1f);
				} else if (last.getRowSpacing()!=null) {
					//ignore row spacing on the last row if overall row spacing is 1.0
					last.setRowSpacing(null);
				}
			}
			return ret2;
		} catch (PaginatorException e) {
			throw new RuntimeException("Pagination failed.", e);
		}
	}
	
	private RowImpl addBorders(RowImpl row) {
		String res = "";
		if (row.getChars().length() > 0) {
			// remove trailing whitespace
			String chars = trailingWs.matcher(row.getChars()).replaceAll("");
			res = border.addBorderToRow(
					padLeft(master.getFlowWidth(), chars, row.getLeftMargin(), row.getRightMargin(), row.getAlignment(), fcontext.getSpaceCharacter()), 
					"");
		} else {
			if (!TextBorderStyle.NONE.equals(borderStyle)) {
				res = border.addBorderToRow(row.getLeftMargin().getContent(), row.getRightMargin().getContent());
			} else {
				if (!row.getLeftMargin().isSpaceOnly() || !row.getRightMargin().isSpaceOnly()) {
					res = TextBorder.addBorderToRow(
						master.getFlowWidth(), row.getLeftMargin().getContent(), "", row.getRightMargin().getContent(), fcontext.getSpaceCharacter()+"");
				} else {
					res = "";
				}
			}
		}
		int rowWidth = StringTools.length(res) + pageMargin;
		if (rowWidth > master.getPageWidth()) {
			throw new PaginatorException("Row is too long (" + rowWidth + "/" + master.getPageWidth() + ") '" + res + "'");
		}
		return new RowImpl(res);
	}
	
	static String padLeft(int w, RowImpl row, char space) {
		String chars = trailingWs.matcher(row.getChars()).replaceAll("");
		return padLeft(w, chars, row.getLeftMargin(), row.getRightMargin(), row.getAlignment(), space);
	}
	
	private static String padLeft(int w, String text, MarginProperties leftMargin, MarginProperties rightMargin, FormattingTypes.Alignment align, char space) {
		if ("".equals(text) && leftMargin.isSpaceOnly() && rightMargin.isSpaceOnly()) {
			return "";
		} else {
			String r = leftMargin.getContent() + StringTools.fill(space, align.getOffset(w - (leftMargin.getContent().length() + rightMargin.getContent().length() + text.length()))) + text;
			if (rightMargin.isSpaceOnly()) {
				return r;
			} else {
				return r + StringTools.fill(space, w - r.length() - rightMargin.getContent().length()) + rightMargin.getContent();
			}
		}
	}

	/**
	 * Get the page index, offset included, zero based. Don't assume
	 * getPageIndex() % 2 == getPageOrdinal() % 2
	 * 
	 * @return returns the page index in the sequence (zero based)
	 */
	int getPageIndex() {
		return pageIndex;
	}

	/**
	 * Gets the flow height for this page, i.e. the number of rows available for text flow
	 * @return returns the flow height
	 */
	int getFlowHeight() {
		return flowHeight;
	}

    private List<RowImpl> renderFields(List<FieldList> fields, BrailleTranslator translator) throws PaginatorException {
        ArrayList<RowImpl> ret = new ArrayList<>();
		for (FieldList row : fields) {
            try {
                RowImpl r = new RowImpl(distribute(row, master.getFlowWidth(), fcontext.getSpaceCharacter()+"", translator));
                r.setRowSpacing(row.getRowSpacing());
                ret.add(r);
            } catch (PaginatorToolsException e) {
                throw new PaginatorException("Error while rendering header", e);
			}
		}
		return ret;
	}
	
    private String distribute(FieldList chunks, int width, String padding, BrailleTranslator translator) throws PaginatorToolsException {
		ArrayList<String> chunkF = new ArrayList<>();
		for (Field f : chunks.getFields()) {
			DefaultTextAttribute.Builder b = new DefaultTextAttribute.Builder(null);
            String resolved = softHyphen.matcher(resolveField(f, this, b)).replaceAll("");
			Translatable.Builder tr = Translatable.text(fcontext.getConfiguration().isMarkingCapitalLetters()?resolved:resolved.toLowerCase()).
										hyphenate(false);
			if (resolved.length()>0) {
				tr.attributes(b.build(resolved.length()));
			}
			try {
				chunkF.add(translator.translate(tr.build()).getTranslatedRemainder());
			} catch (TranslationException e) {
				throw new PaginatorToolsException(e);
			}
		}
        return PaginatorTools.distribute(chunkF, width, padding,
                fcontext.getConfiguration().isAllowingTextOverflowTrimming()?
                PaginatorTools.DistributeMode.EQUAL_SPACING_TRUNCATE:
                PaginatorTools.DistributeMode.EQUAL_SPACING
            );
	}
	
	/*
	 * Note that the result of this function is not constant because getPageInSequenceWithOffset(),
	 * getPageInVolumeWithOffset() and shouldAdjustOutOfBounds() are not constant.
	 */
	private String resolveField(Field field, PageImpl p, DefaultTextAttribute.Builder b) {
		if (field instanceof NoField) {
			throw new UnsupportedOperationException("Not implemented");
		}
		String ret;
		DefaultTextAttribute.Builder b2 = new DefaultTextAttribute.Builder(field.getTextStyle());
		if (field instanceof CompoundField) {
			ret = resolveCompoundField((CompoundField)field, p, b2);
		} else if (field instanceof MarkerReferenceField) {
			ret = crh.getSearchInfo().findStartAndMarker(p.details, (MarkerReferenceField)field);
		} else if (field instanceof CurrentPageField) {
			ret = resolveCurrentPageField((CurrentPageField)field, p);
		} else {
			ret = field.toString();
		}
		if (ret.length()>0) {
			b.add(b2.build(ret.length()));
		}
		return ret;
	}

	private String resolveCompoundField(CompoundField f, PageImpl p, DefaultTextAttribute.Builder b) {
		return f.stream().map(f2 -> resolveField(f2, p, b)).collect(Collectors.joining());
	}
	
	private static String resolveCurrentPageField(CurrentPageField f, PageImpl p) {
		int pagenum = p.getPageIndex() + 1;
		return f.getNumeralStyle().format(pagenum);
	}
	
	/**
	 * Divide a row-spacing value into several rows with a row-spacing < 2.
	 * <p>E.g. A row spacing of 2.5 will return:</p>
	 * <dl>
	 * 	<dt>RowSpacing.spacing</dt><dd>1.25</dd> 
	 *  <dt>RowSpacing.lines</dt><dd>2</dd>
	 * </dl>
	 * @param rs
	 * @return
	 */
	private DistributedRowSpacing distributeRowSpacing(Float rs, boolean nullIfEqualToDefault) {
		if (rs == null) {
			//use default
			rs = this.master.getRowSpacing();
		}
		int ins = Math.max((int)Math.floor(rs), 1);
		Float spacing = rs / ins;
		if (nullIfEqualToDefault && spacing.equals(this.master.getRowSpacing())) {
			return new DistributedRowSpacing(null, ins);
		} else {
			return new DistributedRowSpacing(spacing, ins);
		}
	}
	
	private class DistributedRowSpacing {
		private final Float spacing;
		private final int lines;
		DistributedRowSpacing(Float s, int l) {
			this.spacing = s;
			this.lines = l;
		}
	}
	
	void setKeepWithPreviousSheets(int value) {
		keepPreviousSheets = Math.max(value, keepPreviousSheets);
	}
	
	void setAllowsVolumeBreak(boolean value) {
		this.isVolBreakAllowed = value;
	}

	boolean allowsVolumeBreak() {
		return isVolBreakAllowed;
	}

	int keepPreviousSheets() {
		return keepPreviousSheets;
	}

	PageTemplate getPageTemplate() {
		return template;
	}
	
	Integer getAvoidVolumeBreakAfter() {
		return volumeBreakAfterPriority;
	}
	
	void setAvoidVolumeBreakAfter(Integer value) {
		this.volumeBreakAfterPriority = value;
	}

}
