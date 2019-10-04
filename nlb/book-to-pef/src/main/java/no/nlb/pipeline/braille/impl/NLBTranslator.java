package no.nlb.pipeline.braille.impl;

import java.net.URI;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import static java.nio.file.Files.createTempDirectory;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.NoSuchElementException;
import java.util.regex.Pattern;

import com.google.common.base.MoreObjects;
import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableMap;
import static com.google.common.collect.Iterables.size;
import com.google.common.collect.Lists;
import com.google.common.collect.Maps;

import cz.vutbr.web.css.CSSProperty;
import cz.vutbr.web.css.Term;
import cz.vutbr.web.css.TermIdent;
import cz.vutbr.web.css.TermList;

import org.daisy.braille.css.BrailleCSSProperty.TextTransform;
import org.daisy.braille.css.SimpleInlineStyle;

import org.daisy.common.file.URIs;
import org.daisy.common.file.URLs;

import org.daisy.dotify.api.translator.UnsupportedMetricException;

import org.daisy.pipeline.braille.common.AbstractBrailleTranslator;
import org.daisy.pipeline.braille.common.AbstractTransformProvider;
import org.daisy.pipeline.braille.common.AbstractTransformProvider.util.Function;
import org.daisy.pipeline.braille.common.AbstractTransformProvider.util.Iterables;
import static org.daisy.pipeline.braille.common.AbstractTransformProvider.util.Iterables.concat;
import static org.daisy.pipeline.braille.common.AbstractTransformProvider.util.logCreate;
import static org.daisy.pipeline.braille.common.AbstractTransformProvider.util.logSelect;
import org.daisy.pipeline.braille.common.BrailleTranslator;
import org.daisy.pipeline.braille.common.BrailleTranslatorProvider;
import org.daisy.pipeline.braille.common.CSSStyledText;
import org.daisy.pipeline.braille.common.Hyphenator;
import org.daisy.pipeline.braille.common.HyphenatorProvider;
import org.daisy.pipeline.braille.common.Query;
import org.daisy.pipeline.braille.common.Query.Feature;
import org.daisy.pipeline.braille.common.Query.MutableQuery;
import static org.daisy.pipeline.braille.common.Query.util.mutableQuery;
import static org.daisy.pipeline.braille.common.Query.util.query;
import org.daisy.pipeline.braille.common.TransformationException;
import org.daisy.pipeline.braille.common.TransformProvider;
import static org.daisy.pipeline.braille.common.TransformProvider.util.dispatch;
import static org.daisy.pipeline.braille.common.TransformProvider.util.memoize;
import static org.daisy.pipeline.braille.common.TransformProvider.util.partial;
import static org.daisy.pipeline.braille.common.util.Files.normalize;
import static org.daisy.pipeline.braille.common.util.Iterables.combinations;
import static org.daisy.pipeline.braille.common.util.Locales.parseLocale;
import static org.daisy.pipeline.braille.common.util.Strings.splitInclDelimiter;
import org.daisy.pipeline.braille.liblouis.LiblouisTable;
import org.daisy.pipeline.braille.liblouis.LiblouisTranslator;

import org.osgi.service.component.annotations.Activate;
import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.component.annotations.ReferenceCardinality;
import org.osgi.service.component.annotations.ReferencePolicy;

public interface NLBTranslator {
	
	@Component(
		name = "no.nlb.pipeline.braille.impl.NLBTranslator.Provider",
		service = {
			BrailleTranslatorProvider.class,
			TransformProvider.class
		}
	)
	public static class Provider extends AbstractTransformProvider<BrailleTranslator> implements BrailleTranslatorProvider<BrailleTranslator> {
		
		private URI xprocHref;
		
		@Activate
		void activate(final Map<?,?> properties) {
			xprocHref = URIs.asURI(URLs.getResourceFromJAR("/xml/block-translate.xpl", NLBTranslator.class));
			otherLanguagesProvider = memoize(
				TransformProvider.util.cast(
					new LiblouisTranslatorWithUndefinedDotsProvider(liblouisTranslatorProvider, "26")));
		}
		
		private final static Iterable<BrailleTranslator> empty = Iterables.<BrailleTranslator>empty();
		
		private final static List<String> supportedInput = ImmutableList.of("css","text-css");
		private final static List<String> supportedOutput = ImmutableList.of("css","braille");
		private final static List<String> supportedInputOutput = ImmutableList.of("dtbook","html");
		
		private final static Query uncontracted = query("(contraction:no)");
		private final static Query contracted = query("(contraction:full)");
		
