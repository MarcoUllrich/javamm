package javamm.tests

import javamm.javamm.JavammPackage
import javamm.validation.JavammValidator
import jbase.jbase.JbasePackage
import jbase.validation.JbaseIssueCodes
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.diagnostics.Diagnostic
import org.eclipse.xtext.diagnostics.Severity
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.eclipse.xtext.xbase.XbasePackage
import org.eclipse.xtext.xbase.validation.IssueCodes
import org.eclipse.xtext.xtype.XtypePackage
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(JavammInjectorProvider))
class JavammValidatorTest extends JavammAbstractTest {

	val jbasePack = JbasePackage.eINSTANCE
	val javammPack = JavammPackage.eINSTANCE

	@Test def void testArrayIndexNotIntegerLeft() {
		'''
		args[true] = 0;
		'''.parse.assertTypeMismatch(
			XbasePackage.eINSTANCE.XBooleanLiteral,
			"int",
			"boolean"
		)
	}

	@Test def void testArrayIndexNotIntegerRight() {
		'''
		String s = args[true];
		'''.parse.assertTypeMismatch(
			XbasePackage.eINSTANCE.XBooleanLiteral,
			"int",
			"boolean"
		)
	}

	@Test def void testArrayIndexNotIntegerInArrayConstructorCall() {
		'''
		int[] i = new int[true];
		'''.parse.assertTypeMismatch(
			XbasePackage.eINSTANCE.XBooleanLiteral,
			"int",
			"boolean"
		)
	}

	@Test def void testArrayIndexNotIntegerInMemberFeatureCall() {
		'''
		int[][] a;
		int l = a[true].length;
		'''.parse.assertTypeMismatch(
			XbasePackage.eINSTANCE.XBooleanLiteral,
			"int",
			"boolean"
		)
	}

	@Test def void testTypeMismatchInArrayDimensionExpression() {
		'''
		int[] i = new int[] { 1, true, 2};
		int[][] j = new int[][] {{ 1, 2}, { 1, "foo", 2}};
		int[][] j = new int[][] { 1 };
		'''.parse => [
			assertTypeMismatch(
				XbasePackage.eINSTANCE.XBooleanLiteral,
				"int",
				"boolean"
			)
			assertTypeMismatch(
				XbasePackage.eINSTANCE.XStringLiteral,
				"int",
				"String"
			)
			assertTypeMismatch(
				XbasePackage.eINSTANCE.XNumberLiteral,
				"int[]",
				"int"
			)
		]
	}

	@Test def void testArrayConstructorSpecifiesNeitherDimensionExpressionNorInitializer() {
		'''
		int[] a = new int[];
		'''.parse.assertError(
			jbasePack.XJArrayConstructorCall,
			JbaseIssueCodes.ARRAY_CONSTRUCTOR_EITHER_DIMENSION_EXPRESSION_OR_INITIALIZER,
			"Constructor must provide either dimension expressions or an array initializer"
		)
	}

	@Test def void testArrayConstructorSpecifiesBothDimensionExpressionAndInitializer() {
		'''
		int[] j = new int[1] {};
		'''.parse.assertError(
			jbasePack.XJArrayConstructorCall,
			JbaseIssueCodes.ARRAY_CONSTRUCTOR_BOTH_DIMENSION_EXPRESSION_AND_INITIALIZER,
			"Cannot define dimension expressions when an array initializer is provided"
		)
	}

	@Test def void testArrayConstructorSpecifiesDimensionExpressionAfterEmptyDimension() {
		'''
		int[][] j = new int[][0];
		'''.parse.assertError(
			XbasePackage.eINSTANCE.XNumberLiteral,
			JbaseIssueCodes.ARRAY_CONSTRUCTOR_DIMENSION_EXPRESSION_AFTER_EMPTY_DIMENSION,
			"Cannot specify an array dimension after an empty dimension"
		)
	}

	@Test def void testArrayConstructorSpecifiesDimensionExpressionAfterEmptyDimension2() {
		'''
		int[][][] j = new int[0][][1];
		'''.parse.assertError(
			XbasePackage.eINSTANCE.XNumberLiteral,
			JbaseIssueCodes.ARRAY_CONSTRUCTOR_DIMENSION_EXPRESSION_AFTER_EMPTY_DIMENSION,
			"Cannot specify an array dimension after an empty dimension"
		)
	}

	@Test def void testNotArrayTypeLeft() {
		'''
		int i;
		i[0] = 0;
		'''.parse.assertError(
			jbasePack.XJAssignment,
			JbaseIssueCodes.NOT_ARRAY_TYPE,
			"The type of the expression must be an array type but it resolved to int"
		)
	}

	@Test def void testNotArrayTypeRight() {
		'''
		int i;
		i = i[0];
		'''.parse.assertError(
			jbasePack.XJArrayAccessExpression,
			JbaseIssueCodes.NOT_ARRAY_TYPE,
			"The type of the expression must be an array type but it resolved to int"
		)
	}

