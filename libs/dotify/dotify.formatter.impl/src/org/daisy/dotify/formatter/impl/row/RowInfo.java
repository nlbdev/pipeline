package org.daisy.dotify.formatter.impl.row;

import org.daisy.dotify.common.text.StringTools;

class RowInfo {
	final String preTabText;
	final int preTabTextLen;
	final String preContent;
	final int preTabPos;
	final int maxLenText;
	final RowImpl.Builder row;
	RowInfo(String preContent, RowImpl.Builder r, int available) {
		this.preTabText = r.getText();
		this.row = r;
		this.preContent = preContent;
		int preContentPos = r.getLeftMargin().getContent().length()+StringTools.length(preContent);
		this.preTabTextLen = StringTools.length(preTabText);
		this.preTabPos = preContentPos+preTabTextLen;
		this.maxLenText = available-(preContentPos);
		if (this.maxLenText<1) {
			throw new RuntimeException("Cannot continue layout: No space left for characters.");
		}
	}
}