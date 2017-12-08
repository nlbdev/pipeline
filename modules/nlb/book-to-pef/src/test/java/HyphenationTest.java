import java.io.File;
import java.io.IOException;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.util.Iterator;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Stream;
import javax.inject.Inject;

import ch.sbs.jhyphen.StandardHyphenationException;

import static org.daisy.pipeline.braille.common.Query.util.mutableQuery;
import org.daisy.pipeline.braille.common.Hyphenator;
import org.daisy.pipeline.braille.common.HyphenatorProvider;

import static org.daisy.pipeline.pax.exam.Options.domTraversalPackage;
import static org.daisy.pipeline.pax.exam.Options.felixDeclarativeServices;
import static org.daisy.pipeline.pax.exam.Options.logbackClassic;
import static org.daisy.pipeline.pax.exam.Options.logbackConfigFile;
import static org.daisy.pipeline.pax.exam.Options.mavenBundles;
import static org.daisy.pipeline.pax.exam.Options.mavenBundlesWithDependencies;
import static org.daisy.pipeline.pax.exam.Options.thisPlatform;

import org.junit.Assert;
import org.junit.runner.RunWith;
import org.junit.Test;

import org.ops4j.pax.exam.Configuration;
import static org.ops4j.pax.exam.CoreOptions.junitBundles;
import static org.ops4j.pax.exam.CoreOptions.options;
import static org.ops4j.pax.exam.CoreOptions.systemPackage;
import org.ops4j.pax.exam.junit.PaxExam;
import org.ops4j.pax.exam.Option;
import org.ops4j.pax.exam.spi.reactors.ExamReactorStrategy;
import org.ops4j.pax.exam.spi.reactors.PerClass;
import org.ops4j.pax.exam.util.PathUtils;

@RunWith(PaxExam.class)
@ExamReactorStrategy(PerClass.class)
public class HyphenationTest {
	
	private static final int TEST_EVERY_OTHER_NTH_WORD = 1;
	private static final char GOOD_HYPHEN = '*';
	private static final char MISSED_HYPHEN = '-';
	private static final char BAD_HYPHEN = '.';
	
	@Inject
	HyphenatorProvider<Hyphenator> hyphenatorProvider;
	
	@Test
	public void testHyphenation() throws IOException {
		File baseDir = new File(PathUtils.getBaseDir());
		File dicFile = new File(baseDir, "src/main/resources/hyph/hyph_nb_NO.dic");
		Hyphenator hyphenator = hyphenatorProvider
			.get(mutableQuery().add("libhyphen-table", dicFile.toURI().toASCIIString()))
			.iterator()
			.next();
		Hyphenator.FullHyphenator standardHyphenator = hyphenator.asFullHyphenator();
		Hyphenator.LineBreaker nonStandardHyphenator = hyphenator.asLineBreaker();
		int bad = 0;
		int missed = 0;
		File wordsFile = new File(baseDir, "src/main/resources/hyph/hyph_nb_NO_standard_dictionary/words.txt");
		System.err.println();
		System.err.println("Checking " + wordsFile);
		System.err.println();
		try (Stream<String> wordsStream = Files.lines(wordsFile.toPath(), Charset.forName("ISO-8859-1"))) {
			Iterator<String> words = wordsStream.iterator();
			int line = 0;
			while (words.hasNext()) {
				if (line++ % TEST_EVERY_OTHER_NTH_WORD != 0) {
					words.next();
					continue;
				}
				HyphenationTestResult r = testHyphens(standardHyphenator, nonStandardHyphenator, words.next(), line);
				if (r.missed > 0) {
					missed += r.missed;
					System.err.println("On line " + line + ": missed hyphens: " + r.hyphens);
				}
				if (r.bad > 0) {
					bad += r.bad;
					System.err.println("On line " + line + ": bad hyphens: " + r.hyphens);
				}
			}
		}
		File nonStandardPatternsFile = new File(baseDir, "src/main/resources/hyph/hyph_nb_NO_nonstandard_dictionary/words.txt");
		System.err.println();
		System.err.println("Checking " + nonStandardPatternsFile);
		System.err.println();
		try (Stream<String> patternsStream = Files.lines(nonStandardPatternsFile.toPath(), Charset.forName("ISO-8859-1"))) {
			Iterator<String> patterns = patternsStream.iterator();
			int line = 0;
			while (patterns.hasNext()) {
				if (line++ % TEST_EVERY_OTHER_NTH_WORD != 0) {
					patterns.next();
					continue;
				}
				HyphenationTestResult r = testHyphens(nonStandardHyphenator, patterns.next(), line);
				if (r.missed > 0) {
					missed += r.missed;
					System.err.println("On line " + line + ": missed hyphens: " + r.hyphens);
				}
				if (r.bad > 0) {
					bad += r.bad;
					System.err.println("On line " + line + ": bad hyphens: " + r.hyphens);
				}
			}
		}
		if (missed > 0)
			System.err.println("WARNING: " + missed + " missed hyphens");
		if (bad > 0)
			throw new AssertionError(bad + " bad hyphens");
	}
	