	@Test def void testNotMultiArrayTypeRight() {
		'''
		int[] i;
		i = i[0][1];
		'''.parse.assertError(
			jbasePack.XJArrayAccessExpression,
			JbaseIssueCodes.NOT_ARRAY_TYPE,
			"The type of the expression must be an array type but it resolved to int"
		)
	}

	@Test def void testNotMultiArrayTypeLeft() {
		'''
		int[] i;
		i[0][1] = 1;
		'''.parse.assertError(
			jbasePack.XJAssignment,
			JbaseIssueCodes.NOT_ARRAY_TYPE,
			"The type of the expression must be an array type but it resolved to int"
		)
	}

	@Test def void testWrongMultiArrayConstructor() {
		'''
		int[] i = new int[0][1];
		'''.parse.assertTypeMismatch(
			jbasePack.XJArrayConstructorCall,
			"int[]", "int[][]"
		)
	}

	@Test def void testWrongElementInArrayLiteral() {
		'''
		int[] i = {0, true};
		'''.parse.assertTypeMismatch(
			XbasePackage.eINSTANCE.XBooleanLiteral,
			"int",
			"boolean"
		)
	}

	@Test def void testStringLiteralAsStatement() {
		'''
		"test";
		'''.parse.assertNoSideEffectError(XbasePackage.eINSTANCE.XStringLiteral)
	}

	@Test def void testBooleanExpressionAsStatement() {
		'''
		"test" != "a";
		'''.parse => [
			assertNoSideEffectError(XbasePackage.eINSTANCE.XBinaryOperation)
			assertErrorsAsStrings("This expression is not allowed in this context, since it doesn't cause any side effects.")
		]
	}

	@Test def void testDeadCodeAfterReturn() {
		'''
		void m() {
			return;
			System.out.println("");
		}
		'''.parse.assertUnreachableExpression(jbasePack.XJSemicolonStatement)
	}

	@Test def void testDeadCodeInForLoopTranslatedToJavaWhileEarlyExit() {
		forLoopTranslatedToJavaWhileEarlyExit.
			parse.assertUnreachableExpression(XbasePackage.eINSTANCE.XBinaryOperation)
	}

	@Test def void testNoDeadCodeWithAdditionalSemicolons() {
		additionalSemicolons.parseAndAssertNoErrors
	}

	@Test def void testDeadCodeAfterReturnWithAdditionalSemicolons() {
		'''
		void m() {
			return;;
		}
		'''.parse.assertUnreachableExpression(jbasePack.XJSemicolonStatement)
	}

	@Test def void testNoDeadCodeWithBreakInAWhileWithConditionAlwaysTrue() {
		'''
		int d = 1;
		while (1 == 1) {
			d++;
			if (d == 3)
				break;
		}
		d = 0;
		'''.parseAndAssertNoErrors
	}

	@Test def void testDeadCodeWithContinueInAWhileWithConditionAlwaysTrue() {
		'''
		int d = 1;
		while (1 == 1) {
			d++;
			if (d == 3)
				continue;
		}
		d = 0;
		'''.parse.assertUnreachableExpression(jbasePack.XJSemicolonStatement)
	}

	@Test def void testDeadCodeWithoutInAWhileWithConditionAlwaysTrue() {
		'''
		int d = 1;
		while (1 == 1) {
			d++;
		}
		d = 0;
		'''.parse.assertUnreachableExpression(jbasePack.XJSemicolonStatement)
	}

	@Test def void testNoDeadCodeWithBreakInADoWhileWithConditionAlwaysTrue() {
		'''
		int d = 1;
		do {
			d++;
			if (d == 3)
				break;
		} while (1 == 1);
		d = 0;
		'''.parseAndAssertNoErrors
	}

	@Test def void testNoDeadCodeWithBreakInSingleIfBranchInADoWhileWithConditionAlwaysTrue() {
		'''
		int d = 1;
		do {
			d++;
			if (d == 3)
				break;
			else
				d = 1;
		} while (1 == 1);
		d = 0;
		'''.parseAndAssertNoErrors
	}

	@Test def void testDeadCodeWithContinueInADoWhileWithConditionAlwaysTrue() {
		'''
		int d = 1;
		do {
			d++;
			if (d == 3)
				continue;
		} while (1 == 1);
		d = 0;
		'''.parse.assertUnreachableExpression(jbasePack.XJSemicolonStatement)
	}

	@Test def void testNoDeadCodeWithBreakInABasicForLoopWithConditionAlwaysTrue() {
		'''
		int d = 1;
		for (;;) {
			d++;
			if (d == 3)
				break;
		}
		d = 0;
		'''.parseAndAssertNoErrors
	}

