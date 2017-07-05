package org.daisy.dotify.formatter.impl;

import org.daisy.dotify.api.formatter.SequenceProperties;
import org.daisy.dotify.formatter.impl.search.CrossReferenceHandler;

/**
 * Provides a volume sequence object. A volume sequence is a chunk of contents
 * that is to be placed before or after the contents of a volume.
 * 
 * @author Joel Håkansson
 */
interface VolumeSequence {
	/**
	 * Gets the volume sequence properties.
	 * @return returns the volume sequence properties
	 */
	public SequenceProperties getSequenceProperties();
	
	public BlockSequence getBlockSequence(FormatterContext context, DefaultContext c, CrossReferenceHandler crh);
}
