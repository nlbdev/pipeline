package org.daisy.dotify.formatter.impl;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;

import org.daisy.dotify.api.formatter.Condition;
import org.daisy.dotify.api.formatter.Field;
import org.daisy.dotify.api.formatter.FieldList;
import org.daisy.dotify.api.formatter.MarginRegion;
import org.daisy.dotify.api.formatter.NoField;
import org.daisy.dotify.api.formatter.PageTemplateBuilder;
import org.daisy.dotify.api.obfl.Expression;


/**
 * Specifies page objects such as header and footer
 * for the pages to which it applies.
 * @author Joel Håkansson
 */
class PageTemplate implements PageTemplateBuilder {
	private final Condition condition;
	private final List<FieldList> header;
	private final List<FieldList> footer;
	private final List<MarginRegion> leftMarginRegion;
	private final List<MarginRegion> rightMarginRegion;
	private final HashMap<Integer, Boolean> appliesTo;
	private final float defaultRowSpacing;
	private Integer flowIntoHeaderHeight;
	private Integer flowIntoFooterHeight;
	
	PageTemplate(float rowSpacing) {
		this(null, rowSpacing);
	}

	/**
	 * Create a new SimpleTemplate.
	 * @param useWhen string to evaluate. In addition to the syntax of {@link Expression}, the value $page can be
	 * used. This will be replaced by the current page number before the expression is evaluated.
	 */
	PageTemplate(Condition condition, float rowSpacing) {
		this.condition = condition;
		this.header = new ArrayList<>();
		this.footer = new ArrayList<>();
		this.leftMarginRegion = new ArrayList<>();
		this.rightMarginRegion = new ArrayList<>();
		this.appliesTo = new HashMap<>();
		this.defaultRowSpacing = rowSpacing;
	}

	@Override
	public void addToHeader(FieldList obj) {
		// reset the cached value
		flowIntoHeaderHeight = null;
		header.add(obj);
	}
	
	@Override
	public void addToFooter(FieldList obj) {
		// reset the cached value
		flowIntoFooterHeight = null;
		footer.add(obj);
	}


	/**
	 * Gets header rows for a page using this Template. Each FieldList must 
	 * fit within a single row, i.e. the combined length of all resolved strings in each FieldList must
	 * be smaller than the flow width. Keep in mind that text filters will be applied to the 
	 * resolved string, which could affect its length.
	 * @return returns a List of FieldList
	 */
	List<FieldList> getHeader() {
		return header;
	}
	
	/**
	 * Gets footer rows for a page using this Template. Each FieldList must 
	 * fit within a single row, i.e. the combined length of all resolved strings in each FieldList must
	 * be smaller than the flow width. Keep in mind that text filters will be applied to the 
	 * resolved string, which could affect its length.
	 * @return returns a List of FieldList
	 */
	List<FieldList> getFooter() {
		return footer;
	}

	/**
	 * Tests if this Template applies to this pagenum.
	 * @param pagenum the pagenum to test
	 * @return returns true if the Template should be applied to the page
	 */
	boolean appliesTo(int pagenum) {
		if (condition==null) {
			return true;
		}
		// keep a HashMap with calculated results
		if (appliesTo.containsKey(pagenum)) {
			return appliesTo.get(pagenum);
		}
		boolean applies = condition.evaluate(new DefaultContext.Builder().currentPage(pagenum).build());
		appliesTo.put(pagenum, applies);
		return applies;
	}

	@Override
	public void addToLeftMargin(MarginRegion margin) {
		leftMarginRegion.add(margin);
	}

	@Override
	public void addToRightMargin(MarginRegion margin) {
		rightMarginRegion.add(margin);
	}

	List<MarginRegion> getLeftMarginRegion() {
		return leftMarginRegion;
	}

	List<MarginRegion> getRightMarginRegion() {
		return rightMarginRegion;
	}
	
	int validateAndAnalyzeHeader() {
		// do the analyzing lazily
		if (flowIntoHeaderHeight==null) {
			flowIntoHeaderHeight = validateAndAnalyzeHeaderFooter(true);
		}
		return flowIntoHeaderHeight;
	}
	
	int validateAndAnalyzeFooter() {
		// do the analyzing lazily
		if (flowIntoFooterHeight==null) {
			flowIntoFooterHeight = validateAndAnalyzeHeaderFooter(false); 
		}
		return flowIntoFooterHeight;
	}
	
	private int validateAndAnalyzeHeaderFooter(boolean header) {
		List<FieldList> rows;
		if (header) {
			rows = new ArrayList<>(getHeader());
			Collections.reverse(rows);
		} else {
			rows = getFooter();
		}
		int j = 0;
		int height = 0;
		for (FieldList row : rows) {
			int k = 0;
			boolean hasEmptyField = false;
			for (Field f : row.getFields()) {
				if (f instanceof NoField) {
					if (hasEmptyField) {
						throw new RuntimeException("At most one empty <field/> allowed.");
					} else if (k > 0) {
						throw new RuntimeException("Empty <field/> only allowed on the left.");
					} else {
						hasEmptyField = true;
					}
				}
				k++;
			}
			if (hasEmptyField) {
				if (k == 1) {
					throw new RuntimeException("Empty <field/> does not make sense as single child.");
				} else if (k > 2) {
					throw new RuntimeException("Empty <field/> only allowed in combination with a single non-empty <field/>.");
				}
				float rowSpacing;
				if (row.getRowSpacing() != null) {
					rowSpacing = row.getRowSpacing();
				} else {
					rowSpacing = this.defaultRowSpacing;
				}
				if (rowSpacing != 1.0f) {
					throw new RuntimeException("Empty <field/> only allowed when row-spacing is '1'.");
				}
				if (height == j) {
					height++;
				} else {
					throw new RuntimeException("Empty <field/> only allowed if all "
						                           + (header ? "<header/> below" : "<footer/> above")
						                           + " have an empty <field/> as well.");
				}
			}
			j++;
		}
		return height;
	}


}