		/**
		 * Recognized features:
		 *
		 * - translator: Will only match if the value is `nlb'.
		 * - locale: Will only match if the language subtag is 'no'.
		 * - grade: `0', `1', `2' or `3'.
		 * - dots: `6', `8'. (default 6)
		 *
		 */
		protected final Iterable<BrailleTranslator> _get(Query query) {
			final MutableQuery q = mutableQuery(query);
			String inputFormat = null;
			for (Feature f : q.removeAll("input")) {
				String i = f.getValue().get();
				if (inputFormat == null && supportedInputOutput.contains(i))
					inputFormat = i;
				else if (!supportedInput.contains(i))
					return empty; }
			String outputFormat = null;
			for (Feature f : q.removeAll("output")) {
				String o = f.getValue().get();
				if (outputFormat == null && supportedInputOutput.contains(o))
					outputFormat = o;
				else if (!supportedOutput.contains(o))
					return empty; }
			if (outputFormat != null && (inputFormat == null || !inputFormat.equals(outputFormat)))
				return empty;
			final boolean htmlOrDtbookOut = (outputFormat != null);
			if (q.containsKey("locale")) {
				String locale = parseLocale(q.removeOnly("locale").getValue().get()).getLanguage();
				// If we want to use other tables for other languages in the future; it can be done here.
				// For now, we allow all languages as input.
				// The default CSS disables contraction for other languages.
			}
			if (q.containsKey("translator"))
				if ("nlb".equals(q.removeOnly("translator").getValue().get())) {
					final boolean forceNorwegian;
					if (q.containsKey("force-norwegian") && q.removeOnly("force-norwegian").getValue().get().equals("true"))
						forceNorwegian = true;
					else
						forceNorwegian = false;
					TransformProvider<BrailleTranslator> norwegianProvider = partial(q.asImmutable(), this.norwegianProvider);
					try {
						// check that main translators exist
						norwegianProvider.get(uncontracted).iterator().next();
						norwegianProvider.get(contracted).iterator().next();
					} catch (NoSuchElementException e) {
						return empty;
					}
					q.removeAll("grade");
					q.removeAll("dots");
					TransformProvider<BrailleTranslator> otherLanguagesProvider = partial(q, this.otherLanguagesProvider);
					return Iterables.of(
						logCreate(
							new TransformImpl(norwegianProvider,
							                  forceNorwegian ? norwegianProvider : otherLanguagesProvider,
							                  htmlOrDtbookOut,
							                  xprocHref)));
				}
			return empty;
		}
		
		private static class TransformImpl extends AbstractBrailleTranslator {
			
			private final XProc xproc;
			private final TransformProvider<BrailleTranslator> norwegianTranslator;
			private final TransformProvider<BrailleTranslator> otherLanguageTranslators;
			
			private TransformImpl(TransformProvider<BrailleTranslator> norwegianTranslator,
			                      TransformProvider<BrailleTranslator> otherLanguageTranslators,
			                      boolean htmlOrDtbookOut,
			                      URI xprocHref) {
				Map<String,String> options = ImmutableMap.<String,String>of(
					"text-transform", mutableQuery().add("id", this.getIdentifier()).toString(),
					// This will omit the <_ style="text-transform:none">
					// wrapper. It is assumed that if (output:html) or
					// (output:dtbook) is set, the result is known to be
					// braille (which is the case if (output:braille) is also
					// set).
					"no-wrap", String.valueOf(htmlOrDtbookOut));
				xproc = new XProc(xprocHref, null, options);
				this.norwegianTranslator = memoize(new HandleComputerAndUncontractedProvider(norwegianTranslator));
				this.otherLanguageTranslators = memoize(new HandleComputerAndUncontractedProvider(otherLanguageTranslators));
			}
			
			@Override
			public XProc asXProc() {
				return xproc;
			}
			
			@Override
			public FromStyledTextToBraille fromStyledTextToBraille() {
				return fromStyledTextToBraille;
			}
			
			private static abstract class TransformPerLanguage<T> {
				
				List<T> transform(java.lang.Iterable<CSSStyledText> styledText, int from, int to) {
					if (from < 0 || (to >= 0 && from > to))
						throw new IndexOutOfBoundsException();
					styledText = PreProcessing.dontBreakBeforeEllipsis(styledText);
					List<T> transformed = new ArrayList<>();
					if (from == to) return transformed;
					String curLang = null;
					int i = 0;
					for (CSSStyledText st : styledText) {
						Map<String,String> attrs = st.getTextAttributes();
						String lang = null;
						if (attrs != null)
							lang = attrs.remove("lang");
						if (!(lang == null && curLang == null || lang == curLang) && i > from) {
							for (T t : transform(styledText, from, to < i ? to : i, curLang))
								transformed.add(t);
							if (i < to)
								from = i;
							else
								return transformed; }
						curLang = lang;
						i++; }
					if (i > from)
						for (T t : transform(styledText, from, to < i ? to : i, curLang))
							transformed.add(t);
					return transformed;
				}
				
