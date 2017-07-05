package org.daisy.dotify.formatter.impl;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.daisy.dotify.api.formatter.RenderingScenario;

/**
 * Processes scenarios and selects the best one. The decision is based on the cost
 * function supplied with the scenario.
 * 
 * @author Joel Håkansson
 */
class ScenarioProcessor {
	private static final String baseline = "base";
	private static final String scenario = "best";
	
	private ScenarioData data;

	private RenderingScenario current = null;
	private RenderingScenario invalid = null;
	private double cost = 0;
	private float height = 0;
	private float minWidth = 0;
	private double forceCount = 0;
	private Map<String, ScenarioData> states;

	ScenarioProcessor() {
		data = new ScenarioData();
		states = new HashMap<>();
	}
	
	private void saveState(String id) {
		states.put(id, new ScenarioData(data));
	}
	
	private void restoreState(String id) {
		ScenarioData state = states.get(id);
		if (state!=null) {
			data = new ScenarioData(state);
		}
	}
	
	private void clearState(String id) {
		states.remove(id);
	}
	
	private boolean hasState(String id) {
		return states.containsKey(id);
	}
	
	static Iterable<RowGroupSequence> process(LayoutMaster master, Iterable<Block> seq, BlockContext bc) {
		final ScenarioProcessor rec = new ScenarioProcessor();
		for (Block g : seq)  {
			try {
				rec.processBlock(master, g, bc);
			} catch (Exception e) {
				rec.invalidateScenario(e);
			}
		}
		return rec.processResult();
	}
	
	/**
	 * Process a new block for a scenario
	 * @param g
	 * @param rec
	 */
	void processBlock(LayoutMaster master, Block g, BlockContext context) {
		// FIXME: These calls have to be on separate lines, because variable data might mutate
		AbstractBlockContentManager ret = processBlockInner(g, context);
		data.processBlock(master, g, ret);
	}

	private AbstractBlockContentManager processBlockInner(Block g, BlockContext context) {
		AbstractBlockContentManager ret = g.getBlockContentManager(context);
		if (g.getRenderingScenario()!=null) {
			if (invalid!=null && g.getRenderingScenario()==invalid) {
				//we're still in the same scenario
				return ret;
			}
			if (current==null) {
				height = data.calcSize();
				cost = Double.MAX_VALUE;
				minWidth = ret.getMinimumAvailableWidth();
				forceCount = 0;
				clearState(scenario);
				saveState(baseline);
				current = g.getRenderingScenario();
				invalid = null;
			} else {
				if (current!=g.getRenderingScenario()) {
					if (invalid!=null) {
						invalid = null;
						if (hasState(scenario)) {
							restoreState(scenario);
						} else {
							restoreState(baseline);
						}
					} else {
						//TODO: measure, evaluate
						float size = data.calcSize()-height;
						double ncost = current.calculateCost(setParams(size, minWidth, forceCount));
						if (ncost<cost) {
							//if better, store
							cost = ncost;
							saveState(scenario);
						}
						restoreState(baseline);
						minWidth = ret.getMinimumAvailableWidth();
						forceCount = 0;
					}
					current = g.getRenderingScenario();
				} // we're rendering the current scenario
				forceCount += ret.getForceBreakCount();
				minWidth = Math.min(minWidth, ret.getMinimumAvailableWidth());
			}
		} else {
			finishBlockProcessing();
		}
		return ret;
	}
	
	private void finishBlockProcessing() {
		if (current!=null) {
			if (invalid!=null) {
				invalid = null;
				if (hasState(scenario)) {
					restoreState(scenario);
				} else {
					throw new RuntimeException("Failed to render any scenario.");
				}
			} else {
				//if not better
				float size = data.calcSize()-height;
				double ncost = current.calculateCost(setParams(size, minWidth, forceCount));
				if (ncost>cost) {
					restoreState(scenario);
				}
			}
			current = null;
			invalid = null;
		}
	}
	
	/**
	 * Invalidates the current scenario, if any. This causes the remainder of the
	 * scenario to be excluded from further processing.
	 * 
	 * @param e the exception that caused the scenario to be invalidated
	 * @throws RuntimeException if no scenario is active 
	 */
	void invalidateScenario(Exception e) {
		if (current==null) {
			throw new RuntimeException(e);
		} else {
			invalid = current;
		}
	}
	
	List<RowGroupSequence> processResult() {
		finishBlockProcessing();
		return data.dataGroups;
	}

	private static Map<String, Double> setParams(double height, double minBlockWidth, double forceCount) {
		Map<String, Double> params = new HashMap<>();
		params.put("total-height", height);
		params.put("min-block-width", minBlockWidth);
		params.put("forced-break-count", forceCount);
		return params;
	}

}
