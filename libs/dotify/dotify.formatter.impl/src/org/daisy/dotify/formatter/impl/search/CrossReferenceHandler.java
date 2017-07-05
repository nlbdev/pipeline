package org.daisy.dotify.formatter.impl.search;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

public class CrossReferenceHandler {
	private final LookupHandler<String, Integer> pageRefs;
	private final LookupHandler<String, Integer> volumeRefs;
	private final LookupHandler<Integer, Iterable<AnchorData>> anchorRefs;
	private final LookupHandler<String, Integer> variables;
	private final LookupHandler<SheetIdentity, Boolean> breakable;
	private final Map<Integer, Overhead> volumeOverhead;
	private final SearchInfo searchInfo;
	private static final String VOLUMES_KEY = "volumes";
	private static final String SHEETS_IN_VOLUME = "sheets-in-volume-";
	private static final String SHEETS_IN_DOCUMENT = "sheets-in-document";
	private static final String PAGES_IN_VOLUME = "pages-in-volume-";
	private static final String PAGES_IN_DOCUMENT = "pages-in-document";
    private Set<String> pageIds;
	private boolean overheadDirty = false;
	
	public CrossReferenceHandler() {
		this.pageRefs = new LookupHandler<>();
		this.volumeRefs = new LookupHandler<>();
		this.anchorRefs = new LookupHandler<>();
		this.variables = new LookupHandler<>();
		this.breakable = new LookupHandler<>();
		this.volumeOverhead = new HashMap<>();
		this.searchInfo = new SearchInfo();
        this.pageIds = new HashSet<>();
	}
	
	/**
	 * Gets the volume for the specified identifier.
	 * @param refid the identifier to get the volume for
	 * @return returns the volume number, one-based
	 */
	public Integer getVolumeNumber(String refid) {
		return volumeRefs.get(refid);
	}
	
	public void setVolumeNumber(String refid, int volume) {
		volumeRefs.put(refid, volume);
	}
	
	/**
	 * Gets the page number for the specified identifier.
	 * @param refid the identifier to get the page for
	 * @return returns the page number, one-based
	 */
	public Integer getPageNumber(String refid) {
		return pageRefs.get(refid);
	}
	
	public void setPageNumber(String refid, int page) {
        if (!pageIds.add(refid)) {
            throw new IllegalArgumentException("Identifier not unique: " + refid);
        }
		pageRefs.put(refid, page);
	}
	
	public Iterable<AnchorData> getAnchorData(int volume) {
		return anchorRefs.get(volume);
	}
	
	public void setAnchorData(int volume, Iterable<AnchorData> data) {
		anchorRefs.put(volume, data);
	}
	
	public void setVolumeCount(int volumes) {
		variables.put(VOLUMES_KEY, volumes);
	}
	
	public void setSheetsInVolume(int volume, int value) {
		variables.put(SHEETS_IN_VOLUME+volume, value);
	}
	
	public void setSheetsInDocument(int value) {
		variables.put(SHEETS_IN_DOCUMENT, value);
	}
	
	private void setPagesInVolume(int volume, int value) {
		//TODO: use this method
		variables.put(PAGES_IN_VOLUME+volume, value);
	}
	
	private void setPagesInDocument(int value) {
		//TODO: use this method
		variables.put(PAGES_IN_DOCUMENT, value);
	}
	
	public void keepBreakable(SheetIdentity ident, boolean value) {
		breakable.keep(ident, value);
	}
	
	public void commitBreakable() {
		breakable.commit();
	}
	
	public void trimPageDetails() {
		//FIXME: implement
	}
	
	public Overhead getOverhead(int volumeNumber) {
		if (volumeNumber<1) {
			throw new IndexOutOfBoundsException("Volume must be greater than or equal to 1");
		}
		if (volumeOverhead.get(volumeNumber)==null) {
			volumeOverhead.put(volumeNumber, new Overhead(0, 0));
			overheadDirty = true;
		}
		return volumeOverhead.get(volumeNumber);
	}
	
	public void setOverhead(int volumeNumber, Overhead overhead) {
		volumeOverhead.put(volumeNumber, overhead);
	}

	/**
	 * Gets the number of volumes.
	 * @return returns the number of volumes
	 */
	public int getVolumeCount() {
		return variables.get(VOLUMES_KEY, 1);
	}
	
	public int getSheetsInVolume(int volume) {
		return variables.get(SHEETS_IN_VOLUME+volume, 0);
	}

	public int getSheetsInDocument() {
		return variables.get(SHEETS_IN_DOCUMENT, 0);
	}
	
	public int getPagesInVolume(int volume) {
		return variables.get(PAGES_IN_VOLUME+volume, 0);
	}

	public int getPagesInDocument() {
		return variables.get(PAGES_IN_DOCUMENT, 0);
	}
	
	public boolean getBreakable(SheetIdentity ident) {
		return breakable.get(ident, true);
	}
	
	public SearchInfo getSearchInfo() {
		return searchInfo;
	}

	public boolean isDirty() {
		return pageRefs.isDirty() || volumeRefs.isDirty() || anchorRefs.isDirty() || variables.isDirty() || breakable.isDirty() || overheadDirty;
	}
	
	public void setDirty(boolean value) {
		pageRefs.setDirty(value);
		volumeRefs.setDirty(value);
		anchorRefs.setDirty(value);
		variables.setDirty(value);
		breakable.setDirty(value);
		overheadDirty = value;
	}

    public void resetUniqueChecks() {
        pageIds = new HashSet<>();
    }

}