	@Test def void testDeadCodeWithContinueInABasicForLoopWithConditionAlwaysTrue() {
		'''
		int d = 1;
		for (;;) {
			d++;
			if (d == 3)
				continue;
		}
		d = 0;
		'''.parse.assertUnreachableExpression(jbasePack.XJSemicolonStatement)
	}

	@Test def void testInvalidFunctionalType() {
		'''
		()=>int f = null;
		'''.parse.assertError(
			jbasePack.XJSemicolonStatement,
			Diagnostic.SYNTAX_DIAGNOSTIC,
			"no viable alternative at input ')'"
		)
	}

	@Test def void testNoPrintlnExtensionMethod() {
		'''
		println("Hello");
		'''.parse.assertErrorsAsStrings(
		'''
		The method println(String) is undefined
		'''
		)
	}

	@Test def void testNoAddToCollectionExtensionMethod() {
		'''
		java.util.List<String> strings = new java.util.LinkedList<String>();
		strings += "a";
		'''.parse.assertTypeMismatch(
			XbasePackage.eINSTANCE.XBinaryOperation,
			"List<String>",
			"String"
		)
	}

	@Test def void testValidExplicitAddToCollection() {
		'''
		java.util.List<String> strings = new java.util.LinkedList<String>();
		strings.add("a");
		'''.parse.assertNoErrors
	}

	@Test def void testInvalidContinue() {
		'''
		void m() {
			if (true)
				continue;
		}
		'''.parse.assertInvalidContinueStatement
	}

	@Test def void testInvalidContinue2() {
		'''
		if (true)
			continue;
		'''.parse.assertInvalidContinueStatement
	}

	@Test def void testInvalidBreak() {
		'''
		void m() {
			if (true)
				break;
		}
		'''.parse.assertInvalidBreakStatement
	}

	@Test def void testInvalidBreak2() {
		'''
		if (true)
			break;
		'''.parse.assertInvalidBreakStatement
	}

	@Test def void testInvalidCharAssignment() {
		'''
		char c = "c";
		'''.parse.assertTypeMismatch(
			XbasePackage.eINSTANCE.XStringLiteral,
			"char", "String"
		)
	}

	@Test def void testInvalidStringAssignment() {
		'''
		String s = 's';
		'''.parse.assertTypeMismatch(
			jbasePack.XJCharLiteral,
			"String", "char"
		)
	}

	@Test def void testInvalidCharLiteralAssignmentToBoolean() {
		// https://bugs.eclipse.org/bugs/show_bug.cgi?id=457779
		'''
		boolean b = 's';
		'''.parse.assertTypeMismatch(
			jbasePack.XJCharLiteral,
			"boolean", "char"
		)
	}

	@Test def void testBooleanLiteralAssignableToBoolean() {
		'''
		boolean b = true;
		'''.parseAndAssertNoErrors
	}

	@Test def void testInvalidSwitchExpression() {
		'''
		switch (return 0) {
			default: 
				System.out.println("default");
				break;
		}
		'''.parse.assertError(
			XbasePackage.eINSTANCE.XSwitchExpression,
			Diagnostic.SYNTAX_DIAGNOSTIC,
			"no viable alternative at input 'return'"
		)
	}

	@Test def void testInvalidSwitchCaseType() {
		'''
		String firstArg = args[0];
		char arg = firstArg.toCharArray()[0];
		switch (arg) {
			case "f" : 
				System.out.println("0");
				break;
			default: 
				System.out.println("default");
				break;
		}
		'''.parse.assertTypeMismatch(
			XbasePackage.eINSTANCE.XStringLiteral,
			"char", "String"
		)
	}

	@Test def void testInvalidSwitchReturnType() {
		'''
		int move(int p) {
			switch (p) {
				case 0: return "2";
				default: return -1;
			}
		}
		'''.parse.assertTypeMismatch(
			XbasePackage.eINSTANCE.XStringLiteral,
			"int", "String"
		)
	}

	@Test def void testInvalidSwitchReturnType2() {
		'''
		int move(int p) {
			switch (p) {
				case 0: System.out.println("0"); break;
				default: return -1;
			}
		}
		'''.parse.assertTypeMismatch(
			jbasePack.XJBreakStatement,
			"int", "void"
		)
	}

	@Test def void testInvalidSwitchWithoutDefault() {
		'''
		int move(int p) {
			switch (p) {
				case 0: return 1;
			}
		}
		'''.parse.assertErrorsAsStrings(
		'''
		Missing default branch in the presence of expected type int
		Missing return'''
		)
	}

	@Test def void testValidSwitchReturnTypeWithFallback() {
		'''
		int move(int p) {
			switch (p) {
				case 0: System.out.println("0"); // the default is executed
				default: return -1;
			}
		}
		'''.parse.assertNoErrors
	}

//	@Test def void testWarningSwitchMissingDefaultBranchForPrimitiveType() {
//		'''
//		void move(int p) {
//			switch (p) {
//				case 0: System.out.println("0");
//			}
//		}
//		'''.parse.assertIssuesAsStrings("Missing default branch for switch expression with primitive type")
//	}

