import org.daisy.pipeline.junit.AbstractXSpecAndXProcSpecTest;

import static org.daisy.pipeline.pax.exam.Options.thisPlatform;

public class XProcSpecTest extends AbstractXSpecAndXProcSpecTest {
	
	@Override
	protected String[] testDependencies() {
		return new String[] {
			brailleModule("xml-to-pef"),
			brailleModule("common-utils"),
			brailleModule("pef-utils"),
			brailleModule("obfl-utils"),
			brailleModule("liblouis-utils"),
			brailleModule("dotify-utils"),
			brailleModule("liblouis-tables"),
			"org.daisy.pipeline.modules.braille:liblouis-native:jar:" + thisPlatform() + ":?",
			brailleModule("dotify-formatter"),
			pipelineModule("file-utils"),
			pipelineModule("fileset-utils"),
			pipelineModule("metadata-utils"),
			pipelineModule("dtbook-utils"),
			"org.daisy.pipeline:logging-activator:?",
			// FIXME: Dotify needs older version of jing
			"org.daisy.libs:jing:20120724.0.0",
		};
	}
}
