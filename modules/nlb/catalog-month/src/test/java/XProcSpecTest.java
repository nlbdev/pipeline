import org.daisy.pipeline.junit.AbstractXSpecAndXProcSpecTest;

public class XProcSpecTest extends AbstractXSpecAndXProcSpecTest {
    
    @Override
    protected String[] testDependencies() {
        return new String[] {
            pipelineModule("common-utils"),
            pipelineModule("fileset-utils"),
            pipelineModule("file-utils"),
            "no.nlb.pipeline.modules:html-to-dtbook:?",
            "no.nlb.pipeline.modules:mailchimp:?",
            "no.nlb.pipeline.modules:metadata-utils:?"
        };
    }
}