	@Test def void testMissingSemicolonInAssignment() {
		'''
		int i = 0;
		i = 1
		'''.parse.assertMissingSemicolon(XbasePackage.eINSTANCE.XAssignment)
	}

	@Test def void testMissingSemicolonInVariableDeclaration() {
		'''
		int i = 0
		'''.parse.assertMissingSemicolon(XbasePackage.eINSTANCE.XVariableDeclaration)
	}

	@Test def void testMissingSemicolonInContinue() {
		'''
		continue
		'''.parse.assertMissingSemicolon(jbasePack.XJContinueStatement)
	}

	@Test def void testMissingSemicolonInBreak() {
		'''
		break
		'''.parse.assertMissingSemicolon(jbasePack.XJBreakStatement)
	}

	@Test def void testMissingSemicolonInReturn() {
		'''
		void m() {
			return
		}
		'''.parse.assertMissingSemicolon(XbasePackage.eINSTANCE.XReturnExpression)
	}

	@Test def void testMissingSemicolonInDoWhile() {
		'''
		do {
			
		} while (true)
		'''.parse.assertMissingSemicolon(XbasePackage.eINSTANCE.XDoWhileExpression)
	}

	@Test def void testMissingSemicolonInFeatureCall() {
		'''
		i
		'''.parse.assertMissingSemicolon(XbasePackage.eINSTANCE.XFeatureCall)
	}

	@Test def void testMissingSemicolonInFeatureCall2() {
		'''
		i()
		'''.parse.assertMissingSemicolon(XbasePackage.eINSTANCE.XFeatureCall)
	}

	@Test def void testMissingSemicolonInMemberFeatureCall() {
		'''
		System.out.println()
		'''.parse.assertMissingSemicolon(XbasePackage.eINSTANCE.XMemberFeatureCall)
	}

	@Test def void testMissingSemicolonInImport() {
		'''
		import java.util.List
		'''.parse.assertMissingSemicolon(XtypePackage.eINSTANCE.XImportDeclaration)
	}

	@Test def void testTwoSemicolonsInImportIsOk() {
		'''
		import java.util.List;;
		'''.parseAndAssertNoErrors
	}

	@Test def void testMissingParenthesesForMemberCall() {
		'''
		System.out.println;
		'''.parse.assertMissingParentheses(XbasePackage.eINSTANCE.XMemberFeatureCall)
	}

	@Test def void testMissingParenthesesForMemberCall2() {
		'''
		System.out.println
		'''.parse.assertMissingParentheses(XbasePackage.eINSTANCE.XMemberFeatureCall)
	}

	@Test def void testMissingParenthesesForMethodCall() {
		'''
		void m() {}
		m;
		'''.parse.assertMissingParentheses(XbasePackage.eINSTANCE.XFeatureCall)
	}

	@Test def void testMissingParenthesesForMethodCall2() {
		'''
		void m() {}
		m
		'''.parse.assertMissingParentheses(XbasePackage.eINSTANCE.XFeatureCall)
	}

	@Test def void testMissingParenthesesForArrayLengthOK() {
		'''
		int i = args.length;
		'''.parseAndAssertNoErrors
	}

	@Test def void testInvalidXbaseOperator() {
		'''
		int i;
		System.out.println(i === 0);
		'''.parse.assertError(
			XbasePackage.eINSTANCE.XBinaryOperation,
			Diagnostic.SYNTAX_DIAGNOSTIC,
			"no viable alternative at input '='"
		)
	}

	@Test def void testDuplicateMethods() {
		val input =
		'''
		void m() {}
		void n() {}
		int m() { return 0; }
		'''
		input.parse => [
			assertError(
				javammPack.javammMethod,
				JavammValidator.DUPLICATE_METHOD,
				input.indexOf("m"), 1,
				"Duplicate definition 'm'"
			)
			assertError(
				javammPack.javammMethod,
				JavammValidator.DUPLICATE_METHOD,
				input.lastIndexOf("m"), 1,
				"Duplicate definition 'm'"
			)
			assertErrorsAsStrings(
			'''
			Duplicate definition 'm'
			Duplicate definition 'm' '''
			)
		]
	}

	@Test def void testDuplicateMethodsWithMain() {
		val input =
		'''
		void main(String[] a) {}
		'''
		input.parse => [
			assertError(
				javammPack.javammMethod,
				JavammValidator.DUPLICATE_METHOD,
				input.indexOf("main"), 4,
				"main(java.lang.String[]) is a reserved method"
			)
		]
	}

