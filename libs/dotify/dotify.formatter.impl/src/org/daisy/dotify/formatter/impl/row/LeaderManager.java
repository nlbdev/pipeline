package org.daisy.dotify.formatter.impl.row;

import java.util.logging.Level;
import java.util.logging.Logger;

import org.daisy.dotify.api.formatter.Leader;
import org.daisy.dotify.api.translator.BrailleTranslator;
import org.daisy.dotify.api.translator.Translatable;
import org.daisy.dotify.api.translator.TranslationException;
import org.daisy.dotify.common.text.StringTools;

class LeaderManager {
	private static final Logger logger = Logger.getLogger(LeaderManager.class.getCanonicalName());
	private Leader currentLeader;

	LeaderManager() {
		this.currentLeader = null;
	}

	LeaderManager(LeaderManager template) {
		this.currentLeader = template.currentLeader;
	}

	void setLeader(Leader leader) {
		this.currentLeader = leader;
	}

	boolean hasLeader() {
		return currentLeader!=null;
	}

	void discardLeader() {
		currentLeader = null;
	}

	int getLeaderPosition(int width) {
		if (hasLeader()) {
			return currentLeader.getPosition().makeAbsolute(width);
		} else {
			return 0;
		}
	}

	int getLeaderAlign(int length) {
		if (hasLeader()) {
			switch (currentLeader.getAlignment()) {
				case LEFT:
					return 0;
				case RIGHT:
					return length;
				case CENTER:
					return length/2;
			}
		}
		return 0;
	}

	String getLeaderPattern(BrailleTranslator translator, int len) {
		if (!hasLeader()) {
			return "";
		} else if (len > 0) {
			String leaderPattern;
			try {
				leaderPattern = translator.translate(Translatable.text(currentLeader.getPattern()).build()).getTranslatedRemainder();
			} catch (TranslationException e) {
				throw new RuntimeException(e);
			}
			return StringTools.fill(leaderPattern, len);
		} else {
			if (logger.isLoggable(Level.FINE)) {
				logger.fine("Leader position has been passed on an empty row or text does not fit on an empty row, ignoring...");
			}
			return "";
		}
	}

}
