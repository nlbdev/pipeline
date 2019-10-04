package no.nlb.pipeline.braille.impl;

import java.text.Normalizer;
import java.util.function.Supplier;
import java.util.Iterator;
import java.util.NoSuchElementException;
import javax.xml.stream.XMLStreamException;
import javax.xml.stream.XMLStreamReader;
import static javax.xml.stream.XMLStreamConstants.CHARACTERS;
import static javax.xml.stream.XMLStreamConstants.START_ELEMENT;
import static javax.xml.stream.XMLStreamConstants.END_DOCUMENT;

import com.google.common.collect.Iterators;

import com.xmlcalabash.core.XProcException;
import com.xmlcalabash.core.XProcRuntime;
import com.xmlcalabash.core.XProcStep;
import com.xmlcalabash.io.ReadablePipe;
import com.xmlcalabash.io.WritablePipe;
import com.xmlcalabash.library.DefaultStep;
import com.xmlcalabash.runtime.XAtomicStep;

import net.sf.saxon.s9api.SaxonApiException;

import org.daisy.common.calabash.XMLCalabashHelper;
import static org.daisy.common.stax.XMLStreamWriterHelper.writeAttributes;
import static org.daisy.common.stax.XMLStreamWriterHelper.writeEvent;
import org.daisy.common.stax.BaseURIAwareXMLStreamReader;
import org.daisy.common.stax.BaseURIAwareXMLStreamWriter;
import org.daisy.common.transform.TransformerException;
import org.daisy.common.transform.XMLStreamToXMLStreamTransformer;
import org.daisy.common.xproc.calabash.XProcStepProvider;

import org.osgi.service.component.annotations.Component;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class NFCStep extends DefaultStep {
	
	private NFCStep(XProcRuntime runtime, XAtomicStep step) {
		super(runtime, step);
	}
	
	private ReadablePipe sourcePipe = null;
	private WritablePipe resultPipe = null;
	
	@Override
	public void setInput(String port, ReadablePipe pipe) {
		sourcePipe = pipe;
	}
	
	@Override
	public void setOutput(String port, WritablePipe pipe) {
		resultPipe = pipe;
	}
	
	@Override
	public void reset() {
		sourcePipe.resetReader();
		resultPipe.resetWriter();
	}
	
	@Override
	public void run() throws SaxonApiException {
		super.run();
		try {
			XMLCalabashHelper.transform(
				new NFCTransform(),
				sourcePipe,
				resultPipe,
				runtime); }
		catch (Exception e) {
			logger.error("px:nfc failed", e);
			throw new XProcException(step.getNode(), e); }
	}
	
	private static class NFCTransform implements XMLStreamToXMLStreamTransformer {
		
		public void transform(Iterator<BaseURIAwareXMLStreamReader> input, Supplier<BaseURIAwareXMLStreamWriter> output)
				throws TransformerException {
			BaseURIAwareXMLStreamReader reader = Iterators.getOnlyElement(input);
			BaseURIAwareXMLStreamWriter writer = output.get();
			try {
				writer.setBaseURI(reader.getBaseURI());
				writer.writeStartDocument(); // why is this needed?
			  loop: while (true)
					try {
						int event = reader.next();
						switch (event) {
						case START_ELEMENT:
							writeEvent(writer, event, reader);
							writeAttributes(writer, reader);
							break;
						case CHARACTERS:
							writer.writeCharacters(Normalizer.normalize(reader.getText(), Normalizer.Form.NFC));
							break;
						case END_DOCUMENT:
							writeEvent(writer, event, reader);
							break loop;
						default:
							writeEvent(writer, event, reader);
						}
					} catch (NoSuchElementException e) {
						break;
					}
			} catch (XMLStreamException e) {
				throw new TransformerException(e);
			}
		}
	}

	@Component(
		name = "px:nfc",
		service = { XProcStepProvider.class },
		property = { "type:String={http://www.daisy.org/ns/pipeline/xproc}nfc" }
	)
	public static class Provider implements XProcStepProvider {
		
		@Override
		public XProcStep newStep(XProcRuntime runtime, XAtomicStep step) {
			return new NFCStep(runtime, step);
		}
	}
	
	private static final Logger logger = LoggerFactory.getLogger(NFCStep.class);
	
}
