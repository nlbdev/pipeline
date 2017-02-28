import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import javax.inject.Inject;

import org.daisy.pipeline.braille.common.BrailleTranslator;
import org.daisy.pipeline.braille.common.BrailleTranslatorProvider;
import org.daisy.pipeline.braille.common.CSSStyledText;
import org.daisy.pipeline.braille.common.Hyphenator;
import org.daisy.pipeline.braille.common.HyphenatorProvider;
import org.daisy.pipeline.braille.common.TransformProvider;
import static org.daisy.pipeline.braille.common.TransformProvider.util.dispatch;
import static org.daisy.pipeline.braille.common.Query.util.query;

import org.daisy.pipeline.junit.AbstractXSpecAndXProcSpecTest;

import static org.daisy.pipeline.pax.exam.Options.thisPlatform;

import static org.junit.Assert.assertEquals;
import org.junit.Test;

import org.osgi.framework.BundleContext;
import org.osgi.framework.ServiceReference;

public class NLBTest extends AbstractXSpecAndXProcSpecTest {
	
	@Inject
	private BundleContext context;
	
	private TransformProvider<BrailleTranslator> translatorProvider() {
		try {
			List<BrailleTranslatorProvider<BrailleTranslator>> providers
				= new ArrayList<BrailleTranslatorProvider<BrailleTranslator>>();
			for (ServiceReference<? extends BrailleTranslatorProvider> ref :
				     context.getServiceReferences(BrailleTranslatorProvider.class, null))
				providers.add(context.getService(ref));
			return dispatch(providers); }
		catch (Exception e) {
			throw new RuntimeException(e); }
	}
	
	private TransformProvider<Hyphenator> hyphenatorProvider() {
		try {
			List<HyphenatorProvider<Hyphenator>> providers
				= new ArrayList<HyphenatorProvider<Hyphenator>>();
			for (ServiceReference<? extends HyphenatorProvider> ref :
				     context.getServiceReferences(HyphenatorProvider.class, null))
				providers.add(context.getService(ref));
			return dispatch(providers); }
		catch (Exception e) {
			throw new RuntimeException(e); }
	}
	
	@Test
	public void testEmail() throws Exception {
		BrailleTranslator translator = translatorProvider().get(query("(translator:nlb)(grade:1)")).iterator().next();
		assertEquals(
			braille("⠋⠕⠕ ⠣⠋⠕⠕⠃⠁⠗⠈⠝⠇⠃⠄⠝⠕⠜ ⠃⠼"),
			translator.fromStyledTextToBraille()
			          .transform(styledText("foo foobar@nlb.no bar", "")));
	}
	
	@Test
	public void testBrailleTranslatorUncontracted() throws Exception {
		BrailleTranslator translator = translatorProvider().get(query("(translator:nlb)(grade:1)")).iterator().next();
		assertEquals(
			braille("⠋⠕⠕⠃⠼ ","⠋⠕⠕⠃⠁⠗"),
			translator.fromStyledTextToBraille()
			          .transform(styledText("foobar ", "",
			                                "foobar",  "text-transform: uncontracted")));
	}
	
	@Test
	public void testNonStandardHyphenation() {
		Hyphenator hyphenator = hyphenatorProvider().get(query("(libhyphen-table:'http://www.nlb.no/hyphen/hyph_nb_NO.dic')")).iterator().next();
		assertEquals("buss-\n" +
		             "stopp",
		             fillLines(hyphenator.asLineBreaker().transform("busstopp"), 6, '-'));
		BrailleTranslator translator = translatorProvider().get(query("(translator:nlb)(grade:1)")).iterator().next();
		assertEquals("⠃⠥⠎⠎⠤\n" +
		             "⠎⠞⠕⠏⠏",
		             fillLines(translator.lineBreakingFromStyledText().transform(styledText("busstopp","hyphens:auto")), 6));
	}
	
	@Override
	protected String[] testDependencies() {
		return new String[] {
			brailleModule("css-utils"),
			brailleModule("pef-utils"),
			brailleModule("liblouis-core"),
			brailleModule("liblouis-utils"),
			brailleModule("liblouis-tables"),
			"org.daisy.pipeline.modules.braille:liblouis-native:jar:" + thisPlatform() + ":?",
			brailleModule("libhyphen-core"),
			brailleModule("libhyphen-libreoffice-tables"),
			"org.daisy.pipeline.modules.braille:libhyphen-native:jar:" + thisPlatform() + ":?",
			brailleModule("dotify-formatter"),
			brailleModule("dtbook-to-pef"),
			brailleModule("epub3-to-pef"),
			brailleModule("html-to-pef"),
			brailleModule("xml-to-pef"),
			pipelineModule("file-utils"),
			pipelineModule("common-utils"),
			pipelineModule("html-utils"),
			pipelineModule("zip-utils"),
			pipelineModule("mediatype-utils"),
			pipelineModule("file-utils"),
			pipelineModule("fileset-utils"),
			"org.daisy.pipeline:calabash-adapter:?",
		};
	}
	
	private Iterable<CSSStyledText> styledText(String... textAndStyle) {
		List<CSSStyledText> styledText = new ArrayList<CSSStyledText>();
		String text = null;
		boolean textSet = false;
		for (String s : textAndStyle) {
			if (textSet)
				styledText.add(new CSSStyledText(text, s));
			else
				text = s;
			textSet = !textSet; }
		if (textSet)
			throw new RuntimeException();
		return styledText;
	}
	
	private Iterable<String> braille(String... text) {
		return Arrays.asList(text);
	}
	
	private static String fillLines(BrailleTranslator.LineIterator lines, int width) {
		String s = "";
		while (lines.hasNext()) {
			s += lines.nextTranslatedRow(width, true);
			if (lines.hasNext())
				s += '\n'; }
		return s;
	}
	
	private static String fillLines(Hyphenator.LineIterator lines, int width, char hyphen) {
		String s = "";
		while (lines.hasNext()) {
			lines.mark();
			String line = lines.nextLine(width, true);
			if (lines.lineHasHyphen())
				line += hyphen;
			if (line.length() > width) {
				lines.reset();
				line = lines.nextLine(width - 1, true);
				if (lines.lineHasHyphen())
					line += hyphen; }
			s += line;
			if (lines.hasNext())
				s += '\n'; }
		return s;
	}
}
