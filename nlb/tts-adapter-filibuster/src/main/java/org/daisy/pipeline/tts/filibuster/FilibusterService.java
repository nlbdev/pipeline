package org.daisy.pipeline.tts.filibuster;

import java.io.File;
import java.util.Map;

import org.daisy.common.shell.BinaryFinder;
import org.daisy.pipeline.tts.AbstractTTSService;
import org.daisy.pipeline.tts.TTSEngine;

import com.google.common.base.Optional;

public class FilibusterService extends AbstractTTSService {

	@Override
	public TTSEngine newEngine(Map<String, String> params) throws Throwable {
		// settings
		String filibusterPath = null;
		String tclshPath = null;
		String filibusterProp = "filibuster.path";
		String filibusterEnv = "FILIBUSTER_HOME";
		String tclshProp = "filibuster.tclsh";
		
		tclshPath = System.getProperty(tclshProp);
		if (tclshPath == null) {
			Optional<String> tpath = BinaryFinder.find("tclsh");
			if (!tpath.isPresent()) {
				throw new SynthesisException("Cannot find tclsh's binary using system property " + tclshProp);
			}
			tclshPath = tpath.get();
		}
		
		filibusterPath = System.getProperty(filibusterProp);
		if (filibusterPath == null) {
			filibusterPath = System.getenv(filibusterEnv);
		}
		if (filibusterPath == null) {
			if (new File("/opt/filibuster/").isDirectory()) {
				filibusterPath = new File("/opt/filibuster").getCanonicalPath();
				
			} else if (new File("C:\\filibuster\\").isDirectory()) {
				filibusterPath = new File("C:\\filibuster\\").getCanonicalPath(); 
			}
		}
		if (filibusterPath == null) {
			throw new SynthesisException("Cannot find the path to filibuster using either system property " + filibusterProp + " or environment variable " + filibusterEnv + " and filibuster was not found in /opt/filibuster/ nor in C:\\filibuster\\");
		}

		String priority = params.get("filibuster.priority");
		int intPriority = 2;
		if (priority != null) {
			try {
				intPriority = Integer.valueOf(priority);
			} catch (NumberFormatException e) {

			}
		}

		return new FilibusterEngine(this, filibusterPath, tclshPath, intPriority);
	}

	@Override
	public String getName() {
		return "filibuster";
	}

	@Override
	public String getVersion() {
		return "cli";
	}
}
