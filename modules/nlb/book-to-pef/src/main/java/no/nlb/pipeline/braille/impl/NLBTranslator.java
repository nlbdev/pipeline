package no.nlb.pipeline.braille.impl;

import java.net.URI;
import java.util.ArrayList;
import java.util.Arrays;
import static java.util.Arrays.copyOfRange;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.NoSuchElementException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import com.google.common.base.Objects;
import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableMap;
import static com.google.common.collect.Iterables.size;

import cz.vutbr.web.css.CSSProperty;
import cz.vutbr.web.css.Term;
import cz.vutbr.web.css.TermIdent;
import cz.vutbr.web.css.TermList;

import org.daisy.braille.css.BrailleCSSProperty.TextTransform;
import org.daisy.braille.css.SimpleInlineStyle;

import org.daisy.dotify.api.translator.UnsupportedMetricException;

import org.daisy.pipeline.braille.common.AbstractBrailleTranslator;
import org.daisy.pipeline.braille.common.AbstractTransformProvider;
import org.daisy.pipeline.braille.common.AbstractTransformProvider.util.Function;
import org.daisy.pipeline.braille.common.AbstractTransformProvider.util.Iterables;
import static org.daisy.pipeline.braille.common.AbstractTransformProvider.util.Iterables.concat;
import static org.daisy.pipeline.braille.common.AbstractTransformProvider.util.Iterables.transform;
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
import org.daisy.pipeline.braille.common.TransformationException;
import org.daisy.pipeline.braille.common.TransformProvider;
import static org.daisy.pipeline.braille.common.TransformProvider.util.dispatch;
import static org.daisy.pipeline.braille.common.TransformProvider.util.memoize;
import static org.daisy.pipeline.braille.common.util.Locales.parseLocale;
import static org.daisy.pipeline.braille.common.util.Strings.splitInclDelimiter;
import static org.daisy.pipeline.braille.common.util.URIs.asURI;
import org.daisy.pipeline.braille.liblouis.LiblouisTranslator;

import org.osgi.service.component.annotations.Activate;
import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.component.annotations.ReferenceCardinality;
import org.osgi.service.component.annotations.ReferencePolicy;
import org.osgi.service.component.ComponentContext;

public interface NLBTranslator {
	
	@Component(
		name = "no.nlb.pipeline.braille.impl.NLBTranslator.Provider",
		service = {
			BrailleTranslatorProvider.class,
			TransformProvider.class
		}
	)
	public class Provider extends AbstractTransformProvider<BrailleTranslator> implements BrailleTranslatorProvider<BrailleTranslator> {
		
		private URI href;
		
		@Activate
		private void activate(ComponentContext context, final Map<?,?> properties) {
			href = asURI(context.getBundleContext().getBundle().getEntry("xml/block-translate.xpl"));
		}
		
		private final static Query grade0Table = mutableQuery().add("liblouis-table", "http://www.liblouis.org/tables/no-no-g0.utb");
		private final static Query grade1Table = mutableQuery().add("liblouis-table", "http://www.liblouis.org/tables/no-no-g1.ctb");
		private final static Query grade2Table = mutableQuery().add("liblouis-table", "http://www.liblouis.org/tables/no-no-g2.ctb");
		private final static Query grade3Table = mutableQuery().add("liblouis-table", "http://www.liblouis.org/tables/no-no-g3.ctb");
		private final static Query grade0Table8dot = mutableQuery().add("liblouis-table", "http://www.liblouis.org/tables/no-no-g0.utb");
		private final static Query hyphenationTable = mutableQuery().add("libhyphen-table", "http://www.nlb.no/hyphen/hyph_nb_NO.dic");
		private final static Query fallbackHyphenationTable1 = mutableQuery().add("libhyphen-table",
		                                                                          "http://www.libreoffice.org/dictionaries/hyphen/hyph_nb_NO.dic");
		private final static Query fallbackHyphenationTable2 = mutableQuery().add("hyphenator", "tex").add("locale", "nb");
		
		private final static Iterable<BrailleTranslator> empty = Iterables.<BrailleTranslator>empty();
		
