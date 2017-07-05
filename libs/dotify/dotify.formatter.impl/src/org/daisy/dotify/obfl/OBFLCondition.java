package org.daisy.dotify.obfl;

import org.daisy.dotify.api.formatter.Condition;
import org.daisy.dotify.api.formatter.Context;
import org.daisy.dotify.api.obfl.ExpressionFactory;
import org.daisy.dotify.obfl.impl.ExpressionTools;

public class OBFLCondition extends OBFLExpressionBase implements Condition {

	public OBFLCondition(String exp, ExpressionFactory ef, boolean extended) {
		super(exp, ef, extended);
	}

	@Override
	public boolean evaluate() {
		if (exp==null) {
			return true;
		} else {
			return ef.newExpression().evaluate(exp).equals(true);
		}
	}

	@Override
	public boolean evaluate(Context context) {
		if (exp==null) {
			return true;
		} else {
			return ef.newExpression().evaluate(ExpressionTools.resolveVariables(exp, buildArgs(context))).equals(true);
		}
	}

}
