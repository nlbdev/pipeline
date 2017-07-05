package org.daisy.dotify.formatter.impl;

import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import org.daisy.dotify.api.formatter.BlockPosition;
import org.daisy.dotify.api.formatter.FallbackRule;
import org.daisy.dotify.api.formatter.MarginRegion;
import org.daisy.dotify.api.formatter.MarkerIndicatorRegion;
import org.daisy.dotify.api.formatter.PageAreaProperties;
import org.daisy.dotify.api.formatter.RenameFallbackRule;
import org.daisy.dotify.api.translator.Translatable;
import org.daisy.dotify.api.translator.TranslationException;
import org.daisy.dotify.api.writer.SectionProperties;
import org.daisy.dotify.common.split.SplitPoint;
import org.daisy.dotify.common.split.SplitPointDataSource;
import org.daisy.dotify.common.split.SplitPointHandler;
import org.daisy.dotify.common.split.StandardSplitOption;
import org.daisy.dotify.common.split.Supplements;
import org.daisy.dotify.formatter.impl.search.CrossReferenceHandler;
import org.daisy.dotify.formatter.impl.search.DocumentSpace;
import org.daisy.dotify.formatter.impl.search.PageDetails;
import org.daisy.dotify.formatter.impl.search.SequenceId;
import org.daisy.dotify.formatter.impl.search.View;
import org.daisy.dotify.writer.impl.Page;
import org.daisy.dotify.writer.impl.Section;

class PageSequenceBuilder2 extends View<PageImpl> implements Section {
	private final FormatterContext context;
	private final CrossReferenceHandler crh;
	private final PageAreaContent staticAreaContent;
	private final PageAreaProperties areaProps;

	private ContentCollectionImpl collection;
	private final BlockContext blockContext;
	private final LayoutMaster master;
	private final int pageNumberOffset;
	private final Iterator<RowGroupSequence> dataGroups;
	private final int sequenceId;
	
	private SplitPointHandler<RowGroup> sph = new SplitPointHandler<>();
	private boolean force;
	private SplitPointDataSource<RowGroup> data;

	PageImpl current;
	int keepNextSheets;
	int pageCount = 0;

	PageSequenceBuilder2(PageStruct parent, LayoutMaster master, int pageOffset, CrossReferenceHandler crh,
	                     BlockSequence seq, FormatterContext context, DefaultContext rcontext, int sequenceId) { 
		super(parent.getPages(), parent.getPages().size());
		this.master = master;
		this.pageNumberOffset = pageOffset;
		this.context = context;
		this.crh = crh;
		this.sequenceId = sequenceId;

		this.collection = null;
		this.areaProps = seq.getLayoutMaster().getPageArea();
		if (this.areaProps!=null) {
			this.collection = context.getCollections().get(areaProps.getCollectionId());
		}
		current = null;
		keepNextSheets = 0;
		
		this.blockContext = new BlockContext(seq.getLayoutMaster().getFlowWidth(), crh, rcontext, context);
		this.staticAreaContent = new PageAreaContent(seq.getLayoutMaster().getPageAreaBuilder(), blockContext);
		this.dataGroups = RowGroupBuilder.getResult(master, seq, blockContext);
	}

	private PageImpl newPage() {
		PageImpl buffer = current;
		SequenceId seqId = new SequenceId(sequenceId, new DocumentSpace(blockContext.getContext().getSpace(), blockContext.getContext().getCurrentVolume()));
		PageDetails details = new PageDetails(master.duplex(), pageCount, getGlobalStartIndex(), seqId);
		crh.getSearchInfo().addPageDetails(details);
		current = new PageImpl(crh, details, master, context, pageCount+pageNumberOffset, staticAreaContent.getBefore(), staticAreaContent.getAfter());
		pageCount ++;
		if (keepNextSheets>0) {
			currentPage().setAllowsVolumeBreak(false);
		}
		if (!master.duplex() || pageCount%2==0) {
			if (keepNextSheets>0) {
				keepNextSheets--;
			}
		}
		return buffer;
	}

	private void setKeepWithPreviousSheets(int value) {
		currentPage().setKeepWithPreviousSheets(value);
	}

	private void setKeepWithNextSheets(int value) {
		keepNextSheets = Math.max(value, keepNextSheets);
		if (keepNextSheets>0) {
			currentPage().setAllowsVolumeBreak(false);
		}
	}
	
	private PageImpl currentPage() {
		return current;
	}

	/**
	 * Space used, in rows
	 * 
	 * @return
	 */
	private int spaceUsedOnPage(int offs) {
		return currentPage().spaceUsedOnPage(offs);
	}

	private void newRow(RowImpl row) {
		if (spaceUsedOnPage(1) > currentPage().getFlowHeight()) {
			throw new RuntimeException("Error in code.");
			//newPage();
		}
		currentPage().newRow(row);
	}

	private void insertIdentifier(String id) {
		crh.setPageNumber(id, currentPage().getPageIndex() + 1);
		currentPage().addIdentifier(id);
	}
	