	@Test def void testDuplicateMethodsWithMainWithReturnType() {
		val input =
		'''
		int main(String[] a) {}
		'''
		input.parse => [
			assertError(
				javammPack.javammMethod,
				JavammValidator.DUPLICATE_METHOD,
				input.indexOf("main"), 4,
				"main(java.lang.String[]) is a reserved method"
			)
		]
	}

	@Test def void testDuplicateMethodsWithMainVarArgs() {
		val input =
		'''
		void main(String... a) {}
		'''
		input.parse => [
			assertError(
				javammPack.javammMethod,
				JavammValidator.DUPLICATE_METHOD,
				input.indexOf("main"), 4,
				"main(java.lang.String[]) is a reserved method"
			)
		]
	}

	@Test def void testDuplicateMethodsWithTheSameErasedSignature() {
		val input =
		'''
		void m(java.util.List<String> l) {}
		void n() {}
		int m(java.util.List<Integer> l2) { return 0; }
		'''
		input.parse => [
			assertError(
				javammPack.javammMethod,
				JavammValidator.DUPLICATE_METHOD,
				input.indexOf("m"), 1,
				"Duplicate definition 'm'"
			)
			assertError(
				javammPack.javammMethod,
				JavammValidator.DUPLICATE_METHOD,
				input.lastIndexOf("m"), 1,
				"Duplicate definition 'm'"
			)
			assertErrorsAsStrings(
			'''
			Duplicate definition 'm'
			Duplicate definition 'm' '''
			)
		]
	}

	@Test def void testValidOverloadedMethods() {
		val input =
		'''
		void m() {}
		void n() {}
		int m(int i) { return 0; }
		'''
		input.parseAndAssertNoErrors
	}


	@Test def void testParams() {
		'''
		void m(int i, boolean b, String i) {}
		'''.parse.assertErrorsAsStrings(
		'''Duplicate local variable i'''
		)
	}

	@Test def void testWrongVariableDeclarationInSeveralDeclarations() {
		'''
		int i = 0, j = "a", k = true;
		'''.parse.assertErrorsAsStrings(
		'''
		Type mismatch: cannot convert from String to int
		Type mismatch: cannot convert from boolean to int'''
		)
	}

	@Test def void testValidAccessToVariable() {
		'''
		int i = 0;

		System.out.println(i);
		'''.parse.assertNoIssues
	}

	@Test def void testVariableDeclarationsNoUnusedWarningsWhenUsed() {
		'''
		int i = 0, j = 0, k = 0;

		System.out.println(i);
		System.out.println(j);
		System.out.println(k);
		'''.parse.assertNoIssues
	}

	@Test def void testUnusedSeveralVariableDeclarations() {
		'''
		int i = 0, j = 0, k = 0;
		System.out.println(j);
		'''.parse.assertIssuesAsStrings(
		'''
		The value of the local variable i is not used
		The value of the local variable k is not used
		'''
		)
	}

	@Test def void testPostfixOnWrongExpression() {
		'''
		"a"++;
		'''.parse.assertIssuesAsStrings(
		'''
		++ cannot be resolved.
		'''
		)
	}

	@Test def void testWrongPostfixOnMethodCall() {
		'''
		int m() { return 0; }
		
		int i = m()++;
		'''.parse.assertErrorsAsStrings(
		'''
		The left-hand side of an assignment must be a variable
		'''
		)
	}

	@Test def void testPostfixOnArrayAccess() {
		'''
		
		int i = 0;
		int[] a = {1,2,3,4};
		a[i]++;
		'''.parseAndAssertNoIssues
	}

	@Test def void testPrefixOnWrongExpression() {
		'''
		++"a";
		'''.parse.assertIssuesAsStrings(
		'''
		++ cannot be resolved.
		'''
		)
	}

	@Test def void testWrongPrefixOnMethodCall() {
		'''
		int m() { return 0; }
		
		int i = ++m();
		'''.parse.assertErrorsAsStrings(
		'''
		The left-hand side of an assignment must be a variable
		'''
		)
	}

	@Test def void testArrayAccessOnMemberFeatureCallNotAnArray() {
		'''
		int a;
		int l = a[0].length;
		'''.parse.assertErrorsAsStrings(
		'''
		The method or field length is undefined for the type int
		The type of the expression must be an array type but it resolved to int
		'''
		)
	}

	@Test def void testArrayAccessOnMemberFeatureCallAndClone() {
		'''
		// clone has a generic type, so the result is inferred
		int[] a = null;
		int[] cl1 = a.clone(); // OK
		'''.parseAndAssertNoErrors
	}

	@Test def void testArrayAccessOnMemberFeatureCallAndClone2() {
		'''
		// clone has a generic type, so the result is inferred
		int[] a;
		int cl1 = a[0].clone(); // inferred as Object
		'''.parse.assertErrorsAsStrings(
		'''
		The method clone() is not visible
		Type mismatch: cannot convert from Object to int
		'''
		)
	}

