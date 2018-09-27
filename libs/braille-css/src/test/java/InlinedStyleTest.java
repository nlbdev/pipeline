import java.util.Iterator;

import cz.vutbr.web.css.Declaration;
import cz.vutbr.web.css.RuleBlock;
import cz.vutbr.web.css.Term;

import org.daisy.braille.css.InlinedStyle;
import org.daisy.braille.css.InlinedStyle.RuleMainBlock;
import org.daisy.braille.css.InlinedStyle.RulePseudoElementBlock;
import org.daisy.braille.css.SelectorImpl.PseudoElementImpl;

import org.junit.Assert;
import org.junit.Test;

public class InlinedStyleTest {
	
	@Test
	public void testInlinedStyle() {
		InlinedStyle style = new InlinedStyle(
			// FIXME: @page { size: 25 10; } not supported
			"{ text-transform: none } ::table-by(row)::list-item { margin-left:2; }" );
		Iterator<RuleBlock<?>> blocks;
		RuleBlock<?> block;
		Iterator<Declaration> declarations;
		Declaration declaration;
		Iterator<Term<?>> terms;
		PseudoElementImpl pseudo;
		blocks = style.iterator();
		Assert.assertTrue(blocks.hasNext());
		block = blocks.next();
		Assert.assertTrue(block instanceof RuleMainBlock);
		Assert.assertTrue(block == style.getMainStyle());
		declarations = ((RuleMainBlock)block).iterator();
		Assert.assertTrue(declarations.hasNext());
		declaration = declarations.next();
		Assert.assertEquals("text-transform", declaration.getProperty());
		terms = declaration.iterator();
		Assert.assertTrue(terms.hasNext());
		Assert.assertEquals("none", terms.next().toString());
		Assert.assertFalse(terms.hasNext());
		Assert.assertFalse(declarations.hasNext());
		Assert.assertTrue(blocks.hasNext());
		block = blocks.next();
		Assert.assertTrue(block instanceof RulePseudoElementBlock);
		pseudo = ((RulePseudoElementBlock)block).getPseudoElement();
		Assert.assertEquals("table-by", pseudo.getName());
		Assert.assertEquals(1, pseudo.getArguments().length);
		Assert.assertEquals("row", pseudo.getArguments()[0]);
		Assert.assertTrue(pseudo.getPseudoClasses().isEmpty());
		Assert.assertTrue(pseudo.hasStackedPseudoElement());
		pseudo = pseudo.getStackedPseudoElement();
		Assert.assertEquals("list-item", pseudo.getName());
		Assert.assertTrue(pseudo.getPseudoClasses().isEmpty());
		Assert.assertFalse(pseudo.hasStackedPseudoElement());
		declarations = ((RulePseudoElementBlock)block).iterator();
		Assert.assertTrue(declarations.hasNext());
		declaration = declarations.next();
		Assert.assertEquals("margin-left", declaration.getProperty());
		terms = declaration.iterator();
		Assert.assertTrue(terms.hasNext());
		Assert.assertEquals("2", terms.next().toString());
		Assert.assertFalse(terms.hasNext());
		Assert.assertFalse(declarations.hasNext());
		Assert.assertFalse(blocks.hasNext());
	}
}
