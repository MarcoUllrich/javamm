/*
 * generated by Xtext
 */
package javamm.formatting

import com.google.inject.Inject
import javamm.services.JavammGrammarAccess
import org.eclipse.xtext.formatting.impl.FormattingConfig
import org.eclipse.xtext.xbase.formatting.XbaseFormatter
import org.eclipse.xtext.xbase.services.XbaseGrammarAccess
import javamm.services.JavammGrammarAccess.JavammSemicolonStatementElements

// import com.google.inject.Inject;
// import javamm.services.JavammGrammarAccess

/**
 * This class contains custom formatting description.
 * 
 * see : http://www.eclipse.org/Xtext/documentation.html#formatting
 * on how and when to use it 
 * 
 * Also see {@link org.eclipse.xtext.xtext.XtextFormattingTokenSerializer} as an example
 */
class JavammFormatter extends XbaseFormatter {

	@Inject extension JavammGrammarAccess
	
	@Inject XbaseGrammarAccess xbaseGrammarAccess
	
	override protected void configureFormatting(FormattingConfig c) {
		super.configureFormatting(c)
		
		// It's usually a good idea to activate the following three statements.
		// They will add and preserve newlines around comments
		c.setLinewrap(0, 1, 2).before(SL_COMMENTRule)
		c.setLinewrap(0, 1, 2).before(ML_COMMENTRule)
		c.setLinewrap(0, 1, 1).after(ML_COMMENTRule)
		
		configureJavammSemicolonStatement(c, javammSemicolonStatementAccess)
	}

	override protected getGrammarAccess() {
		xbaseGrammarAccess
	}

	override configureXBlockExpression(FormattingConfig c, XbaseGrammarAccess.XBlockExpressionElements _ele) {
		val ele = XBlockExpressionAccess
		c.setLinewrap().after(ele.getLeftCurlyBracketKeyword_1());
		c.setIndentationIncrement().after(ele.getLeftCurlyBracketKeyword_1());
		// semicolons are handled by our custom JavammSemicolonStatement
//		c.setLinewrap().after(ele.getExpressionsAssignment_2_0());
//		c.setNoSpace().before(ele.getSemicolonKeyword_2_1());
//		c.setLinewrap().after(ele.getSemicolonKeyword_2_1());
		c.setLinewrap().before(ele.getRightCurlyBracketKeyword_3());
		c.setIndentationDecrement().before(ele.getRightCurlyBracketKeyword_3());
	}

	def private configureJavammSemicolonStatement(FormattingConfig c, JavammSemicolonStatementElements ele) {
		c.setLinewrap().after(ele.semicolonKeyword_1);
		c.setNoSpace().before(ele.semicolonKeyword_1);
		c.setLinewrap().after(ele.semicolonKeyword_1);
	}
	
}
