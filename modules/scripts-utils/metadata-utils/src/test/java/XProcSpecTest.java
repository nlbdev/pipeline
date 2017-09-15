import org.daisy.pipeline.junit.AbstractXSpecAndXProcSpecTest;

public class XProcSpecTest extends AbstractXSpecAndXProcSpecTest {
    
    @Override
    protected String[] testDependencies() {
        return new String[] {
            pipelineModule("common-utils"),
            pipelineModule("validation-utils"),
            pipelineModule("dtbook-utils")
        };
    }
    
    // XSpec tests are already run with Maven plugin
    @Override
    public void runXSpec() throws Exception {
    }
}
