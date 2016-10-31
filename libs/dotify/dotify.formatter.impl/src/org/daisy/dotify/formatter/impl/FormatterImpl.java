package org.daisy.dotify.formatter.impl;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Stack;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.daisy.dotify.api.formatter.ContentCollection;
import org.daisy.dotify.api.formatter.Formatter;
import org.daisy.dotify.api.formatter.FormatterConfiguration;
import org.daisy.dotify.api.formatter.FormatterSequence;
import org.daisy.dotify.api.formatter.LayoutMasterBuilder;
import org.daisy.dotify.api.formatter.LayoutMasterProperties;
import org.daisy.dotify.api.formatter.SequenceProperties;
import org.daisy.dotify.api.formatter.TableOfContents;
import org.daisy.dotify.api.formatter.VolumeTemplateBuilder;
import org.daisy.dotify.api.formatter.VolumeTemplateProperties;
import org.daisy.dotify.api.translator.BrailleTranslatorFactoryMakerService;
import org.daisy.dotify.api.translator.MarkerProcessorFactoryMakerService;
import org.daisy.dotify.api.translator.TextBorderFactoryMakerService;
import org.daisy.dotify.api.writer.PagedMediaWriter;
import org.daisy.dotify.common.io.StateObject;
import org.daisy.dotify.formatter.impl.DefaultContext.Space;


/**
 * Breaks flow into rows, page related block properties are left to next step
 * @author Joel Håkansson
 */
public class FormatterImpl implements Formatter {
	private static final int DEFAULT_SPLITTER_MAX = 50;
	
	private final HashMap<String, TableOfContentsImpl> tocs;
	private final Stack<VolumeTemplate> volumeTemplates;
	private final Logger logger;
	
	private final StateObject state;
	private final Stack<BlockSequence> blocks;
	
	//CrossReferenceHandler
	private final Map<Integer, VolumeImpl> volumes;
	private boolean isDirty;
	private CrossReferenceHandler crh;
	private LazyFormatterContext context;

	/**
	 * Creates a new formatter
	 */
	public FormatterImpl(BrailleTranslatorFactoryMakerService translatorFactory, TextBorderFactoryMakerService tbf, MarkerProcessorFactoryMakerService mpf, String locale, String mode) {
		this.context = new LazyFormatterContext(translatorFactory, tbf, mpf, FormatterConfiguration.with(locale, mode).build());
		this.blocks = new Stack<>();
		this.state = new StateObject();
		this.tocs = new HashMap<>();
		this.volumeTemplates = new Stack<>();
		
		this.logger = Logger.getLogger(this.getClass().getCanonicalName());
		
		//CrossReferenceHandler
		this.volumes = new HashMap<>();
		this.isDirty = false;
		this.crh = new CrossReferenceHandler();
	}
	

	@Override
	public FormatterConfiguration getConfiguration() {
		return context.getFormatterContext().getConfiguration();
	}

	@Override
	public void setConfiguration(FormatterConfiguration config) {
		//TODO: we require unopened at the moment due to limitations in the implementation
		state.assertUnopened();
		context.setConfiguration(config);
	}
	
	@Override
	public FormatterSequence newSequence(SequenceProperties p) {
		state.assertOpen();
		BlockSequence currentSequence = new BlockSequence(context.getFormatterContext(), p, context.getFormatterContext().getMasters().get(p.getMasterName()));
		blocks.push(currentSequence);
		return currentSequence;
	}

	@Override
	public LayoutMasterBuilder newLayoutMaster(String name,
			LayoutMasterProperties properties) {
		return context.getFormatterContext().newLayoutMaster(name, properties);
	}

	@Override
	public void open() {
		state.assertUnopened();
		state.open();
	}
	
	@Override
	public void close() throws IOException {
		if (state.isClosed()) {
			return;
		}
		state.assertOpen();
		state.close();
	}

	@Override
	public VolumeTemplateBuilder newVolumeTemplate(VolumeTemplateProperties props) {
		VolumeTemplate template = new VolumeTemplate(context.getFormatterContext(), tocs, props.getCondition(), props.getSplitterMax());
		volumeTemplates.push(template);
		return template;
	}

	@Override
	public TableOfContents newToc(String tocName) {
		TableOfContentsImpl toc = new TableOfContentsImpl(context.getFormatterContext());
		tocs.put(tocName, toc);
		return toc;
	}

	@Override
	public ContentCollection newCollection(String collectionId) {
		return context.getFormatterContext().newContentCollection(collectionId);
	}
	
	@Override
	public void write(PagedMediaWriter writer) {
		try (WriterHandler wh = new WriterHandler(writer)) {
			wh.write(getVolumes());
		} catch (IOException e) {
			logger.log(Level.WARNING, "Failed to close resource.", e);
		}
	}