	@Test def void testArrayAccessOnMemberFeatureCallAndClone3() {
		'''
		// clone has a generic type, so the result is inferred
		String[] a;
		String cl1 = a[0].clone();
		'''.parse.assertErrorsAsStrings(
		'''
		The method clone() is not visible
		Type mismatch: cannot convert from Object to String
		'''
		)
	}

	@Test def void testArrayAccessOnMemberFeatureCallAndClone4() {
		'''
		// clone has a generic type, so the result is inferred
		String[][] a = null;
		String[] cl1 = a[0].clone();
		'''.parseAndAssertNoErrors
	}

	@Test def void testIntegerCannotBeAssignedToByte() {
		"byte b = 1000;".parse.assertNumberLiteralTypeMismatch("byte", "int")
	}

	@Test def void testIntegerCannotBeAssignedToChar() {
		"char c = 100000;".parse.assertNumberLiteralTypeMismatch("char", "int")
	}

	@Test def void testIntegerCannotBeAssignedToChar2() {
		"char c = -10000;".parse.assertTypeMismatch(XbasePackage.eINSTANCE.XUnaryOperation, "char", "int")
	}

	@Test def void testMaxValueChar() {
		"char c = 65535;".parseAndAssertNoErrors
	}

	@Test def void testIntegerCannotBeAssignedToShort() {
		"short s = 100000;".parse.assertNumberLiteralTypeMismatch("short", "int")
	}

	@Test def void testNegativeCanBeAssignedToShort() {
		// https://github.com/LorenzoBettini/javamm/issues/53
		"short s = -10000;".parseAndAssertNoErrors
	}

	@Test def void testDoubleNegativeCanBeAssignedToShort() {
		// https://github.com/LorenzoBettini/javamm/issues/53
		"short s = -(-10000);".parseAndAssertNoErrors
	}

	@Test def void testNegativePositiveCanBeAssignedToShort() {
		// https://github.com/LorenzoBettini/javamm/issues/53
		"short s = -(+10000);".parseAndAssertNoErrors
	}

	@Test def void testPositiveCanBeAssignedToChar() {
		// https://github.com/LorenzoBettini/javamm/issues/53
		"char c = +10;".parseAndAssertNoErrors
	}

	@Test def void testTypeMismatchAfterCast() {
		'''
		char c = 'c';
		String r2 = (char) (int) c;
		'''.parse.assertTypeMismatch(
			XbasePackage.eINSTANCE.XCastedExpression,
			"String", "char"
		)
	}

	@Test def void testInvalidCast() {
		'''
		System.out.println((String) 0);
		'''.parse.assertErrorsAsStrings("Cannot cast from int or Integer to String")
	}

	@Test def void testWarningUnnecessaryCast() {
		'''
		System.out.println((int) 0);
		'''.parse.assertIssuesAsStrings("Unnecessary cast from int to int")
	}

	@Test def void testTypeMismatchInConditionalExpression() {
		'''
		int i = 0;
		int l = i > 0 ? true : 10;
		'''.parse.assertTypeMismatch(
			XbasePackage.eINSTANCE.XBooleanLiteral,
			"int",
			"boolean"
		)
	}

	@Test def void testTypeMismatchInConditionalExpression2() {
		'''
		int i = 0;
		int l = i > 0 ? 10 : true;
		'''.parse.assertTypeMismatch(
			XbasePackage.eINSTANCE.XBooleanLiteral,
			"int",
			"boolean"
		)
	}

	@Test def void testTypeMismatchInConditionalExpression3() {
		'''
		int i = 0;
		int l = 10 ? 20 : 30;
		'''.parse.assertTypeMismatch(
			XbasePackage.eINSTANCE.XNumberLiteral,
			"boolean",
			"int"
		)
	}

	@Test def void testUseOfThis() {
		'''
		System.out.println(this);
		'''.parse.assertIssuesAsStrings("Java-- does not support 'this'")
	}

	@Test def void testUseOfSuper() {
		'''
		System.out.println(super);
		'''.parse.assertIssuesAsStrings("Java-- does not support 'super'")
	}

	@Test def void testTypeMismatchWithGenerics() {
		'''
		java.util.Vector<String> v = new java.util.Vector<Object>();
		System.out.println(v);
		'''.parse.assertIssuesAsStrings("Type mismatch: cannot convert from Vector<Object> to Vector<String>")
	}

	@Test def void testTypeErrorWithWildcardExtends() {
		'''
		java.util.Vector<? extends String> v = new java.util.Vector<String>();
		v.add("s");
		'''.parse.assertIssuesAsStrings("Type mismatch: type String is not applicable at this location")
	}

