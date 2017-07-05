package org.daisy.dotify.obfl.impl;

import org.daisy.dotify.api.obfl.Expression;
import org.daisy.dotify.api.obfl.ExpressionFactory;
import org.daisy.dotify.api.text.Integer2TextFactoryMakerService;
import org.daisy.dotify.formatter.impl.SPIHelper;

import aQute.bnd.annotation.component.Component;
import aQute.bnd.annotation.component.Reference;

/**
 * Provides an expression factory implementation.
 * @author Joel Håkansson
 */
@Component
public class ExpressionFactoryImpl implements ExpressionFactory {
	private Integer2TextFactoryMakerService itf;

	@Override
	public Expression newExpression() {
		return new ExpressionImpl(itf);
	}

	/**
	 * Sets a factory dependency.
	 * @param service the dependency
	 */
	@Reference
	public void setInteger2TextFactory(Integer2TextFactoryMakerService service) {
		this.itf = service;
	}

	/**
	 * Removes a factory dependency.
	 * @param service the dependency to remove
	 */
	public void unsetInteger2TextFactory(Integer2TextFactoryMakerService service) {
		this.itf = null;
	}

	@Override
	public void setCreatedWithSPI() {
		setInteger2TextFactory(SPIHelper.getInteger2TextFactoryMaker());
	}

}
