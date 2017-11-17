package org.daisy.dotify.formatter.impl.sheet;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Optional;

import org.daisy.dotify.api.writer.SectionProperties;
import org.daisy.dotify.common.split.SplitPointDataSource;
import org.daisy.dotify.common.split.SplitResult;
import org.daisy.dotify.common.split.Supplements;
import org.daisy.dotify.formatter.impl.core.FormatterContext;
import org.daisy.dotify.formatter.impl.page.BlockSequence;
import org.daisy.dotify.formatter.impl.page.PageImpl;
import org.daisy.dotify.formatter.impl.page.PageSequenceBuilder2;
import org.daisy.dotify.formatter.impl.page.PageStruct;
import org.daisy.dotify.formatter.impl.page.RestartPaginationException;
import org.daisy.dotify.formatter.impl.search.DefaultContext;
import org.daisy.dotify.formatter.impl.search.DocumentSpace;
import org.daisy.dotify.formatter.impl.search.SheetIdentity;

/**
 * Provides a data source for sheets. Given a list of 
 * BlockSequences, sheets are produced one by one.
 * 
 * @author Joel Håkansson
 */
public class SheetDataSource implements SplitPointDataSource<Sheet> {
	//Global state
	private final PageStruct struct;
	private final FormatterContext context;
	//Input data
	private final DefaultContext rcontext;
	private final Integer volumeGroup;
	private final List<BlockSequence> seqsIterator;
	private final int sheetOffset;
	//Local state
	private int seqsIndex;
	private PageSequenceBuilder2 psb;
	private SectionProperties sectionProperties;
	private int sheetIndex;
	private int pageIndex;
	private String counter;
	private int initialPageOffset;
	private boolean volBreakAllowed;
	private boolean updateCounter;
	//Output buffer
	private List<Sheet> sheetBuffer;

	private int keepNextSheets = 0;

	public SheetDataSource(PageStruct struct, FormatterContext context, DefaultContext rcontext, Integer volumeGroup, List<BlockSequence> seqsIterator) {
		this.struct = struct;
		this.context = context;
		this.rcontext = rcontext;
		this.volumeGroup = volumeGroup;
		this.seqsIterator = seqsIterator;
		this.sheetBuffer = new ArrayList<>();
		this.volBreakAllowed = true;
		this.sheetOffset = 0;
		this.seqsIndex = 0;
		this.psb = null;
		this.sectionProperties = null;
		this.sheetIndex = 0;
		this.pageIndex = 0;
		this.counter = null;
		this.initialPageOffset = 0;
		this.updateCounter = false;
	}
	
	public SheetDataSource(SheetDataSource template) {
		this(template, 0);
	}
	
	private SheetDataSource(SheetDataSource template, int offset) {
		this.struct = new PageStruct(template.struct);
		this.context = template.context;
		this.rcontext = template.rcontext;
		this.volumeGroup = template.volumeGroup;
		this.seqsIterator = template.seqsIterator;
		this.seqsIndex = template.seqsIndex;
		this.psb = PageSequenceBuilder2.copyUnlessNull(template.psb);
		this.sectionProperties = template.sectionProperties;
		this.sheetOffset = template.sheetOffset+offset;
		this.sheetIndex = template.sheetIndex;
		this.pageIndex = template.pageIndex;
		if (template.sheetBuffer.size()>offset) {
			this.sheetBuffer = new ArrayList<>(template.sheetBuffer.subList(offset, template.sheetBuffer.size()));
		} else {
			this.sheetBuffer = new ArrayList<>();
		}
		this.volBreakAllowed = template.volBreakAllowed;
		this.counter = template.counter;
		this.initialPageOffset = template.initialPageOffset;
		this.updateCounter = template.updateCounter;
	}
	
	@Override
	public Sheet get(int index) throws RestartPaginationException {
		if (!ensureBuffer(index+1)) {
			throw new IndexOutOfBoundsException("" + index);
		}
		return sheetBuffer.get(index);
	}

	@Override
	@Deprecated
	public List<Sheet> head(int toIndex) throws RestartPaginationException {
		throw new UnsupportedOperationException("Method is deprecated.");
	}

	@Override
	public List<Sheet> getRemaining() throws RestartPaginationException {
		ensureBuffer(-1);
		return sheetBuffer;
	}

	@Override
	@Deprecated
	public SplitPointDataSource<Sheet> tail(int fromIndex) throws RestartPaginationException {
		throw new UnsupportedOperationException("Method is deprecated.");
	}

	@Override
	public boolean hasElementAt(int index) throws RestartPaginationException {
		return ensureBuffer(index+1);
	}

	@Override
	public int getSize(int limit)  throws RestartPaginationException {
		if (!ensureBuffer(limit-1))  {
			//we have buffered all elements
			return sheetBuffer.size();
		} else {
			return limit;
		}
	}

	@Override
	public boolean isEmpty() {
		return seqsIndex>=seqsIterator.size() && sheetBuffer.isEmpty() && (psb==null || !psb.hasNext());
	}

	@Override
	public Supplements<Sheet> getSupplements() {
		return null;
	}
	
