package org.daisy.dotify.formatter.impl;

import java.util.Stack;

/**
 * Provides a page oriented structure
 * 
 * @author Joel Håkansson
 */
class PageStruct {
	private final Stack<PageImpl> pages;
	private PageSequenceBuilder2 currentSeq;

	PageStruct() {
		pages = new Stack<>();
		currentSeq = null;
	}

	void add(PageSequenceBuilder2 seq) {
		currentSeq = seq;
	}

	int getCurrentPageOffset() {
		if (currentSeq!=null) {
			if (currentSeq.getLayoutMaster().duplex() && (currentSeq.size() % 2)==1) {
				return currentSeq.getPageNumberOffset() + currentSeq.size() + 1;
			} else {
				return currentSeq.getPageNumberOffset() + currentSeq.size();
			}
		} else {
			return 0;
		}
	}

	Stack<PageImpl> getPages() {
		return pages;
	}

}