				abstract java.lang.Iterable<T> transform(java.lang.Iterable<CSSStyledText> styledText, int from, int to, String lang);
			}
			
			private final FromStyledTextToBraille fromStyledTextToBraille = new FromStyledTextToBraille() {
				TransformPerLanguage<String> impl = new TransformPerLanguage<String>() {
					java.lang.Iterable<String> transform(java.lang.Iterable<CSSStyledText> styledText, int from, int to, String lang) {
						return handleComputerAndUncontracted(lang).fromStyledTextToBraille().transform(styledText, from, to);
					}
				};
				public java.lang.Iterable<String> transform(java.lang.Iterable<CSSStyledText> styledText, int from, int to) {
					return impl.transform(styledText, from, to);
				}
			};
			
			@Override
			public LineBreakingFromStyledText lineBreakingFromStyledText() {
				return lineBreakingFromStyledText;
			}
			
			private final LineBreakingFromStyledText lineBreakingFromStyledText = new LineBreakingFromStyledText() {
				TransformPerLanguage<LineIterator> impl = new TransformPerLanguage<LineIterator>() {
					java.lang.Iterable<LineIterator> transform(java.lang.Iterable<CSSStyledText> styledText, int from, int to, String lang) {
						return Collections.singleton(
							handleComputerAndUncontracted(lang).lineBreakingFromStyledText().transform(styledText, from, to));
					}
				};
				public LineIterator transform(java.lang.Iterable<CSSStyledText> styledText, int from, int to) {
					return concatLineIterators(impl.transform(styledText, from, to));
				}
			};
			
			private BrailleTranslator handleComputerAndUncontracted(String lang) {
				TransformProvider<BrailleTranslator> p;
				MutableQuery q = mutableQuery();
				if (lang == null) {
					p = norwegianTranslator;
				} else {
					q.add("locale", lang);
					// FIXME: for foreign languages, handle text-transform:(un)contracted, but don't detect computer braille?
					p = otherLanguageTranslators;
				}
				try {
					return p.get(q).iterator().next();
				} catch (NoSuchElementException e) {
					throw new TransformationException("Could not find a sub-translator for language " + lang);
				}
			}
			
			@Override
			public String toString() {
				return MoreObjects.toStringHelper(NLBTranslator.class.getSimpleName())
					// .add("grade", grade)
					// .add("dots", dots)
					.toString();
			}
		}
		
		// mimicking liblouis behavior
		private final static Pattern COMPUTER = Pattern.compile(
			"(?<=^|[\\x20\t\\n\\r\\u2800\\xA0])[^\\x20\t\\n\\r\\u2800\\xA0]*"
			+ "(?://|www\\.|\\.com|\\.edu|\\.gov|\\.mil|\\.net|\\.org|\\.no|\\.nu|\\.se|\\.dk|\\.fi|\\.ini|\\.doc|\\.docx"
			+ "|\\.xml|\\.xsl|\\.htm|\\.html|\\.tex|\\.txt|\\.gif|\\.jpg|\\.png|\\.wav|\\.mp3|\\.m3u|\\.tar|\\.gz|\\.bz2|\\.zip)"
			+ "[^\\x20\t\\n\\r\\u2800\\xA0]*"
			+ "(?=[\\x20\t\\n\\r\\u2800\\xA0]|$)"
		);
		private final static String OPEN_COMPUTER = "\u2823"; // dots 126 (<)
		private final static String CLOSE_COMPUTER = "\u281C"; // dots 345 (>)
		
		/**
		 * A braille translator that detects urls and e-mail addresses, and handles the CSS
		 * text-transform values "uncontracted" and "contracted".
		 */
		private static class HandleComputerAndUncontracted extends AbstractBrailleTranslator {
			
			private final BrailleTranslator contractingTranslator;
			private final BrailleTranslator nonContractingTranslator;
			
			private HandleComputerAndUncontracted(BrailleTranslator contractingTranslator,
			                                      BrailleTranslator nonContractingTranslator) {
				this.contractingTranslator = contractingTranslator;
				this.nonContractingTranslator = nonContractingTranslator;
			}
			
