import java.io.File;
import java.util.HashMap;
import java.util.Map;

import org.daisy.maven.xspec.TestResults;

import org.daisy.pipeline.junit.AbstractXSpecAndXProcSpecTest;

import org.junit.Assert;
import org.junit.Test;

import org.ops4j.pax.exam.util.PathUtils;

public class XSpecAndXProcSpecTest extends AbstractXSpecAndXProcSpecTest {
	
	@Override
	public void runXSpec() {
		File baseDir = new File(PathUtils.getBaseDir());
		File testsDir = new File(baseDir, "src/test/xspec");
		File reportsDir = new File(baseDir, "target/surefire-reports");
		reportsDir.mkdirs();
		Map<String,File> tests = new HashMap<String,File>(); {
			tests.put("line-number", new File(testsDir, "line-number.xspec"));
		}
		TestResults result = xspecRunner.run(tests, reportsDir);
		Assert.assertEquals("Number of failures and errors should be zero", 0L, result.getFailures() + result.getErrors());
	}
}
