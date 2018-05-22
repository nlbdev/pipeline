package no.nlb.pipeline.braille.impl;

import java.text.Normalizer;
import java.util.NoSuchElementException;
import javax.xml.stream.XMLStreamException;
import javax.xml.stream.XMLStreamReader;
import static javax.xml.stream.XMLStreamConstants.CHARACTERS;
import static javax.xml.stream.XMLStreamConstants.START_ELEMENT;

import com.xmlcalabash.core.XProcException;
import com.xmlcalabash.core.XProcRuntime;
import com.xmlcalabash.core.XProcStep;
import com.xmlcalabash.io.ReadablePipe;
import com.xmlcalabash.io.WritablePipe;
import com.xmlcalabash.library.DefaultStep;
import com.xmlcalabash.runtime.XAtomicStep;

import net.sf.saxon.Configuration;
import net.sf.saxon.s9api.SaxonApiException;

import org.daisy.common.xproc.calabash.XProcStepProvider;
import org.daisy.pipeline.braille.common.saxon.StreamToStreamTransform;
import org.daisy.pipeline.braille.common.TransformationException;

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
			resultPipe.write(
				new NFCTransform(runtime.getConfiguration().getProcessor().getUnderlyingConfiguration())
				.transform(sourcePipe.read().getUnderlyingNode()));
		} catch (Exception e) {
			logger.error("px:nfc failed", e);
			throw new XProcException(step.getNode(), e);
		}
	}
	
	private static class NFCTransform extends StreamToStreamTransform {
		
		public NFCTransform(Configuration configuration) {
			super(configuration);
		}
		
		protected void _transform(XMLStreamReader reader, BufferedWriter writer) throws TransformationException {
			try {
				writer.writeStartDocument(); // why is this needed?
				while (true)
					try {
						int event = reader.next();
						switch (event) {
						case START_ELEMENT:
							writer.copyStartElement(reader);
							writer.copyAttributes(reader);
							break;
						case CHARACTERS:
							writer.writeCharacters(Normalizer.normalize(reader.getText(), Normalizer.Form.NFC));
							break;
						default:
							writer.copyEvent(event, reader);
						}
					} catch (NoSuchElementException e) {
						break;
					}
			} catch (XMLStreamException e) {
				throw new TransformationException(e);
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