	private HyphenationTestResult testHyphens(Hyphenator.FullHyphenator fullHyphenator, Hyphenator.LineBreaker lineBreaker,
	                                          String hyphenatedWord, int lineNo) {
		String word = hyphenatedWord.replace("-", "");
		String expected = hyphenatedWord;
		try {
			String actual = fullHyphenator.transform(word).replace("­", "-");
			int good = 0;
			int bad = 0;
			int missed = 0;
			int ee = 0;
			int aa = 0;
			while (true) {
				if (ee == expected.length()) {
					if (aa == actual.length())
						break;
					else
						throw new RuntimeException();
				} else if (aa == actual.length())
					throw new RuntimeException();
				char e = expected.charAt(ee);
				char a = actual.charAt(aa);
				if (e == '-') {
					if (a == '-') {
						good++;
						actual = actual.substring(0, aa) + GOOD_HYPHEN + actual.substring(aa + 1);
					} else {
						missed++;
						actual = actual.substring(0, aa) + MISSED_HYPHEN + actual.substring(aa);
					}
					aa++;
					ee++;
				} else {
					if (a == '-') {
						bad++;
						actual = actual.substring(0, aa) + BAD_HYPHEN + actual.substring(aa + 1);
					} else if (a != e)
						throw new RuntimeException();
					else {
						ee++;
					}
					aa++;
				}
			}
			return new HyphenationTestResult(lineNo, actual, good, bad, missed);
		} catch (RuntimeException ex) {
			Throwable cause = ex.getCause();
			if (cause == null || !(cause instanceof StandardHyphenationException))
				throw ex;
			// word contains non-standard hyphenation points, fall back to LineBreaker api
			Hyphenator.LineIterator lines = lineBreaker.transform(word);
			String actual = "";
			int good = 0;
			int bad = 0;
			int missed = 0;
			int ee = 0;
			// System.err.println("ee: " + ee);
			int aa = 0;
			// System.err.println("aa: " + aa);
			int maybeBadAt = -1;
			boolean nonStandard = false;
			while (true) {
				if (aa == actual.length() && lines.hasNext()) {
					for (int w = 2;; w++) {
						String line = lines.nextLine(w, false);
						if (!line.isEmpty()) {
							if (lines.hasNext() && !lines.lineHasHyphen())
								throw new RuntimeException();
							if (aa > 0)
								actual += "-";
							actual += line;
							// System.err.println("actual: " + actual);
							break;
						}
					}
				}
				if (ee == expected.length()) {
					if (aa == actual.length()) {
						if (maybeBadAt >= 0) {
							if (nonStandard)
								actual = actual.substring(0, maybeBadAt) + GOOD_HYPHEN + actual.substring(maybeBadAt + 1);
							else {
								bad++;
								actual = actual.substring(0, maybeBadAt) + BAD_HYPHEN + actual.substring(maybeBadAt + 1);
							}
							// System.err.println("actual: " + actual);
						}
						break;
					} else
						throw new RuntimeException();
				} else if (aa == actual.length())
					throw new RuntimeException();
				char e = expected.charAt(ee);
				// System.err.println("e: " + e);
				char a = actual.charAt(aa);
				// System.err.println("a: " + a);
				if (e == '-') {
					if (maybeBadAt >= 0) {
						if (nonStandard)
							actual = actual.substring(0, maybeBadAt) + GOOD_HYPHEN + actual.substring(maybeBadAt + 1);
						else {
							bad++;
							actual = actual.substring(0, maybeBadAt) + BAD_HYPHEN + actual.substring(maybeBadAt + 1);
						}
						// System.err.println("actual: " + actual);
						maybeBadAt = -1;
					}
					if (a == '-') {
						good++;
						actual = actual.substring(0, aa) + GOOD_HYPHEN + actual.substring(aa + 1);
					} else {
						missed++;
						actual = actual.substring(0, aa) + MISSED_HYPHEN + actual.substring(aa);
					}
					// System.err.println("actual: " + actual);
					aa++;
					// System.err.println("aa: " + aa);
					ee++;
					// System.err.println("ee: " + ee);
					nonStandard = false;
					// System.err.println("nonStandard: " + nonStandard);
				} else {
					if (a == '-') {
						if (!nonStandard) {
							if (maybeBadAt >= 0) {
								bad++;
								actual = actual.substring(0, maybeBadAt) + BAD_HYPHEN + actual.substring(maybeBadAt + 1);
								// System.err.println("actual: " + actual);
							}
							maybeBadAt = aa;
							// System.err.println("maybeBadAt: " + maybeBadAt);
						} else
							while (true) {
								if (aa + 1 >= actual.length())
									throw new RuntimeException();
								if (actual.charAt(aa + 1) == e)
									break;
								aa++;
								// System.err.println("aa: " + aa);
							}
						nonStandard = false;
						// System.err.println("nonStandard: " + nonStandard);
					} else if (a != e) {
						// assume this mismatch is because of non-standard hyphenation
						nonStandard = true;
						// System.err.println("nonStandard: " + nonStandard);
						// also assume that the only cases of non-standard hyphenation are when letters are added
					} else {
						ee++;
						// System.err.println("ee: " + ee);
					}
					aa++;
					// System.err.println("aa: " + aa);
				}
			}
			return new HyphenationTestResult(lineNo, actual, good, bad, missed);
		}
	}
	
