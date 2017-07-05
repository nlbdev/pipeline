package org.daisy.dotify.formatter.impl.search;

public class SequenceId {
	private final int ordinal;
	private final DocumentSpace space;
	
	public SequenceId(int ordinal, DocumentSpace space) {
		this.ordinal = ordinal;
		this.space = space;
	}
	
	int getOrdinal() {
		return ordinal;
	}
	
	DocumentSpace getSpace() {
		return space;
	}

}