			@Override
			public FromStyledTextToBraille fromStyledTextToBraille() {
				return fromStyledTextToBraille;
			}
			
			private static abstract class TransformImpl<T> {
				
				List<T> transform(java.lang.Iterable<CSSStyledText> styledText, int from, int to) {
					if (from < 0 || (to >= 0 && from > to))
						throw new IndexOutOfBoundsException();
					List<CSSStyledText> segments = new ArrayList<CSSStyledText>();
					// which segments are an url or e-mail address
					List<Boolean> computer = new ArrayList<Boolean>();
					// mapping from index in segments to index in styledText
					List<Integer> mapping = new ArrayList<Integer>();
					// from and to mapped to segments
					int fromSegment, toSegment; {
						int i = 0;
						fromSegment = -1;
						toSegment = -1;
						for (CSSStyledText st : styledText) {
							if (i == from)
								fromSegment = segments.size();
							if (i == to)
								toSegment = segments.size();
							String text = st.getText();
							if (text.isEmpty()) {
								segments.add(st);
								computer.add(false);
								mapping.add(i); }
							else {
								boolean c = false;
								boolean needStyleCopy = false;
								for (String s : splitInclDelimiter(text, COMPUTER)) {
									if (!s.isEmpty()) {
										SimpleInlineStyle style = st.getStyle();
										Map<String,String> attrs = st.getTextAttributes();
										if (needStyleCopy) {
											if (style != null)
												style = (SimpleInlineStyle)style.clone();
											if (attrs != null)
												attrs = new HashMap<String,String>(attrs); }
										segments.add(new CSSStyledText(s, style, attrs));
										computer.add(c);
										mapping.add(i);
										needStyleCopy = true; }
									c = !c; }}
							i++; }
						if (fromSegment < 0)
							throw new IndexOutOfBoundsException();
						if (toSegment < 0)
							toSegment = segments.size(); }
					int size = (to < 0 ? size(styledText) : to) - from;
					List<T> braille = new ArrayList<>();
					for (int i = 0; i < size; i++) braille.add(empty());
					int i = fromSegment;
					boolean curComputer = false;
					for (T b : transform(segments, fromSegment, toSegment, computer)) {
						if (!computer.get(i) && curComputer)
							braille.set(mapping.get(i) - from, add(braille.get(mapping.get(i) - from), closeComputer()));
						else if (computer.get(i) && !curComputer)
							braille.set(mapping.get(i) - from, add(braille.get(mapping.get(i) - from), openComputer()));
						braille.set(mapping.get(i) - from, add(braille.get(mapping.get(i) - from), b));
						curComputer = computer.get(i);
						i++; }
					if (curComputer)
						braille.set(mapping.get(i-1) - from, add(braille.get(mapping.get(i-1) - from), closeComputer()));
					return braille;
				}
				
				java.lang.Iterable<T> transform(java.lang.Iterable<CSSStyledText> styledText, int from, int to, List<Boolean> computer) {
					List<T> transformed = new ArrayList<>();
					if (from == to) return transformed;
					List<CSSStyledText> buffer = new ArrayList<CSSStyledText>();
					boolean curUncontracted = false;
					int i = 0;
					for (CSSStyledText st : styledText) {
						SimpleInlineStyle style = st.getStyle();
						boolean uncontracted; {
							uncontracted = false;
							if (style != null) {
								CSSProperty val = style.getProperty("text-transform");
								if (val != null) {
									if (val == TextTransform.list_values) {
										TermList values = style.getValue(TermList.class, "text-transform");
										
										// According to the spec values should be "applied" from left to right, and
										// values of inner elements always come before values of outer elements (see
										// http://braillespecs.github.io/braille-css/#the-text-transform-property). This
										// is the most logical situation in most cases. However the order in which
										// "uncontracted" and "contracted" should overwrite each other is exactly the
										// opposite. Therefore invert the list.
										Iterator<Term<?>> it = Lists.reverse(values).iterator();
										while (it.hasNext()) {
											String tt = ((TermIdent)it.next()).getValue();
											if (tt.equals("uncontracted")) {
												uncontracted = true;
												it.remove(); }
											else if (tt.equals("contracted")) { // means "allow contracted"
												uncontracted = false; // "contracted" overwrites "uncontracted" if it comes later in the list
												it.remove(); }}
										if (values.isEmpty())
											style.removeProperty("text-transform"); }}}
							if (computer != null)
								uncontracted = uncontracted || computer.get(i);
						}
						if (uncontracted != curUncontracted && !buffer.isEmpty()) {
							if (from < buffer.size())
								for (T s : transform(buffer, from, to < buffer.size() ? to : -1, curUncontracted))
									transformed.add(s);
							from -= buffer.size();
							if (from < 0) from = 0;
							if (to > 0) {
								to -= buffer.size();
								if (to <= 0)
									return transformed; }
							buffer = new ArrayList<CSSStyledText>(); }
						curUncontracted = uncontracted;
						buffer.add(st);
						i++; }
					if (!buffer.isEmpty() && from < buffer.size())
						for (T s : transform(buffer, from, to < buffer.size() ? to : -1, curUncontracted))
							transformed.add(s);
					return transformed;
				}
				
