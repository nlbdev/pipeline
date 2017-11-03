package org.daisy.dotify.formatter.impl;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import org.daisy.dotify.common.split.SplitPointDataSource;
import org.daisy.dotify.common.split.Supplements;
import org.daisy.dotify.formatter.impl.search.CrossReferenceHandler;
import org.daisy.dotify.formatter.impl.search.DocumentSpace;
import org.daisy.dotify.formatter.impl.search.SheetIdentity;

class SheetDataSource implements SplitPointDataSource<Sheet> {
	private final PageStruct struct;
	private final CrossReferenceHandler crh;
	private final FormatterContext context;
	private final DefaultContext rcontext;
	private final Integer volumeGroup;
	private final Iterator<BlockSequence> seqsIterator;
	private final int sheetsServed;
	private int seqsServed;
	
	private List<Sheet> sheetBuffer;
	private boolean volBreakAllowed;
	private int keepNextSheets = 0;

	SheetDataSource(PageStruct struct, CrossReferenceHandler crh, FormatterContext context, DefaultContext rcontext, Integer volumeGroup, Iterator<BlockSequence> seqsIterator) {
		this(struct, crh, context, rcontext, volumeGroup, seqsIterator, new ArrayList<>(), true, 0, 0);
	}
	
	SheetDataSource(PageStruct struct, CrossReferenceHandler crh, FormatterContext context, DefaultContext rcontext, Integer volumeGroup, Iterator<BlockSequence> seqsIterator, List<Sheet> sheetBuffer, boolean volBreakAllowed, int sheetsServed, int seqsServed) {
		this.struct = struct;
		this.crh = crh;
		this.context = context;
		this.rcontext = rcontext;
		this.volumeGroup = volumeGroup;
		this.seqsIterator = seqsIterator;
		this.sheetBuffer = sheetBuffer;
		this.volBreakAllowed = volBreakAllowed;
		this.sheetsServed = sheetsServed;
		this.seqsServed = seqsServed;
	}

	@Override
	public Sheet get(int index) throws RestartPaginationException {
		if (!ensureBuffer(index)) {
			throw new IndexOutOfBoundsException("" + index);
		}
		return sheetBuffer.get(index);
	}

	@Override
	public List<Sheet> head(int toIndex) throws RestartPaginationException {
		if (!ensureBuffer(toIndex-1)) {
			throw new IndexOutOfBoundsException();
		}
		return sheetBuffer.subList(0, toIndex);
	}

	@Override
	public List<Sheet> getRemaining() throws RestartPaginationException {
		ensureBuffer(-1);
		return sheetBuffer;
	}

	@Override
	public SplitPointDataSource<Sheet> tail(int fromIndex) throws RestartPaginationException {
		List<Sheet> newBuffer;
		if (!ensureBuffer(fromIndex)) {
			newBuffer = new ArrayList<>();
		} else {
			newBuffer = sheetBuffer.subList(fromIndex, sheetBuffer.size());
		}
		return new SheetDataSource(struct, crh, context, rcontext, volumeGroup, seqsIterator, newBuffer, volBreakAllowed, sheetsServed+fromIndex, seqsServed);
	}

	@Override
	public boolean hasElementAt(int index) throws RestartPaginationException {
		return ensureBuffer(index);
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
		return !seqsIterator.hasNext() && sheetBuffer.isEmpty();
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
		while (index<0 || sheetBuffer.size()<=index) {
			if (!seqsIterator.hasNext()) {
				crh.commitBreakable();
				crh.trimPageDetails();
				// cannot ensure buffer, return false
				return false;
			}
			BlockSequence bs = seqsIterator.next();
			seqsServed++;
			int offset = struct.getCurrentPageOffset();
			PageSequenceBuilder2 psb = new PageSequenceBuilder2(struct, bs.getLayoutMaster(), bs.getInitialPageNumber()!=null?bs.getInitialPageNumber() - 1:offset, crh, bs, context, rcontext, seqsServed);
			if (keepNextSheets > 0) {
				psb.keepNextSheets = keepNextSheets;
				keepNextSheets = 0;
			}
			LayoutMaster lm = bs.getLayoutMaster();
			Sheet.Builder s = null;
			SheetIdentity si = null;
			int sheetIndex = 0;
			int pageIndex = 0;
			while (psb.hasNext()) {
				PageImpl p = psb.nextPage();
				if (!lm.duplex() || pageIndex % 2 == 0) {
					volBreakAllowed = true;
					if (s!=null) {
						Sheet r = s.build();
						sheetBuffer.add(r);
					}
					s = new Sheet.Builder(psb);
					si = new SheetIdentity(rcontext.getSpace(), rcontext.getCurrentVolume(), volumeGroup, sheetsServed + sheetBuffer.size());
					sheetIndex++;
				}
				s.avoidVolumeBreakAfterPriority(p.getAvoidVolumeBreakAfter());
				boolean br = crh.getBreakable(si);
				//TODO: the following is a low effort way of giving existing uses of non-breakable units a high priority, but it probably shouldn't be done this way
				if (!br) {
					s.avoidVolumeBreakAfterPriority(1);
				}
				s.breakable(br);

				setPreviousSheet(si.getSheetIndex()-1, Math.min(p.keepPreviousSheets(), sheetIndex-1), rcontext);
				volBreakAllowed &= p.allowsVolumeBreak();
				if (!lm.duplex() || pageIndex % 2 == 1) {
					crh.keepBreakable(si, volBreakAllowed);
				}
				s.add(p);
				pageIndex++;
			}
			if (s!=null) {
				keepNextSheets = psb.keepNextSheets;
				if (keepNextSheets > 0 && (!lm.duplex() || pageIndex % 2 == 1)) {
					keepNextSheets--;
					volBreakAllowed = false;
				}
				crh.keepBreakable(si, volBreakAllowed);
				sheetBuffer.add(s.build());
			}
			crh.getSearchInfo().setSequenceScope(new DocumentSpace(rcontext.getSpace(), rcontext.getCurrentVolume()), seqsServed, psb.getGlobalStartIndex(), psb.getToIndex());
			struct.add(psb);
		}
		return true;
	}
	
	
	private void setPreviousSheet(int start, int p, DefaultContext rcontext) {
		int i = 0;
		//TODO: simplify this?
		for (int x = start; i < p && x > 0; x--) {
			SheetIdentity si = new SheetIdentity(rcontext.getSpace(), rcontext.getCurrentVolume(), volumeGroup, x);
			crh.keepBreakable(si, false);
			i++;
		}
	}

}