	@Test def void testTypeErrorWithWildcardSuper() {
		'''
		java.util.Vector<? super String> v = new java.util.Vector<String>();
		String s = v.get(0);
		System.out.println(s);
		'''.parse.assertIssuesAsStrings("Type mismatch: cannot convert from Object to String")
	}

	@Test def void testFinalVariableNotInitialized() {
		'''
		final int i;
		'''.parse.assertError(
			jbasePack.XJVariableDeclaration,
			IssueCodes.MISSING_INITIALIZATION,
			"Value must be initialized"
		)
	}

	@Test def void testFinalVariableNotInitialized2() {
		'''
		final int i = 0, j;
		'''.parse.assertErrorsAsStrings("Value must be initialized")
	}

	@Test def void testAssignmentToFinalVariable() {
		'''
		final int i = 0;
		i = 1;
		'''.parse.assertIssuesAsStrings("Assignment to final variable")
	}

	@Test def void testAssignmentToFinalArrayVariable() {
		'''
		final int[] i = {0};
		i = {0};
		'''.parse.assertIssuesAsStrings("Assignment to final variable")
	}

	@Test def void testAssignmentToFinalArrayVariableElementOk() {
		'''
		final int[] i = {0};
		i[0] = 0;
		'''.parseAndAssertNoIssues
	}

	@Test def void testAssignmentToFinalVariableAdditional() {
		'''
		final int i = 0, j = 0;
		j = 1;
		'''.parse.assertErrorsAsStrings("Assignment to final variable")
	}

	@Test def void testAssignmentToFinalParameter() {
		'''
		void m(final int i) {
			i = 1;
		}
		'''.parse.assertIssuesAsStrings("Assignment to final parameter")
	}

	@Test def void testAssignmentToFinalParameterInForEachLoop() {
		'''
		java.util.List<String> strings;
		for (final String s : strings)
			s = "a";
		'''.parse.assertIssuesAsStrings("Assignment to final parameter")
	}

	@Test def void testAssignmentToParameter() {
		assignToParam.parseAndAssertNoErrors
	}

	@Test def void testInstanceOfWithoutExplicitCast() {
		'''
		import java.util.Date;
		
		Object d = new Date();
		if (d instanceof Date) {
			System.out.println(((Date)d).getTime());
		}
		'''.parseAndAssertNoIssues
	}

	@Test def void testInstanceOfWithoutExplicitCastError() {
		'''
		import java.util.Date;
		
		Object d = new Date();
		if (d instanceof Date) {
			System.out.println(d.getTime());
		}
		'''.parse.assertErrorsAsStrings("The method getTime() is undefined for the type Object")
	}

	@Test def void testInvalidUseOfVarArgs() {
		val input = '''
		void m(int... i, String... a) {
			
		}
		'''
		input.parse.assertError(
			jbasePack.XJJvmFormalParameter,
			JbaseIssueCodes.INVALID_USE_OF_VAR_ARGS,
			input.indexOf("..."), 3,
			"A vararg must be the last parameter."
		)
	}

	@Test def void testMissingReturnStatementDueToImplicitReturn() {
		// https://github.com/LorenzoBettini/javamm/issues/32
		val input = '''
		int m(int i) {
			0;
		}
		'''
		input.parse.assertMissingReturn(XbasePackage.eINSTANCE.XNumberLiteral)
	}

	@Test def void testMissingReturnStatementInEmptyBlock() {
		// https://github.com/LorenzoBettini/javamm/issues/32
		val input = '''
		int m(int i) {
		}
		'''
		input.parse.assertMissingReturn(XbasePackage.eINSTANCE.XBlockExpression)
	}

	@Test def void testMissingReturnStatement() {
		// https://github.com/LorenzoBettini/javamm/issues/32
		val input = '''
		int m(int i) {
			if (i < 0) {
				return 0;
			}
		}
		'''
		input.parse.assertMissingReturn(XbasePackage.eINSTANCE.XIfExpression)
	}

	@Test def void testReturnStatementInBothIfBranches() {
		val input = '''
		int m(int i) {
			if (i < 0) {
				return 0;
			} else {
				return 1;
			}
		}
		'''
		input.parse.assertNoErrors
	}

	@Test def void testIncompatibleOperandTypes_Issue_39() {
		// note that the error is reported only in the workbench,
		// after the generated Java code is compiled.
		// so in this test no error is detected.
		// In the workbench test the error is correctly detected:
		// see javamm.ui.tests.JavammWorkbenchTest.testErrorInGeneratedJavaCode()
		val input = '''
		int a = 2;
		int b = 2;
		int c = 2;
		if (a==b==c==2) {
			System.out.println("TRUE");
		}
		'''
		input.parse.assertNoErrors
	}

	@Test def void testInvalidCharacterConstant() {
		val input = '''
		System.out.println('12');
		'''
		input.parse.assertError(
			jbasePack.XJCharLiteral,
			JbaseIssueCodes.INVALID_CHARACTER_CONSTANT,
			input.indexOf("'12'"), 4,
			"Invalid character constant"
		)
	}