				abstract java.lang.Iterable<T> transform(java.lang.Iterable<CSSStyledText> styledText, int from, int to, boolean uncontracted);
				
				abstract T openComputer();
				abstract T closeComputer();
				abstract T empty();
				abstract T add(T a, T b);
			}
			
			private final FromStyledTextToBraille fromStyledTextToBraille = new FromStyledTextToBraille() {
				TransformImpl<String> impl = new TransformImpl<String>() {
					java.lang.Iterable<String> transform(java.lang.Iterable<CSSStyledText> styledText, int from, int to, boolean uncontracted) {
						return (uncontracted ? nonContractingTranslator : contractingTranslator)
						       .fromStyledTextToBraille().transform(styledText, from, to);
					}
					String openComputer() { return OPEN_COMPUTER; }
					String closeComputer() { return CLOSE_COMPUTER; }
					String empty() { return ""; }
					String add(String a, String b) { return a + b; }
				};
				public java.lang.Iterable<String> transform(java.lang.Iterable<CSSStyledText> styledText, int from, int to) {
					return impl.transform(styledText, from, to);
				}
			};
			
			@Override
			public LineBreakingFromStyledText lineBreakingFromStyledText() {
				return lineBreakingFromStyledText;
			}
			
			private final LineBreakingFromStyledText lineBreakingFromStyledText = new LineBreakingFromStyledText() {
				TransformImpl<LineIterator> impl = new TransformImpl<LineIterator>() {
					java.lang.Iterable<LineIterator> transform(java.lang.Iterable<CSSStyledText> styledText, int from, int to, boolean uncontracted) {
						return Collections.singleton(
							(uncontracted ? nonContractingTranslator : contractingTranslator)
							.lineBreakingFromStyledText().transform(styledText, from, to));
					}
					LineIterator openComputer() { return new NonBreakingBrailleString(OPEN_COMPUTER); }
					LineIterator closeComputer() { return new NonBreakingBrailleString(CLOSE_COMPUTER); }
					LineIterator empty() { return null; }
					LineIterator add(LineIterator a, LineIterator b) { return concatLineIterators(a, b); }
				};
				public LineIterator transform(java.lang.Iterable<CSSStyledText> styledText, int from, int to) {
					return concatLineIterators(impl.transform(styledText, from, to));
				}
			};
		}
		
		private static class NonBreakingBrailleString implements BrailleTranslator.LineIterator {
			
			private String remainder;
			
			private NonBreakingBrailleString(String string) {
				remainder = string;
			}
			
			public String nextTranslatedRow(int limit, boolean force, boolean wholeWordsOnly) {
				if (remainder.length() <= limit) {
					String next = remainder;
					remainder = null;
					return next; }
				else if (force) {
					String next = remainder.substring(0, limit);
					remainder = remainder.substring(limit);
					return next; }
				else
					return "";
			}
			
			public String getTranslatedRemainder() {
				return remainder;
			}
			
			public int countRemaining() {
				return (remainder != null) ? remainder.length() : 0;
			}
			
			public boolean hasNext() {
				return (remainder != null);
			}
			
			public NonBreakingBrailleString copy() {
				return new NonBreakingBrailleString(remainder);
			}
			
			public boolean supportsMetric(String metric) {
				return false;
			}
			
			public double getMetric(String metric) {
				throw new UnsupportedMetricException("Metric not supported: " + metric);
			}
		}
		
		private static BrailleTranslator.LineIterator concatLineIterators(BrailleTranslator.LineIterator a, BrailleTranslator.LineIterator b) {
			if (a == null)
				return b;
			else if (b == null)
				return a;
			else {
				List<BrailleTranslator.LineIterator> list = new ArrayList<>();
				list.add(a);
				list.add(b);
				return concatLineIterators(list);
			}
		}
		
