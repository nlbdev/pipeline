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
import org.daisy.pipeline.braille.liblouis.LiblouisTranslator;

import org.daisy.pipeline.junit.AbstractXSpecAndXProcSpecTest;

import static org.daisy.pipeline.pax.exam.Options.thisPlatform;
import static org.daisy.pipeline.pax.exam.Options.mavenBundle;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import org.junit.Test;

import org.ops4j.pax.exam.Configuration;
import static org.ops4j.pax.exam.CoreOptions.composite;
import static org.ops4j.pax.exam.CoreOptions.options;
import org.ops4j.pax.exam.Option;

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
	public void testQuery() throws Exception {
		{
			BrailleTranslator translator = translatorProvider().get(query(
				"(input:css)(output:css)(translator:nlb)(locale:no)(grade:0)"
			)).iterator().next();
			assertNotNull(translator);
		}
		{
			BrailleTranslator translator = translatorProvider().get(query(
				"(input:html)(input:css)(output:html)(output:css)(output:braille)(translator:nlb)(grade:0)(locale:no)"
			)).iterator().next();
			assertNotNull(translator);
		}
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
	
	/*@Override @Test
	public void runXSpec() throws Exception {
		// skip
	}
	
	@Override @Test
	public void runXProcSpec() throws Exception {
		// skip
	}*/
	
	@Test
	public void testNonStandardHyphenation() {
		Hyphenator hyphenator = hyphenatorProvider().get(query("(libhyphen-table:'http://www.nlb.no/hyphen/hyph_nb_NO.dic')")).iterator().next();
		assertEquals("buss-\n" +
		             "stopp",
		             fillLines(hyphenator.asLineBreaker().transform("busstopp"), 5, '-'));
		BrailleTranslator translator = translatorProvider().get(query("(translator:nlb)(grade:1)")).iterator().next();
		assertEquals("⠃⠥⠎⠎⠤\n" +
		             "⠎⠞⠕⠏⠏",
		             fillLines(translator.lineBreakingFromStyledText().transform(styledText("busstopp","hyphens:auto")), 5));
	}
	
	@Inject
	LiblouisTranslator.Provider liblouisProvider;
	
	// see https://github.com/nlbdev/pipeline/issues/70
	@Test
	public void testIssue70() throws Exception {
		LiblouisTranslator grade0Translator
			= liblouisProvider.get(query("(liblouis-table:'http://www.liblouis.org/tables/no-no-g0.utb')")).iterator().next();
		LiblouisTranslator translator
			= liblouisProvider.get(query("(liblouis-table:'http://www.liblouis.org/tables/no-no-g1.ctb')")).iterator().next();
		assertEquals(
			braille("⠰⠁ ⠃ ⠁ ⠰⠇"),
			translator.fromStyledTextToBraille()
			          .transform(styledText("a ble at l", "")));
		
		grade0Translator.fromStyledTextToBraille()
		                .transform(styledText("punkt@nlb.no", ""));
		assertEquals(
			braille("⠰⠁ ⠃ ⠁ ⠰⠇"),
			translator.fromStyledTextToBraille()
			          .transform(styledText("a ble at l", "")));
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
			pipelineModule("common-entities"),
			"org.daisy.pipeline:calabash-adapter:?",
			// logging
			"org.slf4j:jul-to-slf4j:?",
			"org.daisy.pipeline:logging-activator:?",
			// FIXME: because otherwise excluded through com.fasterxml.woodstox:woodstox-core exclusion
			"org.codehaus.woodstox:stax2-api:?",
		};
	}
	
	@Override @Configuration
	public Option[] config() {
		return options(
			// FIXME: BrailleUtils needs older version of jing
			mavenBundle("org.daisy.libs:jing:20120724.0.0"),
			composite(super.config()));
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
