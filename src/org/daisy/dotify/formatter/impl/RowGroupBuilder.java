package org.daisy.dotify.formatter.impl;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import org.daisy.dotify.api.formatter.FormattingTypes.Keep;
import org.daisy.dotify.api.formatter.MarginRegion;

class RowGroupBuilder {
	
	private static int getTotalMarginRegionWidth(LayoutMaster master) {
		int mw = 0;
		for (MarginRegion mr : master.getTemplate(1).getLeftMarginRegion()) {
			mw += mr.getWidth();
		}
		for (MarginRegion mr : master.getTemplate(1).getRightMarginRegion()) {
			mw += mr.getWidth();
		}
		return mw;
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

	static Iterator<RowGroupSequence> getResult(LayoutMaster master, BlockSequence in, BlockContext blockContext) {
		//TODO: This assumes that all page templates have margin regions that are of the same width  
		final BlockContext bc = new BlockContext(in.getLayoutMaster().getFlowWidth() - getTotalMarginRegionWidth(master), blockContext.getRefs(), blockContext.getContext(), blockContext.getFcontext());
		List<Block> data = new ArrayList<>();
		for (RowGroupSequence s : getResultInner(master, in, bc)) {
			data.addAll(s.getBlocks());
		}
		return getResultInner(master, data, bc).iterator();
	}
	
	private static Iterable<RowGroupSequence> getResultInner(LayoutMaster master, Iterable<Block> seq, BlockContext bc) {
		final PageSequenceRecorder rec = new PageSequenceRecorder();
		for (Block g : seq)  {
			try {
				AbstractBlockContentManager bcm = rec.processBlock(g, bc);

				List<RowGroup> store = new ArrayList<>();
				List<RowImpl> rl1 = bcm.getCollapsiblePreContentRows();
				if (!rl1.isEmpty()) {
					store.add(new RowGroup.Builder(master.getRowSpacing(), rl1).
											collapsible(true).skippable(false).breakable(false).build());
				}
				List<RowImpl> rl2 = bcm.getInnerPreContentRows();
				if (!rl2.isEmpty()) {
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
						rec.setKeepWithNext(g.getKeepWithNext());
					}
					RowGroup.Builder rgb = new RowGroup.Builder(master.getRowSpacing()).add(r).
							collapsible(false).skippable(false).breakable(
									r.allowsBreakAfter()&&
									owc.allowsBreakAfter(i-1)&&
									rec.getKeepWithNext()<=0 &&
									(Keep.AUTO==g.getKeepType() || i==bcm.getRowCount()) &&
									(i<bcm.getRowCount() || rl3.isEmpty())
									);
					if (i==1) { //First item
						setProperties(rgb, bcm, g);
					}
					store.add(rgb.build());
					rec.setKeepWithNext(rec.getKeepWithNext()-1);
				}
				if (!rl3.isEmpty()) {
					store.add(new RowGroup.Builder(master.getRowSpacing(), rl3).
						collapsible(false).skippable(false).breakable(rec.getKeepWithNext()<0).build());
				}
				List<RowImpl> rl4 = bcm.getSkippablePostContentRows();
				if (!rl4.isEmpty()) {
					store.add(new RowGroup.Builder(master.getRowSpacing(), rl4).
						collapsible(true).skippable(true).breakable(rec.getKeepWithNext()<0).build());
				}
				if (store.isEmpty() && !rec.isDataGroupsEmpty()) {
					RowGroup gx = rec.currentSequence().currentGroup();
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
						rec.addRowGroup(b);
					}
				}
			} catch (Exception e) {
				rec.invalidateScenario(e);
			}
		}
		return rec.processResult();
	}

}