		private static BrailleTranslator.LineIterator concatLineIterators(List<BrailleTranslator.LineIterator> iterators) {
			if (iterators.size() == 0)
				return new NonBreakingBrailleString(null);
			else if (iterators.size() == 1 && iterators.get(0) != null)
				return iterators.get(0);
			else
				return new ConcatLineIterators(iterators);
		}
		
		@Reference(
			name = "LiblouisTranslatorProvider",
			unbind = "unbindLiblouisTranslatorProvider",
			service = LiblouisTranslator.Provider.class,
			cardinality = ReferenceCardinality.MULTIPLE,
			policy = ReferencePolicy.DYNAMIC
		)
		protected void bindLiblouisTranslatorProvider(LiblouisTranslator.Provider provider) {
			liblouisTranslatorProviders.add(provider);
		}
	
		protected void unbindLiblouisTranslatorProvider(LiblouisTranslator.Provider provider) {
			liblouisTranslatorProviders.remove(provider);
			liblouisTranslatorProvider.invalidateCache();
		}
	
		private List<LiblouisTranslator.Provider> liblouisTranslatorProviders
		= new ArrayList<LiblouisTranslator.Provider>();
		private TransformProvider.util.MemoizingProvider<LiblouisTranslator> liblouisTranslatorProvider
		= memoize(dispatch(liblouisTranslatorProviders));
		
		@Reference(
			name = "HyphenatorProvider",
			unbind = "unbindHyphenatorProvider",
			service = HyphenatorProvider.class,
			cardinality = ReferenceCardinality.MULTIPLE,
			policy = ReferencePolicy.DYNAMIC
		)
		@SuppressWarnings(
			"unchecked" // safe cast to TransformProvider<Hyphenator>
		)
		protected void bindHyphenatorProvider(HyphenatorProvider<?> provider) {
			hyphenatorProviders.add((TransformProvider<Hyphenator>)provider);
		}
	
		protected void unbindHyphenatorProvider(HyphenatorProvider<?> provider) {
			hyphenatorProviders.remove(provider);
			hyphenatorProvider.invalidateCache();
		}
		
		private List<TransformProvider<Hyphenator>> hyphenatorProviders
		= new ArrayList<TransformProvider<Hyphenator>>();
		private TransformProvider.util.MemoizingProvider<Hyphenator> hyphenatorProvider
		= memoize(dispatch(hyphenatorProviders));
		private TransformProvider<BrailleTranslator> norwegianProvider
		= memoize(
			TransformProvider.util.cast(
				new NorwegianLiblouisTranslatorProvider(liblouisTranslatorProvider, hyphenatorProvider)));
		// created in activate method
		private TransformProvider<BrailleTranslator> otherLanguagesProvider;
		
		private final static Query grade0Table = mutableQuery().add("liblouis-table", "http://www.liblouis.org/tables/no-no-g0.utb");
		private final static Query grade1Table = mutableQuery().add("liblouis-table", "http://www.liblouis.org/tables/no-no-g1.ctb");
		private final static Query grade2Table = mutableQuery().add("liblouis-table", "http://www.liblouis.org/tables/no-no-g2.ctb");
		private final static Query grade3Table = mutableQuery().add("liblouis-table", "http://www.liblouis.org/tables/no-no-g3.ctb");
		private final static Query grade0Table8dot = mutableQuery().add("liblouis-table", "http://www.liblouis.org/tables/no-no-g0.utb");
		private final static Query hyphenationTable = mutableQuery().add("libhyphen-table", "http://www.nlb.no/hyphen/hyph_nb_NO.dic");
		private final static Query fallbackHyphenationTable1 = mutableQuery().add("libhyphen-table",
		                                                                          "http://www.libreoffice.org/dictionaries/hyphen/hyph_nb_NO.dic");
		private final static Query fallbackHyphenationTable2 = mutableQuery().add("hyphenator", "tex").add("locale", "nb");
		