	boolean hasNext() {
		return dataGroups.hasNext() || (data!=null && !data.isEmpty()) || current!=null;
	}
	
	PageImpl nextPage() throws PaginatorException, RestartPaginationException // pagination must be restarted in PageStructBuilder.paginateInner
	{
		PageImpl ret = nextPageInner();
		//This is for pre/post volume contents, where the volume number is known
		if (blockContext.getContext().getCurrentVolume()!=null) {
			for (String id : ret.getIdentifiers()) {
				crh.setVolumeNumber(id, blockContext.getContext().getCurrentVolume());
			}
		}
		addPage(ret);
		return ret;
	}

	PageImpl nextPageInner() throws PaginatorException, RestartPaginationException // pagination must be restarted in PageStructBuilder.paginateInner
	{
		while (dataGroups.hasNext() || (data!=null && !data.isEmpty())) {
			if ((data==null || data.isEmpty()) && dataGroups.hasNext()) {
				//pick up next group
				RowGroupSequence rgs = dataGroups.next();
				data = rgs.toSource(new CollectionData(blockContext));
				if (rgs.getBlockPosition()!=null) {
					if (pageCount==0) {
						// we know newPage returns null
						newPage();
					}
					float size = 0;
					for (RowGroup g : data.getRemaining()) {
						size += g.getUnitSize();
					}
					int pos = calculateVerticalSpace(rgs.getBlockPosition(), (int)Math.ceil(size));
					for (int i = 0; i < pos; i++) {
						RowImpl ri = rgs.getEmptyRow();
						newRow(new RowImpl(ri.getChars(), ri.getLeftMargin(), ri.getRightMargin()));
					}
				} else {
					PageImpl p = newPage();
					if (p!=null) {
						return p;
					}
				}
				force = false;
			}
			if (!data.isEmpty()) {
				//Discards leading skippable row groups, but retains their properties
				SplitPoint<RowGroup> sl = SplitPointHandler.trimLeading(data);
				for (RowGroup rg : sl.getDiscarded()) {
					addProperties(rg);
				}
				data = sl.getTail();
				int flowHeight = currentPage().getFlowHeight();
				SplitPoint<RowGroup> res = sph.split(flowHeight, data, force?StandardSplitOption.ALLOW_FORCE:null);
				if (res.getHead().size()==0 && force) {
					if (firstUnitHasSupplements(data) && hasPageAreaCollection()) {
						reassignCollection();
						throw new RestartPaginationException();
					} else {
						throw new RuntimeException("A layout unit was too big for the page.");
					}
				}
				force = res.getHead().size()==0;
				data = res.getTail();
				List<RowGroup> head = res.getHead();
				for (RowGroup rg : head) {
					addProperties(rg);
					for (RowImpl r : rg.getRows()) { 
						if (r.shouldAdjustForMargin()) {
							// clone the row as not to append the margins twice
							r = RowImpl.withRow(r);
							for (MarginRegion mr : currentPage().getPageTemplate().getLeftMarginRegion()) {
								r.setLeftMargin(getMarginRegionValue(mr, r, false).append(r.getLeftMargin()));
							}
							for (MarginRegion mr : currentPage().getPageTemplate().getRightMarginRegion()) {
								r.setRightMargin(r.getRightMargin().append(getMarginRegionValue(mr, r, true)));
							}
						}
						currentPage().newRow(r);
					}
				}
				Integer lastPriority = getLastPriority(head);
				if (!res.getDiscarded().isEmpty()) {
					//override if not empty
					lastPriority = getLastPriority(res.getDiscarded());
				}
				currentPage().setAvoidVolumeBreakAfter(lastPriority);
				for (RowGroup rg : res.getDiscarded()) {
					addProperties(rg);
				}
				for (RowGroup rg : res.getSupplements()) {
					currentPage().addToPageArea(rg.getRows());
				}
				if (hasPageAreaCollection() && currentPage().pageAreaSpaceNeeded() > master.getPageArea().getMaxHeight()) {
					reassignCollection();
					throw new RestartPaginationException();
				}
				if (!data.isEmpty()) {
					return newPage();
				}
			}
		}
		//flush current page
		PageImpl ret = current;
		current = null;
		return ret;
	}
	
	private static Integer getLastPriority(List<RowGroup> list) {
		if (!list.isEmpty()) {
			return list.get(list.size()-1).getAvoidVolumeBreakAfterPriority();
		} else {
			return null;
		}
	}
	
	private boolean firstUnitHasSupplements(SplitPointDataSource<RowGroup> spd) {
		return !spd.isEmpty() && !spd.get(0).getSupplementaryIDs().isEmpty();
	}
	
	private boolean hasPageAreaCollection() {
		return master.getPageArea()!=null && collection!=null;
	}
	
