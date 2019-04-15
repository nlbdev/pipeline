package org.daisy.dotify.formatter.impl.core;

import java.util.Collections;
import java.util.List;

public class TransitionContent {
	public enum Type {
		INTERRUPT,
		RESUME
	}
	private final Type type;
	private final List<Block> inBlock;
	private final List<Block> inSeq;
	private final List<Block> inAny;

	public TransitionContent(Type type, FormatterCoreImpl inBlock, FormatterCoreImpl inSeq, FormatterCoreImpl inAny) {
		this.type = type;
		this.inBlock = Collections.unmodifiableList(inBlock);
		this.inSeq = Collections.unmodifiableList(inSeq);
		this.inAny = Collections.unmodifiableList(inAny);
	}

	public Type getType() {
		return type;
	}

	public List<Block> getInBlock() {
		return inBlock;
	}

	public List<Block> getInSequence() {
		return inSeq;
	}
	
	public List<Block> getInAny() {
		return inAny;
	}
}