	@Test def void testInvalidCharacterConstantWithBackslash() {
		val input = '''
		System.out.println('\at');
		'''
		input.parse.assertError(
			jbasePack.XJCharLiteral,
			JbaseIssueCodes.INVALID_CHARACTER_CONSTANT,
			input.indexOf("'\\at'"), 5,
			"Invalid character constant"
		)
	}

	@Test def void testValidCharacterConstant() {
		val input = '''
		System.out.println('\t');
		System.out.println('t');
		'''
		input.parse.assertNoErrors
	}

	@Test def void testVariableNotInitializedInMain() {
		val input = '''
		int i;
		System.out.println(i);
		'''
		input.parse.assertVariableNotInitialized("i")
	}

	@Test def void testVariableNotInitializedInMethod() {
		val input = '''
		void m() {
			int i;
			System.out.println(i);
		}
		'''
		input.parse.assertVariableNotInitialized("i")
	}

	@Test def void testInvalidExponentiation_Issue_43() {
		// https://github.com/LorenzoBettini/javamm/issues/43
		'''
		double x = 2 ** 3;
		'''.parse.assertError(
			XbasePackage.eINSTANCE.XBinaryOperation,
			Diagnostic.SYNTAX_DIAGNOSTIC,
			"no viable alternative at input '*'"
		)
	}

	@Test def void testValidMultiplication() {
		'''
		double x = 2 * 3;
		'''.parse.assertNoErrors
	}

	@Test def void testJbaseExpressionArgumentFactory_Issue57() {
		// https://github.com/LorenzoBettini/javamm/issues/57
		'''
		toString[0] = 0;
		'''.parse.assertErrorsAsStrings(
		'''
		The type of the expression must be an array type but it resolved to String
		Cannot make a static reference to the non-static method toString from the type __synthetic0
		Invalid number of arguments. The method toString() is not applicable for the arguments (int)
		'''
		)
	}

	def private assertNumberLiteralTypeMismatch(EObject o, String expectedType, String actualType) {
		o.assertTypeMismatch(XbasePackage.eINSTANCE.XNumberLiteral, expectedType, actualType)
	}

	def private assertTypeMismatch(EObject o, EClass c, String expectedType, String actualType) {
		o.assertError(
			c,
			IssueCodes.INCOMPATIBLE_TYPES,
			'''Type mismatch: cannot convert from «actualType» to «expectedType»'''
		)
	}

	def private assertNoSideEffectError(EObject o, EClass c) {
		o.assertError(
			c,
			IssueCodes.INVALID_INNER_EXPRESSION,
			'''This expression is not allowed in this context, since it doesn't cause any side effects.'''
		)
	}

	def private assertUnreachableExpression(EObject o, EClass c) {
		o.assertError(
			c,
			IssueCodes.UNREACHABLE_CODE,
			'''Unreachable expression.'''
		)
	}

	def private assertInvalidContinueStatement(EObject o) {
		o.assertError(
			jbasePack.XJContinueStatement,
			JbaseIssueCodes.INVALID_BRANCHING_STATEMENT,
			"continue cannot be used outside of a loop"
		)
	}

	def private assertInvalidBreakStatement(EObject o) {
		o.assertError(
			jbasePack.XJBreakStatement,
			JbaseIssueCodes.INVALID_BRANCHING_STATEMENT,
			"break cannot be used outside of a loop or a switch"
		)
	}

	def private assertErrorsAsStrings(EObject o, CharSequence expected) {
		expected.toString.trim.assertEqualsStrings(
			o.validate.filter[severity == Severity.ERROR].map[message].join("\n"))
	}

	def private assertIssuesAsStrings(EObject o, CharSequence expected) {
		expected.toString.trim.assertEqualsStrings(
			o.validate.map[message].join("\n"))
	}

	def private assertMissingSemicolon(EObject o, EClass c) {
		o.assertError(
			c,
			JbaseIssueCodes.MISSING_SEMICOLON,
			'Syntax error, insert ";" to complete Statement'
		)
	}

	def private assertMissingParentheses(EObject o, EClass c) {
		o.assertError(
			c,
			JbaseIssueCodes.MISSING_PARENTHESES,
			'Syntax error, insert "()" to complete method call'
		)
	}

	def private assertMissingReturn(EObject o, EClass c) {
		o.assertError(
			c,
			JbaseIssueCodes.MISSING_RETURN,
			'Missing return'
		)
	}

	def private assertVariableNotInitialized(EObject o, String name) {
		o.assertError(
			XbasePackage.eINSTANCE.XFeatureCall,
			JbaseIssueCodes.NOT_INITIALIZED_VARIABLE,
			"The local variable " + name + " may not have been initialized"
		)
	}
}