	private MarginProperties getMarginRegionValue(MarginRegion mr, RowImpl r, boolean rightSide) throws PaginatorException {
		String ret = "";
		int w = mr.getWidth();
		if (mr instanceof MarkerIndicatorRegion) {
			ret = firstMarkerForRow(r, (MarkerIndicatorRegion)mr);
			if (ret.length()>0) {
				try {
					ret = context.getDefaultTranslator().translate(Translatable.text(context.getConfiguration().isMarkingCapitalLetters()?ret:ret.toLowerCase()).build()).getTranslatedRemainder();
				} catch (TranslationException e) {
					throw new PaginatorException("Failed to translate: " + ret, e);
				}
			}
			boolean spaceOnly = ret.length()==0;
			if (ret.length()<w) {
				StringBuilder sb = new StringBuilder();
				if (rightSide) {
					while (sb.length()<w-ret.length()) { sb.append(context.getSpaceCharacter()); }
					sb.append(ret);
				} else {
					sb.append(ret);				
					while (sb.length()<w) { sb.append(context.getSpaceCharacter()); }
				}
				ret = sb.toString();
			} else if (ret.length()>w) {
				throw new PaginatorException("Cannot fit " + ret + " into a margin-region of size "+ mr.getWidth());
			}
			return new MarginProperties(ret, spaceOnly);
		} else {
			throw new PaginatorException("Unsupported margin-region type: " + mr.getClass().getName());
		}
	}
	
	private String firstMarkerForRow(RowImpl r, MarkerIndicatorRegion mrr) {
		return mrr.getIndicators().stream()
				.filter(mi -> r.hasMarkerWithName(mi.getName()))
				.map(mi -> mi.getIndicator())
				.findFirst().orElse("");
	}
	
	private void addProperties(RowGroup rg) {
		if (rg.getIdentifier()!=null) {
			insertIdentifier(rg.getIdentifier());
		}
		currentPage().addMarkers(rg.getMarkers());
		//TODO: addGroupAnchors
		setKeepWithNextSheets(rg.getKeepWithNextSheets());
		setKeepWithPreviousSheets(rg.getKeepWithPreviousSheets());
	}
	
	private void reassignCollection() throws PaginatorException {
		//reassign collection
		if (areaProps!=null) {
			int i = 0;
			for (FallbackRule r : areaProps.getFallbackRules()) {
				i++;
				if (r instanceof RenameFallbackRule) {
					collection = context.getCollections().remove(r.applyToCollection());
					if (context.getCollections().put(((RenameFallbackRule)r).getToCollection(), collection)!=null) {
						throw new PaginatorException("Fallback id already in use:" + ((RenameFallbackRule)r).getToCollection());
					}							
				} else {
					throw new PaginatorException("Unknown fallback rule: " + r);
				}
			}
			if (i==0) {
				throw new PaginatorException("Failed to fit collection '" + areaProps.getCollectionId() + "' within the page-area boundaries, and no fallback was defined.");
			}
		}
	}
	
	private class CollectionData implements Supplements<RowGroup> {
		private PageImpl page;
		private final BlockContext c;
		private final Map<String, RowGroup> map;
		
		private CollectionData(BlockContext c) {
			this.c = c;
			this.page = null;
			this.map = new HashMap<>();
		}

		@Override
		public RowGroup get(String id) {
			if (collection!=null) {
				if (page!=currentPage()) {
					map.clear();
				}
				RowGroup ret = map.get(id);
				if (ret==null) {
					RowGroup.Builder b = new RowGroup.Builder(master.getRowSpacing());
					for (Block g : collection.getBlocks(id)) {
						AbstractBlockContentManager bcm = g.getBlockContentManager(c);
						b.addAll(bcm.getCollapsiblePreContentRows());
						b.addAll(bcm.getInnerPreContentRows());
						for (RowImpl r : bcm) {
							b.add(r);
						}
						b.addAll(bcm.getPostContentRows());
						b.addAll(bcm.getSkippablePostContentRows());
					}
					if (page==null || page!=currentPage()) {
						page = currentPage();
						b.overhead(page.staticAreaSpaceNeeded());
					}
					ret = b.build();
					map.put(id, ret);
				} 
				return ret;
			} else {
				return null;
			}
		}
		
	}
	
	private int calculateVerticalSpace(BlockPosition p, int blockSpace) {
		if (p != null) {
			int pos = p.getPosition().makeAbsolute(currentPage().getFlowHeight());
			int t = pos - spaceUsedOnPage(0);
			if (t > 0) {
				int advance = 0;
				switch (p.getAlignment()) {
				case BEFORE:
					advance = t - blockSpace;
					break;
				case CENTER:
					advance = t - blockSpace / 2;
					break;
				case AFTER:
					advance = t;
					break;
				}
				return (int)Math.floor(advance / master.getRowSpacing());
			}
		}
		return 0;
	}
	
	private void addPage(PageImpl p) {
		items.add(p);
		setToIndex(getToIndex() + 1);
	}

	/**
	 * Gets the layout master for this sequence
	 * @return returns the layout master for this sequence
	 */
	LayoutMaster getLayoutMaster() {
		return master;
	}

	public int getPageNumberOffset() {
		return pageNumberOffset;
	}

	@Override
	public SectionProperties getSectionProperties() {
		return master;
	}

	@Override
	public List<? extends Page> getPages() {
		return getItems();
	}


}