	private final static Pattern HYPHEN_PATTERN
		= Pattern.compile("^(?<word>[^/]+)/(?<rep>[^-]+-[^,]+),(?<pos>[1-9][0-9]*),(?<cut>[1-9][0-9]*)$");
	
	private HyphenationTestResult testHyphens(Hyphenator.LineBreaker hyphenator, String pattern, int lineNo) {
		Matcher m = HYPHEN_PATTERN.matcher(pattern);
		if (!m.matches())
			throw new RuntimeException();
		String word = m.group("word").replaceAll("-", "");
		String rep = m.group("rep");
		int pos = Integer.parseInt(m.group("pos"));
		int cut = Integer.parseInt(m.group("cut"));
		String expected = word.substring(0, pos - 1) + rep + word.substring(pos - 1 + cut);
		Hyphenator.LineIterator lines = hyphenator.transform(word);
		String actual = "";
		int good = 0;
		int bad = 0;
		int missed = 0;
		int ee = 0;
		// System.err.println("ee: " + ee);
		int aa = 0;
		// System.err.println("aa: " + aa);
		while (true) {
			if (aa == actual.length() && lines.hasNext()) {
				for (int w = 2;; w++) {
					String line = lines.nextLine(w, false);
					if (!line.isEmpty()) {
						if (lines.hasNext() && !lines.lineHasHyphen())
							throw new RuntimeException();
						if (aa > 0)
							actual += "-";
						actual += line;
						// System.err.println("actual: " + actual);
						break;
					}
				}
			}
			if (ee == expected.length()) {
				if (aa == actual.length()) {
					break;
				} else
					throw new RuntimeException();
			} else if (aa == actual.length())
				throw new RuntimeException();
			char e = expected.charAt(ee);
			// System.err.println("e: " + e);
			char a = actual.charAt(aa);
			// System.err.println("a: " + a);
			if (e == '-') {
				if (a == '-') {
					good++;
					expected = expected.substring(0, ee) + GOOD_HYPHEN + expected.substring(ee + 1);
				} else {
					missed++;
					expected = expected.substring(0, ee) + MISSED_HYPHEN + expected.substring(ee + 1);
				}
				// System.err.println("expected: " + expected);
				aa++;
				// System.err.println("aa: " + aa);
				ee++;
				// System.err.println("ee: " + ee);
			} else {
				if (a == '-') {
					// assume this is because of standard hyphenation
					expected = expected.substring(0, ee) + GOOD_HYPHEN + expected.substring(ee);
					// System.err.println("expected: " + expected);
				} else if (a != e) {
					// assume this is because of a missed non-standard hyphenation
					// also assume that the only cases of non-standard hyphenation are when letters are added
					while (true) {
						if (ee + 1 >= expected.length())
							throw new RuntimeException();
						ee++;
						// System.err.println("ee: " + ee);
						e = expected.charAt(ee);
						if (e == '-')
							throw new RuntimeException();
						if (e == a)
							break;
					}
					ee++;
				} else {
					ee++;
					// System.err.println("ee: " + ee);
				}
				aa++;
				// System.err.println("aa: " + aa);
			}
		}
		return new HyphenationTestResult(lineNo, expected, good, bad, missed);
	}
	
	private class HyphenationTestResult {
		final int lineNo;
		final String hyphens;
		final int good;   // true positives
		final int bad;    // false positives
		final int missed; // false negatives
		HyphenationTestResult(int lineNo, String hyphens, int good, int bad, int missed) {
			this.lineNo = lineNo;
			this.hyphens = hyphens;
			this.good = good;
			this.bad = bad;
			this.missed = missed;
		}
	}
	
	@Configuration
	public Option[] config() {
		try {
			return options(
				logbackConfigFile(),
				domTraversalPackage(),
				felixDeclarativeServices(),
				junitBundles(),
				systemPackage("com.sun.org.apache.xml.internal.resolver"),
				systemPackage("com.sun.org.apache.xml.internal.resolver.tools"),
				mavenBundlesWithDependencies(
					mavenBundles(
						"org.daisy.pipeline.modules.braille:libhyphen-core:?",
						"org.daisy.pipeline.modules.braille:libhyphen-native:jar:" + thisPlatform() + ":?",
						"org.slf4j:jul-to-slf4j:?",
						"org.daisy.pipeline:logging-activator:?",
						"org.slf4j:jcl-over-slf4j:1.7.2"),
					logbackClassic()));
		} catch (RuntimeException e) {
			e.printStackTrace();
			throw e;
		}
	}
}
