package org.daisy.dotify.formatter.impl.search;

public final class PageId {
	private final int ordinal;
	private final int globalStartIndex;
	private final SequenceId sequenceId;
	
	public PageId(int ordinal, int globalStartIndex, SequenceId sequenceId) {
		this.ordinal = ordinal;
		this.globalStartIndex = globalStartIndex;
		this.sequenceId = sequenceId;		
	}
	
	public int getOrdinal() {
		return ordinal;
	}
	
	PageId with(int ordinal) {
		return new PageId(ordinal, this.globalStartIndex, this.sequenceId);
	}
	
	int getPageIndex() {
		return globalStartIndex + ordinal;
	}
	
	SequenceId getSequenceId() {
		return sequenceId;
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + globalStartIndex;
		result = prime * result + ordinal;
		result = prime * result + ((sequenceId == null) ? 0 : sequenceId.hashCode());
		return result;
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		PageId other = (PageId) obj;
		if (globalStartIndex != other.globalStartIndex)
			return false;
		if (ordinal != other.ordinal)
			return false;
		if (sequenceId == null) {
			if (other.sequenceId != null)
				return false;
		} else if (!sequenceId.equals(other.sequenceId))
			return false;
		return true;
	}

	@Override
	public String toString() {
		return "PageId [ordinal=" + ordinal + ", globalStartIndex=" + globalStartIndex + ", sequenceId=" + sequenceId
				+ "]";
	}

}
