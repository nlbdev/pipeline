package org.daisy.pipeline.braille.css.calabash.impl;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.NoSuchElementException;
import java.util.Stack;
import java.util.TreeMap;

import javax.xml.namespace.QName;
import static javax.xml.stream.XMLStreamConstants.END_ELEMENT;
import static javax.xml.stream.XMLStreamConstants.START_ELEMENT;
import javax.xml.stream.XMLStreamException;
import javax.xml.stream.XMLStreamReader;

import com.google.common.base.Splitter;

import com.xmlcalabash.core.XProcException;
import com.xmlcalabash.core.XProcStep;
import com.xmlcalabash.core.XProcRuntime;
import com.xmlcalabash.io.ReadablePipe;
import com.xmlcalabash.io.WritablePipe;
import com.xmlcalabash.library.DefaultStep;
import com.xmlcalabash.runtime.XAtomicStep;

import net.sf.saxon.Configuration;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.XdmNode;

import org.daisy.common.xproc.calabash.XProcStepProvider;
import org.daisy.pipeline.braille.common.saxon.StreamToStreamTransform;
import org.daisy.pipeline.braille.common.TransformationException;
import static org.daisy.pipeline.braille.common.util.Strings.join;

import org.osgi.service.component.annotations.Component;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class CssShiftIdStep extends DefaultStep {
	
	@Component(
		name = "pxi:css-shift-id",
		service = { XProcStepProvider.class },
		property = { "type:String={http://www.daisy.org/ns/pipeline/xproc/internal}css-shift-id" }
	)
	public static class Provider implements XProcStepProvider {
		
		@Override
		public XProcStep newStep(XProcRuntime runtime, XAtomicStep step) {
			return new CssShiftIdStep(runtime, step);
		}
	}
	
	private ReadablePipe sourcePipe = null;
	private WritablePipe resultPipe = null;
	
	private static final String XMLNS_CSS = "http://www.daisy.org/ns/pipeline/braille-css";
	private static final QName CSS_ID = new QName(XMLNS_CSS, "id");
	private static final QName CSS_BOX = new QName(XMLNS_CSS, "box");
	private static final QName CSS__ = new QName(XMLNS_CSS, "_");
	private static final QName _TYPE = new QName("type");
	private static final QName CSS_COUNTER = new QName(XMLNS_CSS, "counter");
	private static final QName _NAME = new QName("name");
	private static final QName _TARGET = new QName("target");
	private static final QName CSS_ANCHOR = new QName(XMLNS_CSS, "anchor");
	
	private CssShiftIdStep(XProcRuntime runtime, XAtomicStep step) {
		super(runtime, step);
	}
	
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
			XdmNode source = sourcePipe.read();
			// Two passes: one for shifting id, second for updating references.
			// Alternative is to combine the two and make use of FutureEvent for forward references.
			Map<String,String> idMap = new TreeMap<String,String>();
			XdmNode tmp = new ShiftIdTransform(runtime.getConfiguration().getProcessor().getUnderlyingConfiguration(), idMap)
				.transform(source.getUnderlyingNode());
			resultPipe.write(
				new UpdateRefsTransform(runtime.getConfiguration().getProcessor().getUnderlyingConfiguration(), idMap)
				.transform(tmp.getUnderlyingNode())); }
		catch (Exception e) {
			logger.error("pxi:shift-id failed", e);
			throw new XProcException(step.getNode(), e); }
	}
	
	private static class ShiftIdTransform extends StreamToStreamTransform {
		
		final Map<String,String> idMap;
		
		public ShiftIdTransform(Configuration configuration, Map<String,String> idMap) {
			super(configuration);
			this.idMap = idMap;
		}
		
		protected void _transform(XMLStreamReader reader, BufferedWriter writer) throws TransformationException {
			boolean insideInlineBox = false;
			Stack<Boolean> blockBoxes = new Stack<Boolean>();
			Stack<Boolean> inlineBoxes = new Stack<Boolean>();
			List<String> pendingId = new ArrayList<String>();
			ShiftedId shiftedId = null;
			try {
				writer.writeStartDocument(); // why is this needed?
				while (true)
					try {
						int event = reader.next();
						switch (event) {
						case START_ELEMENT: {
							writer.copyEvent(event, reader);
							boolean isInlineBox = false;
							boolean isBlockBox = false;
							if (insideInlineBox)
								writer.copyAttributes(reader);
							else {
								boolean isBox = CSS_BOX.equals(reader.getName());
								String id = null;
								for (int i = 0; i < reader.getAttributeCount(); i++) {
									QName name = reader.getAttributeName(i);
									String value = reader.getAttributeValue(i);
									if (CSS_ID.equals(name))
										id = value;
									else {
										if (isBox && _TYPE.equals(name))
											if ("inline".equalsIgnoreCase(value))
												isInlineBox = true;
											else if ("block".equalsIgnoreCase(value))
												isBlockBox = true;
										writer.writeAttribute(name, value); }}
								if (isBlockBox || isInlineBox)
									if (shiftedId != null) {
										shiftedId.render();
										shiftedId = null; }
								if (isInlineBox) {
									if (id != null)
										if (!pendingId.isEmpty())
											pendingId.add(id);
										else
											writer.writeAttribute(CSS_ID, id);
									if (!pendingId.isEmpty()) {
										id = pendingId.get(pendingId.size() - 1);
										for (String oldId : pendingId)
											if (!oldId.equals(id))
												idMap.put(oldId, id);
										pendingId.clear();
										if (id != null)
											writer.writeAttribute(CSS_ID, id); }}
								else if (id != null)
									pendingId.add(id);
								if (isInlineBox)
									insideInlineBox = true; }
							blockBoxes.push(isBlockBox);
							inlineBoxes.push(isInlineBox);
							break; }
						case END_ELEMENT: {
							boolean isBlockBox = blockBoxes.pop();
							boolean isInlineBox = inlineBoxes.pop();
							if (isBlockBox) {
								if (!pendingId.isEmpty()) {
									if (shiftedId == null)
										throw new RuntimeException();
									else
										shiftedId.putAll(pendingId);
									pendingId.clear(); }}
							if (isInlineBox) {
								if (shiftedId != null)
									throw new RuntimeException("coding error");
								shiftedId = new ShiftedId();
								writer.writeEvent(shiftedId); }
							if (isInlineBox)
								insideInlineBox = false;
							writer.copyEvent(event, reader);
							break; }
						default:
							writer.copyEvent(event, reader); }}
					catch (NoSuchElementException e) {
						break; }
				if (!pendingId.isEmpty())
					if (shiftedId == null)
						throw new RuntimeException("invalid input");
					else
						shiftedId.putAll(pendingId);
				if (shiftedId != null)
					shiftedId.render();
				writer.flush(); }
			catch (XMLStreamException e) {
				throw new TransformationException(e); }
		}
		
		private class ShiftedId implements FutureEvent {
			
			private List<String> ids;
			private boolean ready = false;
			
			private void put(String id) {
				if (this.ids == null)
					this.ids = new ArrayList<String>();
				this.ids.add(id);
			}
			
			private void putAll(List<String> ids) {
				for (String id : ids) put(id);
			}
			
			private void render() {
				ready = true;
			}
			
			public void writeTo(Writer writer) throws XMLStreamException {
				if (!ready)
					throw new XMLStreamException("not ready");
				if (ids != null) {
					String id = ids.get(0);
					for (String oldId : ids)
						if (!oldId.equals(id))
							idMap.put(oldId, id);
					writer.writeStartElement(CSS__);
					writer.writeAttribute(CSS_ID, id);
					writer.writeEndElement(); }
			}
			
			public boolean isReady() {
				return ready;
			}
		}
	}
	
	private static class UpdateRefsTransform extends StreamToStreamTransform {
		
		final Map<String,String> idMap;
		
		public UpdateRefsTransform(Configuration configuration, Map<String,String> idMap) {
			super(configuration);
			this.idMap = idMap;
		}
		
		protected void _transform(XMLStreamReader reader, BufferedWriter writer) throws TransformationException {
			try {
				while (true)
					try {
						int event = reader.next();
						switch (event) {
						case START_ELEMENT: {
							writer.copyEvent(event, reader);
							QName elemName = reader.getName();
							boolean isCounter = CSS_COUNTER.equals(elemName);
							String counterTarget = null;
							String anchor = null;
							for (int i = 0; i < reader.getAttributeCount(); i++) {
								QName attrName = reader.getAttributeName(i);
								String attrValue = reader.getAttributeValue(i);
								if (CSS_ANCHOR.equals(attrName))
									anchor = attrValue;
								else if (isCounter && _TARGET.equals(attrName)) {
									counterTarget = attrValue;
								} else {
									writer.writeAttribute(attrName, attrValue);
								}
							}
							if (anchor != null) {
								if (idMap.containsKey(anchor)) {
									anchor = idMap.get(anchor);
								}
								writer.writeAttribute(CSS_ANCHOR, anchor);
							}
							if (counterTarget != null) {
								if (idMap.containsKey(counterTarget)) {
									counterTarget = idMap.get(counterTarget);
								}
								writer.writeAttribute(_TARGET, counterTarget);
							}
							break; }
						default:
							writer.copyEvent(event, reader); }}
					catch (NoSuchElementException e) {
						break; }
				writer.flush(); }
			catch (XMLStreamException e) {
				throw new TransformationException(e); }
		}
	}
	
	private static final Logger logger = LoggerFactory.getLogger(CssShiftIdStep.class);
	
}
