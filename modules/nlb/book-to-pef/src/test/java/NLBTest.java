import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.inject.Inject;

import org.daisy.maven.xproc.xprocspec.XProcSpecRunner;

import org.daisy.pipeline.braille.common.BrailleTranslator;
import org.daisy.pipeline.braille.common.BrailleTranslatorProvider;
import org.daisy.pipeline.braille.common.CSSStyledText;
import org.daisy.pipeline.braille.common.Hyphenator;
import org.daisy.pipeline.braille.common.HyphenatorProvider;
import org.daisy.pipeline.braille.common.TransformProvider;
import static org.daisy.pipeline.braille.common.TransformProvider.util.dispatch;
import static org.daisy.pipeline.braille.common.Query.util.query;

import static org.daisy.pipeline.pax.exam.Options.brailleModule;
import static org.daisy.pipeline.pax.exam.Options.calabashConfigFile;
import static org.daisy.pipeline.pax.exam.Options.domTraversalPackage;
import static org.daisy.pipeline.pax.exam.Options.felixDeclarativeServices;
import static org.daisy.pipeline.pax.exam.Options.logbackClassic;
import static org.daisy.pipeline.pax.exam.Options.mavenBundle;
import static org.daisy.pipeline.pax.exam.Options.mavenBundlesWithDependencies;
import static org.daisy.pipeline.pax.exam.Options.logbackConfigFile;
import static org.daisy.pipeline.pax.exam.Options.pipelineModule;
import static org.daisy.pipeline.pax.exam.Options.thisBundle;
import static org.daisy.pipeline.pax.exam.Options.xprocspec;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import org.junit.Test;
import org.junit.runner.RunWith;

import org.ops4j.pax.exam.Configuration;
import org.ops4j.pax.exam.junit.PaxExam;
import org.ops4j.pax.exam.Option;
import org.ops4j.pax.exam.spi.reactors.ExamReactorStrategy;
import org.ops4j.pax.exam.spi.reactors.PerClass;
import org.ops4j.pax.exam.util.PathUtils;

import static org.ops4j.pax.exam.CoreOptions.junitBundles;
import static org.ops4j.pax.exam.CoreOptions.options;
import static org.ops4j.pax.exam.CoreOptions.systemPackage;

import org.osgi.framework.BundleContext;
import org.osgi.framework.ServiceReference;

@RunWith(PaxExam.class)
@ExamReactorStrategy(PerClass.class)
public class NLBTest {
	
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
	
	@Inject
	private XProcSpecRunner xprocspecRunner;
	
	@Test
	public void runXProcSpec() throws Exception {
		File baseDir = new File(PathUtils.getBaseDir());
		Map<String,File> tests = new HashMap<String,File>();
		for (String test : new String[]{
			"test_css_formatter",
			"test_css_translator",
			"test_dtbook-to-pef",
			"test_dtbook-to-pef_hyphenation",
			"test_epub3-to-pef",
			"test_html-to-pef",
			"test_script",
			"test_translator"
			})
			tests.put(test, new File(baseDir, "src/test/xprocspec/" + test + ".xprocspec"));
		boolean success = xprocspecRunner.run(tests,
		                                      new File(baseDir, "target/xprocspec-reports"),
		                                      new File(baseDir, "target/surefire-reports"),
		                                      new File(baseDir, "target/xprocspec"),
		                                      null,
		                                      new XProcSpecRunner.Reporter.DefaultReporter());
		assertTrue("XProcSpec tests should run with success", success);
	}
	
	@Configuration
	public Option[] config() {
		return options(
			logbackConfigFile(),
			calabashConfigFile(),
			domTraversalPackage(),
			felixDeclarativeServices(),
			thisBundle(),
			junitBundles(),
			systemPackage("javax.xml.stream;version=\"1.0.1\""),
			mavenBundlesWithDependencies(
				brailleModule("css-utils"),
				brailleModule("pef-utils"),
				brailleModule("liblouis-core"),
				brailleModule("liblouis-utils"),
				brailleModule("liblouis-tables"),
				brailleModule("liblouis-native").forThisPlatform(),
				brailleModule("libhyphen-core"),
				brailleModule("libhyphen-libreoffice-tables"),
				brailleModule("libhyphen-native").forThisPlatform(),
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
				logbackClassic(),
				xprocspec(),
				mavenBundle("org.daisy.maven:xproc-engine-daisy-pipeline:?")
			)
		);
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
