package javamm.controlflow

import org.eclipse.xtext.xbase.XExpression
import javamm.javamm.JavammBranchingStatement
import org.eclipse.xtext.xbase.XIfExpression
import org.eclipse.xtext.xbase.XBlockExpression
import javamm.javamm.JavammSemicolonStatement

/**
 * Whether in the passed expression a branching statement like break
 * and continue is surely executed.
 * 
 * @author Lorenzo Bettini
 */
class JavammBranchingStatementDetector {
	
	def boolean isSureBranchStatement(XExpression e) {
		if (e == null)
			return false;
		return sureBranch(e)
	}

	def protected dispatch sureBranch(XExpression e) {
		return false
	}

	def protected dispatch sureBranch(JavammBranchingStatement e) {
		return true
	}

	def protected dispatch sureBranch(XIfExpression e) {
		return isSureBranchStatement(e.then)
			&& (e.^else == null || isSureBranchStatement(e.^else))
	}

	def protected dispatch sureBranch(XBlockExpression e) {
		e.expressions.exists[isSureBranchStatement]
	}

	def protected dispatch sureBranch(JavammSemicolonStatement e) {
		e.expression.isSureBranchStatement
	}
}