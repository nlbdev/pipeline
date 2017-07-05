package org.daisy.dotify.formatter.impl;

class PageFullException extends Exception {
	
	private static final long serialVersionUID = -463645830012511731L;
	
	private final int effectiveFlowHeight;
	private final boolean headerRowTooShort;
	
	PageFullException(int effectiveFlowHeight, boolean headerRowTooShort) {
		this.effectiveFlowHeight = effectiveFlowHeight;
		this.headerRowTooShort = headerRowTooShort;
	}
	
	int getEffectiveFlowHeight() {
		return effectiveFlowHeight;
	}
	
	boolean isHeaderRowTooShort() {
		return headerRowTooShort;
	}
}
