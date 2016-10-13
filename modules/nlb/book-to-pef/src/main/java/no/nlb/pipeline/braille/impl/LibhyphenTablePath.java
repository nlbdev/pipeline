package no.nlb.pipeline.braille.impl;

import java.util.Map;

import org.osgi.service.component.annotations.Activate;
import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.ComponentContext;

@Component(
	name = "no.nlb.pipeline.braille.impl.LibhyphenTablePath",
	service = {
		org.daisy.pipeline.braille.libhyphen.LibhyphenTablePath.class
	},
	property = {
		"identifier:String=http://www.nlb.no/hyphen/",
		"path:String=/hyph",
		"includes:String=*.dic"
	}
)
public class LibhyphenTablePath extends org.daisy.pipeline.braille.libhyphen.LibhyphenTablePath {
	
	@Activate
	protected void activate(ComponentContext context, Map<?,?> properties) throws Exception {
		super.activate(context, properties);
	}
}
