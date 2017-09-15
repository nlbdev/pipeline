import org.daisy.pipeline.junit.AbstractXSpecAndXProcSpecTest;

import static org.daisy.pipeline.pax.exam.Options.*;

import org.ops4j.pax.exam.Configuration;
import static org.ops4j.pax.exam.CoreOptions.composite;
import static org.ops4j.pax.exam.CoreOptions.options;
import org.ops4j.pax.exam.Option;

public class XProcSpecTest extends AbstractXSpecAndXProcSpecTest {
    
    @Override
    protected String[] testDependencies() {
        return new String[] {
            //pipelineModule("common-utils"),
        };
    }
    
    @Override @Configuration
    public Option[] config() {
        return options(
            composite(super.config()),
            mavenBundlesWithDependencies(
                mavenBundle("org.daisy:epubcheck:?"),
                mavenBundle("org.apache.servicemix.bundles:org.apache.servicemix.bundles.xmlresolver:?")
            ),
            
            // for org.apache.httpcomponents:httpclient (<-- xmlcalabash):
            mavenBundle("org.slf4j:jcl-over-slf4j:1.7.2")
        );
    }
}