	private Iterable<? extends Volume> getVolumes() {
		VolumeProvider volumeProvider = new VolumeProvider(blocks, new VolumeSplitterLimit(), context.getFormatterContext(), crh);

		ArrayList<VolumeImpl> ret;
		ArrayList<AnchorData> ad;

		for (int j=1;j<=10;j++) {
			ret = new ArrayList<>();
			volumeProvider.prepare();
			for (int i=1;i<= crh.getVolumeCount();i++) {
				VolumeImpl volume = getVolume(i);
				ad = new ArrayList<>();
				volume.setPreVolData(updateVolumeContents(i, ad, true));
				volume.setBody(volumeProvider.nextVolume(volume.getOverhead(), ad));
				
				if (logger.isLoggable(Level.FINE)) {
					logger.fine("Sheets  in volume " + i + ": " + (volume.getVolumeSize()) + 
							", content:" + volume.getBodySize() +
							", overhead:" + volume.getOverhead());
				}
				volume.setPostVolData(updateVolumeContents(i, ad, false));
				crh.setSheetsInVolume(i, volume.getBodySize() + volume.getOverhead());
				//crh.setPagesInVolume(i, value);
				crh.setAnchorData(i, ad);
				ret.add(volume);
			}

			volumeProvider.update();
			crh.setVolumeCount(volumeProvider.getVolumeCount());
			crh.setSheetsInDocument(volumeProvider.countTotalSheets());
			//crh.setPagesInDocument(value);
			if (volumeProvider.hasNext()) {
				if (logger.isLoggable(Level.FINE)) {
					logger.fine("There is more content (sheets: " + volumeProvider.countRemainingSheets() + ", pages: " + volumeProvider.countRemainingPages() + ")");
				}
				if (!isDirty() && j>1) {
					volumeProvider.adjustVolumeCount();
				}
			}
			if (!isDirty() && !volumeProvider.hasNext()) {
				//everything fits
				return ret;
			} else {
				setDirty(false);
				logger.info("Things didn't add up, running another iteration (" + j + ")");
			}
		}
		throw new RuntimeException("Failed to complete volume division.");
	}

	private List<Sheet> updateVolumeContents(int volumeNumber, ArrayList<AnchorData> ad, boolean pre) {
		DefaultContext c = new DefaultContext.Builder()
						.currentVolume(volumeNumber)
						.referenceHandler(crh)
						.space(pre?Space.PRE_CONTENT:Space.POST_CONTENT)
						.build();
		try {
			ArrayList<BlockSequence> ib = new ArrayList<>();
			for (VolumeTemplate t : volumeTemplates) {
				if (t.appliesTo(c)) {
					for (VolumeSequence seq : (pre?t.getPreVolumeContent():t.getPostVolumeContent())) {
						BlockSequence s = seq.getBlockSequence(context.getFormatterContext(), c, crh);
						if (s!=null) {
							ib.add(s);
						}
					}
					break;
				}
			}
			List<Sheet> ret = new PageStructBuilder(context.getFormatterContext(), ib, crh).paginate(c);
			for (Sheet ps : ret) {
				for (PageImpl p : ps.getPages()) {
					if (p.getAnchors().size()>0) {
						ad.add(new AnchorData(p.getPageIndex(), p.getAnchors()));
					}
				}
			}
			return ret;
		} catch (PaginatorException e) {
			return null;
		}
	}
	
	
	private class VolumeSplitterLimit implements SplitterLimit {
		/**
		 * Gets the volume max size based on the supplied information.
		 * 
		 * @param volumeNumber the volume number, one based
		 * @param volumeCount the number of volumes
		 * @return returns the maximum number of sheets in the volume
		 */
		public int getSplitterLimit(int volumeNumber) {
			for (VolumeTemplate t : volumeTemplates) {
				if (t==null) {
					logger.warning("A volume template is null.");
					continue;
				}
				if (t.appliesTo(new DefaultContext.Builder()
							.currentVolume(volumeNumber)
							.referenceHandler(crh)
							.build())) {
					return t.getVolumeMaxSize();
				}
			}
			logger.fine("Found no applicable volume template.");
			return DEFAULT_SPLITTER_MAX;
		}
	}
	
	private VolumeImpl getVolume(int volumeNumber) {
		if (volumeNumber<1) {
			throw new IndexOutOfBoundsException("Volume must be greater than or equal to 1");
		}
		if (volumes.get(volumeNumber)==null) {
			volumes.put(volumeNumber, new VolumeImpl());
			setDirty(true);
		}
		return volumes.get(volumeNumber);
	}
	
	private boolean isDirty() {
		return isDirty || crh.isDirty();
	}

	private void setDirty(boolean isDirty) {
		this.isDirty = isDirty;
		crh.setDirty(isDirty);
	}

}