		/*
		 * Provides translators based on the Norwegian Liblouis table. "contraction" determines
		 * whether contraction is applied or not. When the value is "full", contraction is applied
		 * with the contraction grade determined by "grade". "dots" can be "6" or "8". "locale"
		 * determines the hyphenation table. When "locale" is absent, Norwegian hyphenation rules
		 * are applied.
		 */
		private static class NorwegianLiblouisTranslatorProvider
				extends AbstractTransformProvider<LiblouisTranslator> implements BrailleTranslatorProvider<LiblouisTranslator> {
			
			final TransformProvider<LiblouisTranslator> liblouisTranslatorProvider;
			final TransformProvider<Hyphenator> hyphenatorProvider;
			
			NorwegianLiblouisTranslatorProvider(TransformProvider<LiblouisTranslator> liblouisTranslatorProvider,
			                                    TransformProvider<Hyphenator> hyphenatorProvider) {
				this.liblouisTranslatorProvider = liblouisTranslatorProvider;
				this.hyphenatorProvider = hyphenatorProvider;
			}
			
			protected Iterable<LiblouisTranslator> _get(final Query query) {
				MutableQuery q = mutableQuery(query);
				final int grade;
				if (q.containsKey("contraction") && q.removeOnly("contraction").getValue().get().equals("full")) {
					if (q.containsKey("grade")) {
						String v = q.removeOnly("grade").getValue().get();
						if (v.equals("0"))
							grade = 0;
						else if (v.equals("1"))
							grade = 1;
						else if (v.equals("2"))
							grade = 2;
						else if (v.equals("3"))
							grade = 3;
						else
							return empty;
					} else
						return empty;
				} else {
					q.removeAll("grade");
					grade = 0;
				}
				final int dots;
				if (q.containsKey("dots") && q.removeOnly("dots").getValue().get().equals("8"))
					dots = 8;
				else
					dots = 6;
				final Locale locale;
				if (q.containsKey("locale")) {
					locale = parseLocale(q.removeOnly("locale").getValue().get());
				} else
					locale = null;
				if (q.isEmpty()) {
					final Query liblouisTable;
					if (dots == 8)
						liblouisTable = grade0Table8dot;
					else
						liblouisTable = grade == 3 ? grade3Table : grade == 2 ? grade2Table : grade == 1 ? grade1Table : grade0Table;
					Iterable<Hyphenator> hyphenators;
					if (locale != null)
						hyphenators = logSelect(mutableQuery().add("locale", locale.getLanguage()), hyphenatorProvider);
					else
						hyphenators = concat(
							logSelect(hyphenationTable, hyphenatorProvider),
							concat(
								logSelect(fallbackHyphenationTable1, hyphenatorProvider),
								logSelect(fallbackHyphenationTable2, hyphenatorProvider)));
					return concat(
						Iterables.transform(
							concat(
								concat(
									Iterables.transform(
										hyphenators,
										new Function<Hyphenator,String>() {
											public String _apply(Hyphenator h) {
												return h.getIdentifier(); }}),
									"liblouis"),
								"none"),
							new Function<String,Iterable<LiblouisTranslator>>() {
								public Iterable<LiblouisTranslator> _apply(final String hyphenator) {
									return logSelect(mutableQuery(liblouisTable)
									                    .add("hyphenator", hyphenator)
									                    .add("handle-non-standard-hyphenation", "defer"),
									                 liblouisTranslatorProvider); }} ));
				} else
					return empty;
			}
			
			private final static Iterable<LiblouisTranslator> empty = Iterables.<LiblouisTranslator>empty();
			
		}
		
		private static class HandleComputerAndUncontractedProvider extends AbstractTransformProvider<BrailleTranslator>
				implements BrailleTranslatorProvider<BrailleTranslator> {
			
			private final TransformProvider<BrailleTranslator> backingProvider;
			
			HandleComputerAndUncontractedProvider(TransformProvider<BrailleTranslator> backingProvider) {
				this.backingProvider = backingProvider;
			}
			
			protected Iterable<BrailleTranslator> _get(final Query query) {
				TransformProvider<BrailleTranslator> partial = partial(query, backingProvider);
				return Iterables.transform(
					combinations(
						Maps.toMap(
							ImmutableList.of(contracted, uncontracted),
							contraction -> partial.get(contraction))),
					new Function<Map<Query,BrailleTranslator>,BrailleTranslator>() {
						public BrailleTranslator _apply(Map<Query,BrailleTranslator> subTranslators) {
							return new HandleComputerAndUncontracted(subTranslators.get(contracted),
							                                         subTranslators.get(uncontracted)); }});
			}
		}
		