		private final static List<String> supportedInput = ImmutableList.of("css","text-css");
		private final static List<String> supportedOutput = ImmutableList.of("css","braille");
		private final static List<String> supportedInputOutput = ImmutableList.of("dtbook","html");
		
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
				if ("nlb".equals(q.removeOnly("translator").getValue().get()))
					if (q.containsKey("grade")) {
						String v = q.removeOnly("grade").getValue().get();
						final int grade;
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
						final int dots;
						if (q.containsKey("dots") && q.removeOnly("dots").getValue().get().equals("8"))
							dots = 8;
						else
							dots = 6;
						if (q.isEmpty()) {
							Iterable<Hyphenator> hyphenators = concat(
								logSelect(hyphenationTable, hyphenatorProvider),
								concat(
									logSelect(fallbackHyphenationTable1, hyphenatorProvider),
									logSelect(fallbackHyphenationTable2, hyphenatorProvider)));
							final Query liblouisTable;
							if (dots == 8)
								liblouisTable = grade0Table8dot;
							else
								liblouisTable = grade == 3 ? grade3Table : grade == 2 ? grade2Table : grade == 1 ? grade1Table : grade0Table;
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
									new Function<String,Iterable<BrailleTranslator>>() {
										public Iterable<BrailleTranslator> _apply(final String hyphenator) {
											return concat(
												transform(
													logSelect(mutableQuery(liblouisTable)
													              .add("hyphenator", hyphenator)
													              .add("handle-non-standard-hyphenation", "defer"),
													          liblouisTranslatorProvider),
													new Function<LiblouisTranslator,Iterable<BrailleTranslator>>() {
														public Iterable<BrailleTranslator> _apply(final LiblouisTranslator translator) {
															return Iterables.transform(
																logSelect(mutableQuery(grade0Table)
																              .add("hyphenator", hyphenator)
																              .add("handle-non-standard-hyphenation", "defer"),
																          liblouisTranslatorProvider),
																new Function<LiblouisTranslator,BrailleTranslator>() {
																	public BrailleTranslator _apply(LiblouisTranslator grade0Translator) {
																		return __apply(
																			logCreate(
																				new TransformImpl(grade, dots, translator, grade0Translator,
																				                  // FIXME: other languages provider does not need to be liblouis
																				                  liblouisTranslatorProvider,
																				                  htmlOrDtbookOut))); }} ); }} )); }} )); }}
			return empty;
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
		
		private class TransformImpl extends AbstractBrailleTranslator {
			
			private final XProc xproc;
			private final LiblouisTranslator translator;
			private final LiblouisTranslator grade0Translator;
			private final TransformProvider<? extends BrailleTranslator> otherLanguageTranslators;
			private final int grade;
			private final int dots;
			
			private TransformImpl(int grade, int dots, LiblouisTranslator translator, LiblouisTranslator grade0Translator,
			                      TransformProvider<? extends BrailleTranslator> otherLanguageTranslators,
								  boolean htmlOrDtbookOut) {
				Map<String,String> options = ImmutableMap.<String,String>of(
					"text-transform", mutableQuery().add("id", this.getIdentifier()).toString(),
					// This will omit the <_ style="text-transform:none">
					// wrapper. It is assumed that if (output:html) or
					// (output:dtbook) is set, the result is known to be
					// braille (which is the case if (output:braille) is also
					// set).
					"no-wrap", String.valueOf(htmlOrDtbookOut));
				xproc = new XProc(href, null, options);
				this.translator = translator;
				this.grade0Translator = grade0Translator;
				this.otherLanguageTranslators = otherLanguageTranslators;
				this.grade = grade;
				this.dots = dots;
			}
			
			@Override
			public XProc asXProc() {
				return xproc;
			}
			
			@Override
			public FromStyledTextToBraille fromStyledTextToBraille() {
				return fromStyledTextToBraille;
			}
			
			private final FromStyledTextToBraille fromStyledTextToBraille = new FromStyledTextToBraille() {
				
				public java.lang.Iterable<String> transform(java.lang.Iterable<CSSStyledText> styledText) {
					List<String> transformed = new ArrayList<String>();
					List<CSSStyledText> buffer = new ArrayList<CSSStyledText>();
					String curLang = null;
					for (CSSStyledText st : styledText) {
						Map<String,String> attrs = st.getTextAttributes();
						String lang = null;
						if (attrs != null)
							lang = attrs.remove("lang");
						if (!(lang == null && curLang == null || lang == curLang)) {
							if (!buffer.isEmpty()) {
								for (String s : transform(buffer, curLang))
									transformed.add(s);
								buffer.clear(); }}
						curLang = lang;
						buffer.add(st); }
					if (!buffer.isEmpty())
						for (String s : transform(buffer, curLang))
							transformed.add(s);
					return transformed;
				}
				
				private java.lang.Iterable<String> transform(List<CSSStyledText> styledText, String lang) {
					if (lang == null)
						return transformNorwegian(styledText);
					else
						return transform(styledText, lang, null);
				}
				
				private java.lang.Iterable<String> transformNorwegian(List<CSSStyledText> styledText) {
					List<CSSStyledText> segments = new ArrayList<CSSStyledText>();
					// which segments are an url or e-mail address
					List<Boolean> computer = new ArrayList<Boolean>();
					// mapping from index in segments to index in text
					List<Integer> mapping = new ArrayList<Integer>(); {
						int i = 0;
						for (CSSStyledText st : styledText) {
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
							i++; }}
					String braille[] = new String[size(styledText)];
					for (int i = 0; i < braille.length; i++)
						braille[i] = "";
					int i = 0;
					boolean curComputer = false;
					for (String b : transform(segments, null, computer)) {
						if (!computer.get(i) && curComputer)
							braille[mapping.get(i)] += CLOSE_COMPUTER;
						else if (computer.get(i) && !curComputer)
							braille[mapping.get(i)] += OPEN_COMPUTER;
						braille[mapping.get(i)] += b;
						curComputer = computer.get(i);
						i++; }
					if (curComputer)
						braille[mapping.get(i-1)] += CLOSE_COMPUTER;
					return Arrays.asList(braille);
				}
				
				private java.lang.Iterable<String> transform(List<CSSStyledText> styledText, String lang, List<Boolean> computer) {
					List<String> transformed = new ArrayList<String>();
					List<CSSStyledText> buffer = new ArrayList<CSSStyledText>();
					boolean curUncontracted = false;
					int i = 0;
					for (CSSStyledText st : styledText) {
						SimpleInlineStyle style = st.getStyle();
						boolean uncontracted; {
							uncontracted = computer == null ? false : computer.get(i);
							if (style != null) {
								CSSProperty val = style.getProperty("text-transform");
								if (val != null) {
									if (val == TextTransform.list_values) {
										TermList values = style.getValue(TermList.class, "text-transform");
										Iterator<Term<?>> it = values.iterator();
										while (it.hasNext()) {
											String tt = ((TermIdent)it.next()).getValue();
											if (tt.equals("uncontracted")) {
												uncontracted = true;
												it.remove();
												break; }}
										if (values.isEmpty())
											style.removeProperty("text-transform"); }}}}
						if (uncontracted != curUncontracted && !buffer.isEmpty()) {
							for (String s : transformWithContractionGrade(buffer, lang, curUncontracted))
								transformed.add(s);
							buffer = new ArrayList<CSSStyledText>(); }
						curUncontracted = uncontracted;
						buffer.add(st);
						i++; }
					if (!buffer.isEmpty())
						for (String s : transformWithContractionGrade(buffer, lang, curUncontracted))
							transformed.add(s);
					return transformed;
				}
			};
			
			private java.lang.Iterable<String> transformWithContractionGrade(List<CSSStyledText> styledText, String lang, boolean uncontracted) {
				FromStyledTextToBraille t; {
					if (lang == null) {
						if (!uncontracted)
							t = translator.fromStyledTextToBraille();
						else
							t = grade0Translator.fromStyledTextToBraille(); }
					else {
						MutableQuery q = mutableQuery().add("locale", lang).add("contraction", uncontracted ? "no" : "full");
						try {
							t = otherLanguageTranslators.get(q).iterator().next().fromStyledTextToBraille(); }
						catch (NoSuchElementException e) {
							throw new TransformationException("Could not find a sub-translator for language " + lang
							                                  + " (" + (uncontracted ? "un" : "") + "contracted)"); }}}
				return t.transform(styledText);
			}
			
			@Override
			public LineBreakingFromStyledText lineBreakingFromStyledText() {
				return lineBreakingFromStyledText;
			}
			
			private final LineBreakingFromStyledText lineBreakingFromStyledText = new LineBreakingFromStyledText() {
				
				public LineIterator transform(java.lang.Iterable<CSSStyledText> styledText) {
					List<LineIterator> lineIterators = new ArrayList<LineIterator>();
					List<CSSStyledText> buffer = new ArrayList<CSSStyledText>();
					String curLang = null;
					for (CSSStyledText st : styledText) {
						Map<String,String> attrs = st.getTextAttributes();
						String lang = null;
						if (attrs != null)
							lang = attrs.remove("lang");
						if (!(lang == null && curLang == null || lang == curLang)) {
							if (!buffer.isEmpty()) {
								lineIterators.add(transform(buffer, curLang));
								buffer.clear(); }}
						curLang = lang;
						buffer.add(st); }
					if (!buffer.isEmpty()) {
						lineIterators.add(transform(buffer, curLang)); }
					return concatLineIterators(lineIterators);
				}
				
				private LineIterator transform(List<CSSStyledText> styledText, String lang) {
					if (lang == null)
						return transformNorwegian(styledText);
					else
						return transform(styledText, lang, false);
				}
				
				private LineIterator transformNorwegian(List<CSSStyledText> styledText) {
					List<LineIterator> lineIterators = new ArrayList<LineIterator>();
					List<CSSStyledText> buffer = new ArrayList<CSSStyledText>();
					boolean curComputer = false;
					for (CSSStyledText st : styledText) {
						String text = st.getText();
						if (!text.isEmpty()) {
							boolean computer = false;
							boolean needStyleCopy = false;
							for (String s : splitInclDelimiter(text, COMPUTER)) {
								if (!s.isEmpty()) {
									if (computer != curComputer && !buffer.isEmpty()) {
										if (curComputer)
											lineIterators.add(new NonBreakingBrailleString(OPEN_COMPUTER));
										lineIterators.add(transform(buffer, null, curComputer));
										if (curComputer)
											lineIterators.add(new NonBreakingBrailleString(CLOSE_COMPUTER));
										buffer = new ArrayList<CSSStyledText>();
										curComputer = computer; }
									SimpleInlineStyle style = st.getStyle();
									Map<String,String> attrs = st.getTextAttributes();
									if (needStyleCopy) {
										if (style != null)
											style = (SimpleInlineStyle)style.clone();
										if (attrs != null)
											attrs = new HashMap<String,String>(attrs); }
									buffer.add(new CSSStyledText(s, style, attrs));
									needStyleCopy = true; }
								computer = !computer; }}}
					if (!buffer.isEmpty()) {
						if (curComputer)
							lineIterators.add(new NonBreakingBrailleString(OPEN_COMPUTER));
						lineIterators.add(transform(buffer, null, curComputer));
						if (curComputer)
							lineIterators.add(new NonBreakingBrailleString(CLOSE_COMPUTER)); }
					return concatLineIterators(lineIterators);
				}
				
				private LineIterator transform(List<CSSStyledText> styledText, String lang, boolean computer) {
					List<LineIterator> lineIterators = new ArrayList<LineIterator>();
					List<CSSStyledText> buffer = new ArrayList<CSSStyledText>();
					boolean curUncontracted = false;
					for (CSSStyledText st : styledText) {
						SimpleInlineStyle style = st.getStyle();
						boolean uncontracted; {
							uncontracted = computer;
							if (style != null) {
								CSSProperty val = style.getProperty("text-transform");
								if (val != null) {
									if (val == TextTransform.list_values) {
										TermList values = style.getValue(TermList.class, "text-transform");
										Iterator<Term<?>> it = values.iterator();
										while (it.hasNext()) {
											String tt = ((TermIdent)it.next()).getValue();
											if (tt.equals("uncontracted")) {
												uncontracted = true;
												it.remove();
												break; }}
										if (values.isEmpty())
											style.removeProperty("text-transform"); }}}}
						if (uncontracted != curUncontracted && !buffer.isEmpty()) {
							lineIterators.add(transformWithContractionGrade(buffer, lang, curUncontracted));
							buffer = new ArrayList<CSSStyledText>(); }
						curUncontracted = uncontracted;
						buffer.add(st); }
					if (!buffer.isEmpty())
						lineIterators.add(transformWithContractionGrade(buffer, lang, curUncontracted));
					return concatLineIterators(lineIterators);
				}
				
				private LineIterator transformWithContractionGrade(List<CSSStyledText> styledText, String lang, boolean uncontracted) {
					LineBreakingFromStyledText t; {
						if (lang == null) {
							if (!uncontracted)
								t = translator.lineBreakingFromStyledText();
							else
								t = grade0Translator.lineBreakingFromStyledText(); }
						else {
							MutableQuery q = mutableQuery().add("locale", lang).add("contraction", uncontracted ? "no" : "full");
							try {
								t = otherLanguageTranslators.get(q).iterator().next().lineBreakingFromStyledText(); }
							catch (NoSuchElementException e) {
								throw new TransformationException("Could not find a sub-translator for language " + lang
								                                  + " (" + (uncontracted ? "un" : "") + "contracted)"); }}}
					return t.transform(styledText);
				}
			};
			
			@Override
			public String toString() {
				return Objects.toStringHelper(NLBTranslator.class.getSimpleName())
					.add("grade", grade)
					.add("dots", dots)
					.toString();
			}
		}
		
		private static class NonBreakingBrailleString implements BrailleTranslator.LineIterator {
			
			private String remainder;
			
			private NonBreakingBrailleString(String string) {
				remainder = string;
			}
			
			public String nextTranslatedRow(int limit, boolean force) {
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
				return remainder.length();
			}
			
			public boolean hasNext() {
				return (remainder != null);
			}
			
			public boolean supportsMetric(String metric) {
				return false;
			}
			
			public double getMetric(String metric) {
				throw new UnsupportedMetricException("Metric not supported: " + metric);
			}
		}
		
		private static BrailleTranslator.LineIterator concatLineIterators(final List<BrailleTranslator.LineIterator> iterators) {
			if (iterators.size() == 0)
				return new NonBreakingBrailleString(null);
			else if (iterators.size() == 1)
				return iterators.get(0);
			else
				return new BrailleTranslator.LineIterator() {
					
					private BrailleTranslator.LineIterator current = iterators.get(0);
					private int currentIndex = 0;
					
					public String nextTranslatedRow(int limit, boolean force) {
						String row = "";
						while (limit > row.length()) {
							row += current.nextTranslatedRow(limit - row.length(), force);
							if (!current.hasNext() && currentIndex + 1 < iterators.size())
								current = iterators.get(++currentIndex);
							else
								break; }
						return row;
					}
					
					public String getTranslatedRemainder() {
						String remainder = "";
						for (int i = currentIndex; i < iterators.size(); i++)
							remainder += iterators.get(i).getTranslatedRemainder();
						return remainder;
					}
					
					public int countRemaining() {
						int remaining = 0;
						for (int i = currentIndex; i < iterators.size(); i++)
							remaining += iterators.get(i).countRemaining();
						return remaining;
					}
					
					public boolean hasNext() {
						if (current.hasNext())
							return true;
					else {
						while (currentIndex + 1 < iterators.size()) {
							current = iterators.get(++currentIndex);
							if (current.hasNext())
								return true; }}
						return false;
					}
					
					public boolean supportsMetric(String metric) {
						return false;
					}
					
					public double getMetric(String metric) {
						throw new UnsupportedMetricException("Metric not supported: " + metric);
					}
				};
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
	
		private List<TransformProvider<LiblouisTranslator>> liblouisTranslatorProviders
		= new ArrayList<TransformProvider<LiblouisTranslator>>();
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
		
	}
}
