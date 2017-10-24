package org.daisy.dotify.formatter.impl;

import java.util.ArrayList;
import java.util.List;
import java.util.Stack;

import org.daisy.dotify.api.formatter.BlockPosition;
import org.daisy.dotify.api.formatter.FormattingTypes.BreakBefore;
import org.daisy.dotify.api.formatter.FormattingTypes.Keep;

/**
 * Provides data about a single rendering scenario.
 * 
 * @author Joel Håkansson
 */
class ScenarioData {
		Stack<RowGroupSequence> dataGroups = new Stack<>();
		private int keepWithNext = 0;

		ScenarioData() {
			dataGroups = new Stack<>();
			keepWithNext = 0;
		}

		/**
		 * Creates a deep copy of the supplied instance
		 * @param template the instance to copy
		 */
		ScenarioData(ScenarioData template) {
			dataGroups = new Stack<>();
			for (RowGroupSequence rgs : template.dataGroups) {
				dataGroups.add(new RowGroupSequence(rgs));
			}
			keepWithNext = template.keepWithNext;
		}

		private int getKeepWithNext() {
			return keepWithNext;
		}

		private void setKeepWithNext(int keepWithNext) {
			this.keepWithNext = keepWithNext;
		}

		float calcSize() {
			float size = 0;
			for (RowGroupSequence rgs : dataGroups) {
				size += rgs.calcSequenceSize();
			}
			return size;
		}
		
		private boolean isDataEmpty() {
			return (dataGroups.isEmpty()||dataGroups.peek().getGroup().isEmpty());
		}
		
		private void newRowGroupSequence(BlockPosition pos, RowImpl emptyRow) {
			RowGroupSequence rgs = new RowGroupSequence(pos, emptyRow);
			dataGroups.add(rgs);
		}
		
		private void addRowGroup(RowGroup rg) {
			dataGroups.peek().getGroup().add(rg);
		}
		
		private void addBlock(Block b) {
			dataGroups.peek().getBlocks().add(b);
		}

		private static void setProperties(RowGroup.Builder rgb, AbstractBlockContentManager bcm, Block g) {
			if (!"".equals(g.getIdentifier())) { 
				rgb.identifier(g.getIdentifier());
			}
			rgb.markers(bcm.getGroupMarkers());
			rgb.anchors(bcm.getGroupAnchors());
			rgb.keepWithNextSheets(g.getKeepWithNextSheets());
			rgb.keepWithPreviousSheets(g.getKeepWithPreviousSheets());
		}
		
		void processBlock(LayoutMaster master, Block g, AbstractBlockContentManager bcm) {
			if (dataGroups.isEmpty() || (g.getBreakBeforeType()==BreakBefore.PAGE && !isDataEmpty()) || g.getVerticalPosition()!=null) {
				newRowGroupSequence(g.getVerticalPosition(), new RowImpl("", bcm.getLeftMarginParent(), bcm.getRightMarginParent()));
				setKeepWithNext(-1);
			}
			addBlock(g);
			List<RowGroup> store = new ArrayList<>();
			List<RowImpl> rl1 = bcm.getCollapsiblePreContentRows();
			if (!rl1.isEmpty()) {
				store.add(new RowGroup.Builder(master.getRowSpacing(), rl1).
										collapsible(true).skippable(false).breakable(false).build());
			}
			List<RowImpl> rl2 = bcm.getInnerPreContentRows();
			if (!rl2.isEmpty()) {
				for (RowImpl r : rl2) {
					r.setAdjustedForMargin(true);
				}
				store.add(new RowGroup.Builder(master.getRowSpacing(), rl2).
										collapsible(false).skippable(false).breakable(false).build());
			}
			
			if (bcm.getRowCount()==0) { //TODO: Does this interfere with collapsing margins? 
				if (!bcm.getGroupAnchors().isEmpty() || !bcm.getGroupMarkers().isEmpty() || !"".equals(g.getIdentifier())
						|| g.getKeepWithNextSheets()>0 || g.getKeepWithPreviousSheets()>0 ) {
					RowGroup.Builder rgb = new RowGroup.Builder(master.getRowSpacing(), new ArrayList<RowImpl>());
					setProperties(rgb, bcm, g);
					store.add(rgb.build());
				}
			}

			int i = 0;
			List<RowImpl> rl3 = bcm.getPostContentRows();
			OrphanWidowControl owc = new OrphanWidowControl(g.getRowDataProperties().getOrphans(),
															g.getRowDataProperties().getWidows(), 
															bcm.getRowCount());
			for (RowImpl r : bcm) {
				i++;
				r.setAdjustedForMargin(true);
				if (i==bcm.getRowCount()) {
					//we're at the last line, this should be kept with the next block's first line
					setKeepWithNext(g.getKeepWithNext());
				}
				RowGroup.Builder rgb = new RowGroup.Builder(master.getRowSpacing()).add(r).
						collapsible(false).skippable(false).breakable(
								r.allowsBreakAfter()&&
								owc.allowsBreakAfter(i-1)&&
								getKeepWithNext()<=0 &&
								(Keep.AUTO==g.getKeepType() || i==bcm.getRowCount()) &&
								(i<bcm.getRowCount() || rl3.isEmpty())
								);
				if (i==1) { //First item
					setProperties(rgb, bcm, g);
				}
				store.add(rgb.build());
				setKeepWithNext(getKeepWithNext()-1);
			}
			if (!rl3.isEmpty()) {
				for (RowImpl r : rl3) {
					r.setAdjustedForMargin(true);
				}
				store.add(new RowGroup.Builder(master.getRowSpacing(), rl3).
					collapsible(false).skippable(false).breakable(getKeepWithNext()<0).build());
			}
			List<RowImpl> rl4 = bcm.getSkippablePostContentRows();
			if (!rl4.isEmpty()) {
				store.add(new RowGroup.Builder(master.getRowSpacing(), rl4).
					collapsible(true).skippable(true).breakable(getKeepWithNext()<0).build());
			}
			if (store.isEmpty() && !dataGroups.isEmpty()) {
				RowGroup gx = dataGroups.peek().currentGroup();
				if (gx!=null && gx.getAvoidVolumeBreakAfterPriority()==g.getAvoidVolumeBreakInsidePriority()
						&&gx.getAvoidVolumeBreakAfterPriority()!=g.getAvoidVolumeBreakAfterPriority()) {
					gx.setAvoidVolumeBreakAfterPriority(g.getAvoidVolumeBreakAfterPriority());
				}
			} else {
				for (int j=0; j<store.size(); j++) {
					RowGroup b = store.get(j);
					if (j==store.size()-1) {
						b.setAvoidVolumeBreakAfterPriority(g.getAvoidVolumeBreakAfterPriority());
					} else {
						b.setAvoidVolumeBreakAfterPriority(g.getAvoidVolumeBreakInsidePriority());
					}
					addRowGroup(b);
				}
			}
		}
	}