		/*
		 * Provides Liblouis translators that return a fixed dot pattern for unknown
		 * characters. Only works correctly when based on Liblouis translators that can be
		 * represented correctly by their table URL only. That means that the queries may
		 * not contain "hyphenator" or "handle-non-standard-hyphenation".
		 */
		private static class LiblouisTranslatorWithUndefinedDotsProvider
				extends AbstractTransformProvider<LiblouisTranslator> implements BrailleTranslatorProvider<LiblouisTranslator> {
			
			final TransformProvider<LiblouisTranslator> backingProvider;
			final File undefinedTable;
			
			LiblouisTranslatorWithUndefinedDotsProvider(TransformProvider<LiblouisTranslator> backingProvider,
			                                            String dots) {
				this.backingProvider = backingProvider;
				File directory; {
					try {
						directory = createTempDirectory("pipeline-").toFile(); }
					catch (Exception e) {
						throw new RuntimeException("Could not create temporary directory", e); }
					directory.deleteOnExit();
				}
				directory = normalize(directory);
				this.undefinedTable = new File(directory, "undefined.cti");
				try {
					undefinedTable.createNewFile();
					FileOutputStream writer = new FileOutputStream(undefinedTable);
					// FIXME: avoid error "Dot pattern \.../ is not defined"
					// -> this should be fixed properly in Liblouis!
					// writer.write(("sign ... " + dots + "\n").getBytes());
					writer.write(("undefined " + dots + "\n").getBytes());
					writer.flush();
					writer.close();
				} catch (IOException e) {
					throw new RuntimeException(e);
				}
			}
				
			protected final Iterable<LiblouisTranslator> _get(Query query) {
				// locale needed to select correct hyphenator
				final String locale = query.containsKey("locale")
					? query.get("locale").iterator().next().getValue().get()
					: null;
				query = mutableQuery(query).add("output", "ascii");
				return Iterables.concat(
					Iterables.transform(
						logSelect(query, backingProvider.get(query)),
						new Function<LiblouisTranslator,Iterable<LiblouisTranslator>>() {
							public Iterable<LiblouisTranslator> _apply(LiblouisTranslator t) {
								URI[] table = t.asLiblouisTable().asURIs();
								LiblouisTable tableWithUndefinedDots; {
									URI[] uris = new URI[table.length + 1];
									System.arraycopy(table, 0, uris, 0, uris.length - 1);
									// adding the "undefined" rule to the end overwrites any previous rules
									uris[uris.length - 1] = URIs.asURI(undefinedTable);
									tableWithUndefinedDots = new LiblouisTable(uris);
								}
								MutableQuery newQuery = mutableQuery().add("table", tableWithUndefinedDots.toString());
								if (locale != null)
									newQuery.add("locale", locale);
								return logSelect(newQuery, backingProvider);
							}
						}
					)
				);
			}
		}
		
		private static class ConcatLineIterators implements BrailleTranslator.LineIterator {
			
			final List<BrailleTranslator.LineIterator> iterators;
			BrailleTranslator.LineIterator current;
			int currentIndex = 0;
			
			ConcatLineIterators(List<BrailleTranslator.LineIterator> iterators) {
				this.iterators = iterators;
				currentIndex = -1;
				current = null;
				computeCurrent();
			}
			
			void computeCurrent() {
				while (current == null || !current.hasNext())
					if (currentIndex + 1 < iterators.size())
						current = iterators.get(++currentIndex);
					else {
						current = null;
						break; }
			}
			
			public String nextTranslatedRow(int limit, boolean force, boolean wholeWordsOnly) {
				String row = "";
				while (limit > row.length()) {
					if (current == null) break;
					row += current.nextTranslatedRow(limit - row.length(), force, wholeWordsOnly);
					computeCurrent(); }
				return row;
			}
			
			public String getTranslatedRemainder() {
				String remainder = "";
				if (current == null) return remainder;
				for (int i = currentIndex; i < iterators.size(); i++)
					if (iterators.get(i) != null)
						remainder += iterators.get(i).getTranslatedRemainder();
				return remainder;
			}
			
			public int countRemaining() {
				int remaining = 0;
				if (current == null) return remaining;
				for (int i = currentIndex; i < iterators.size(); i++)
					if (iterators.get(i) != null)
						remaining += iterators.get(i).countRemaining();
				return remaining;
			}
			
			public boolean hasNext() {
				computeCurrent();
				return current != null;
			}
			
			public ConcatLineIterators copy() {
				List<BrailleTranslator.LineIterator> iteratorsCopy = new ArrayList<>(iterators.size() - currentIndex);
				for (int i = currentIndex; i < iterators.size(); i++)
					if (iterators.get(i) != null)
						iteratorsCopy.add((BrailleTranslator.LineIterator)iterators.get(i).copy());
				return new ConcatLineIterators(iteratorsCopy);
			}
			
			public boolean supportsMetric(String metric) {
				return false;
			}
			
			public double getMetric(String metric) {
				throw new UnsupportedMetricException("Metric not supported: " + metric);
			}
		}
	}
}
