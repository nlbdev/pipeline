package ch.sbs.maven;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.text.SimpleDateFormat;
import java.util.Date;

import org.apache.maven.plugin.AbstractMojo;
import org.apache.maven.plugin.MojoFailureException;
import org.apache.maven.plugins.annotations.LifecyclePhase;
import org.apache.maven.plugins.annotations.Mojo;
import org.apache.maven.plugins.annotations.Parameter;
import org.apache.maven.project.MavenProject;

@Mojo(
	name = "set-detailed-project-version",
	defaultPhase = LifecyclePhase.INITIALIZE
)
public class SetDetailedProjectVersionMojo extends AbstractMojo {
	
	@Parameter(
		readonly = true,
		required = true,
		defaultValue = "${project}"
	)
	private MavenProject project;
	
	@Parameter(
		readonly = true,
		required = true,
		defaultValue = "${project.version}"
	)
	private String projectVersion;
	
	public void execute() throws MojoFailureException {
		String detailedVersion;
		String timeStamp;
		String gitCommit; {
			try {
				if (projectVersion.endsWith("-SNAPSHOT")) {
					timeStamp = new SimpleDateFormat("yyyyMMdd.HHmmss").format(new Date());
					Process p = Runtime.getRuntime().exec("git describe --tags --always --dirty");
					p.waitFor();
					BufferedReader reader = new BufferedReader(new InputStreamReader(p.getInputStream()));
					gitCommit = reader.readLine();
					if (gitCommit == null || reader.readLine() != null)
						throw new RuntimeException();
					detailedVersion = projectVersion.substring(0, projectVersion.length() - 9)
						+ "~" + timeStamp
						+ "-" + gitCommit
					;
				} else {
					timeStamp = null;
					gitCommit = null;
					detailedVersion = projectVersion;
				}
			} catch (Exception e) {
				throw new MojoFailureException("Error computing detailed version", e);
			}
		}
		project.getProperties().put("project.detailedVersion", detailedVersion);
		if (timeStamp != null) {
			project.getProperties().put("project.detailedVersion.timestamp", timeStamp);
		}
		if (gitCommit != null) {
			project.getProperties().put("project.detailedVersion.commit", gitCommit);
		}
	}
}
