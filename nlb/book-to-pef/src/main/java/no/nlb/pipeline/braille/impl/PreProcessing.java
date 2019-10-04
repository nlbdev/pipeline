package no.nlb.pipeline.braille.impl;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

import com.google.common.collect.Iterables;

import cz.vutbr.web.css.CSSProperty;
import org.daisy.braille.css.SimpleInlineStyle;

import org.daisy.braille.css.BrailleCSSProperty.WhiteSpace;
import org.daisy.pipeline.braille.common.CSSStyledText;

public class PreProcessing {

	private final static Pattern SPACE_ELLIPSIS = Pattern.compile( "[^\\s]\\s+…" );

	// Replace a space between a word and an ellipsis with a non-breaking space.
	// This is technically part of pre-processing, but for convenience it is included in the
	// braille translation, because this way we automatically get access to the style information.
	static CSSStyledText dontBreakBeforeEllipsis(CSSStyledText styledText) {
		SimpleInlineStyle style = styledText.getStyle();
		CSSProperty whiteSpace = style == null ? WhiteSpace.NORMAL : style.getProperty("white-space");
		if (whiteSpace == WhiteSpace.PRE_WRAP);
		else {
			String text = styledText.getText();
			Matcher m = SPACE_ELLIPSIS.matcher(text);
			StringBuilder b = null;
			int i = 0;
			while (m.find()) {
				if (b == null) b = new StringBuilder();
				b.append(text.substring(i, m.start()));
				String s = text.substring(m.start(), m.end());
				if (whiteSpace == WhiteSpace.PRE_LINE && s.indexOf('\n') >= 0)
					b.append(s);
				else
					b.append(s.charAt(0)).append(" …");
				i = m.end();
			}
			if (i > 0) {
				b.append(text.substring(i));
				styledText = new CSSStyledText(b.toString(), style, styledText.getTextAttributes());
			}
		}
		return styledText;
	}

	static Iterable<CSSStyledText> dontBreakBeforeEllipsis(Iterable<CSSStyledText> styledText) {
		return Iterables.transform(styledText, PreProcessing::dontBreakBeforeEllipsis);
	}

	private PreProcessing() {
		// no instantiation
	}
}