	/**
	 * Ensures that there are at least index elements in the buffer.
	 * When index is -1 this method always returns false.
	 * @param index the index (or -1 to get all remaining elements)
	 * @return returns true if the index element was available, false otherwise
	 */
	private boolean ensureBuffer(int index) {
		Sheet.Builder s = null;
		SheetIdentity si = null;
		while (index<0 || sheetBuffer.size()<index) {
			if (updateCounter) { 
				if(counter!=null) {
					initialPageOffset = rcontext.getRefs().getPageNumberOffset(counter) - psb.size();
				} else {
					initialPageOffset = struct.getDefaultPageOffset() - psb.size();
				}
				updateCounter = false;
			}
			if (psb==null || !psb.hasNext()) {
				if (s!=null) {
					//Last page in the sequence doesn't need volume keep priority
					sheetBuffer.add(s.build());
					s=null;
					continue;
				}
				if (seqsIndex>=seqsIterator.size()) {
					// cannot ensure buffer, return false
					return false;
				}
				// init new sequence
				BlockSequence bs = seqsIterator.get(seqsIndex);
				seqsIndex++;
				counter = bs.getSequenceProperties().getPageCounterName().orElse(null);
				if (bs.getInitialPageNumber()!=null) {
					 initialPageOffset = bs.getInitialPageNumber() - 1;
				} else if (counter!=null) {
					initialPageOffset = Optional.ofNullable(rcontext.getRefs().getPageNumberOffset(counter)).orElse(0);
				} else {
					 initialPageOffset = struct.getDefaultPageOffset();
				}
				psb = new PageSequenceBuilder2(struct.getPageCount(), bs.getLayoutMaster(), initialPageOffset, bs, context, rcontext, seqsIndex);
				if (keepNextSheets > 0) {
					psb.keepNextSheets = keepNextSheets;
					keepNextSheets = 0;
				}
				sectionProperties = bs.getLayoutMaster().newSectionProperties();
				s = null;
				si = null;
				sheetIndex = 0;
				pageIndex = 0;
			}
			int currentSize = sheetBuffer.size();
			while (psb.hasNext() && currentSize == sheetBuffer.size()) {
				if (!sectionProperties.duplex() || pageIndex % 2 == 0) {
					if (s!=null) {
						Sheet r = s.build();
						sheetBuffer.add(r);
						s = null;
						continue;
					}
					volBreakAllowed = true;
					s = new Sheet.Builder(sectionProperties);
					si = new SheetIdentity(rcontext.getSpace(), rcontext.getCurrentVolume(), volumeGroup, sheetBuffer.size()+sheetOffset);
					sheetIndex++;
				}
				PageImpl p = psb.nextPage(initialPageOffset);
				struct.increasePageCount();
				s.avoidVolumeBreakAfterPriority(p.getAvoidVolumeBreakAfter());
				boolean br = rcontext.getRefs().getBreakable(si);
				//TODO: the following is a low effort way of giving existing uses of non-breakable units a high priority, but it probably shouldn't be done this way
				if (!br) {
					s.avoidVolumeBreakAfterPriority(1);
				}
				s.breakable(br);

				setPreviousSheet(si.getSheetIndex()-1, Math.min(p.keepPreviousSheets(), sheetIndex-1), rcontext);
				volBreakAllowed &= p.allowsVolumeBreak();
				if (!sectionProperties.duplex() || pageIndex % 2 == 1) {
					rcontext.getRefs().keepBreakable(si, volBreakAllowed);
				}
				s.add(p);
				pageIndex++;
				if (!psb.hasNext()) {
					keepNextSheets = psb.keepNextSheets;
					if (keepNextSheets > 0 && (!sectionProperties.duplex() || pageIndex % 2 == 1)) {
						keepNextSheets--;
						volBreakAllowed = false;
					}
					rcontext.getRefs().keepBreakable(si, volBreakAllowed);
				}
			}
			if (!psb.hasNext()) {
				rcontext.getRefs().setSequenceScope(new DocumentSpace(rcontext.getSpace(), rcontext.getCurrentVolume()), seqsIndex, psb.getGlobalStartIndex(), psb.getToIndex());
				if (counter!=null) {
					rcontext.getRefs().setPageNumberOffset(counter, initialPageOffset + psb.getSizeLast());
				} else {
					struct.setDefaultPageOffset(initialPageOffset + psb.getSizeLast());
				}
			}
		}
		return true;
	}

	private void setPreviousSheet(int start, int p, DefaultContext rcontext) {
		int i = 0;
		//TODO: simplify this?
		for (int x = start; i < p && x > 0; x--) {
			SheetIdentity si = new SheetIdentity(rcontext.getSpace(), rcontext.getCurrentVolume(), volumeGroup, x);
			rcontext.getRefs().keepBreakable(si, false);
			i++;
		}
	}

	@Override
	public SplitResult<Sheet> split(int atIndex) {
		if (!ensureBuffer(atIndex)) {
			throw new IndexOutOfBoundsException("" + atIndex);
		}
		if (counter!=null) {
			rcontext.getRefs().setPageNumberOffset(counter, initialPageOffset + psb.getSizeLast());
		} else {
			struct.setDefaultPageOffset(initialPageOffset + psb.getSizeLast());
		}
		SheetDataSource tail = new SheetDataSource(this, atIndex);
		tail.updateCounter = true;
		if (atIndex==0) {
			return new SplitResult<Sheet>(Collections.emptyList(), tail);
		} else {
			return new SplitResult<Sheet>(sheetBuffer.subList(0, atIndex), tail);
		}
	}

}
