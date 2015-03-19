/*
 * generated by Xtext
 */
package javamm;

import javamm.compiler.JavammJvmModelGenerator;
import javamm.compiler.JavammXbaseCompiler;
import javamm.conversion.JavammValueConverterService;
import javamm.scoping.JavammOperatorMapping;
import javamm.scoping.JavammQualifiedNameProvider;
import javamm.typesystem.JavammExpressionArgumentFactory;
import javamm.typesystem.JavammTypeComputer;

import org.eclipse.xtext.conversion.IValueConverterService;
import org.eclipse.xtext.generator.IGenerator;
import org.eclipse.xtext.naming.IQualifiedNameProvider;
import org.eclipse.xtext.xbase.compiler.XbaseCompiler;
import org.eclipse.xtext.xbase.scoping.featurecalls.OperatorMapping;
import org.eclipse.xtext.xbase.typesystem.computation.ITypeComputer;
import org.eclipse.xtext.xbase.typesystem.internal.ExpressionArgumentFactory;


/**
 * Use this class to register components to be used at runtime / without the Equinox extension registry.
 */
public class JavammRuntimeModule extends javamm.AbstractJavammRuntimeModule {

	public Class<? extends ITypeComputer> bindITypeComputer() {
		return JavammTypeComputer.class;
	}

	public Class<? extends XbaseCompiler> bindXbaseCompiler() {
		return JavammXbaseCompiler.class;
	}

	public Class<? extends ExpressionArgumentFactory> bindExpressionArgumentFactory() {
		return JavammExpressionArgumentFactory.class;
	}

	public Class<? extends OperatorMapping> bindOperatorMapping() {
		return JavammOperatorMapping.class;
	}

	@Override
	public Class<? extends IGenerator> bindIGenerator() {
		return JavammJvmModelGenerator.class;
	}

	@Override
	public Class<? extends IValueConverterService> bindIValueConverterService() {
		return JavammValueConverterService.class;
	}

	@Override
	public Class<? extends IQualifiedNameProvider> bindIQualifiedNameProvider() {
		return JavammQualifiedNameProvider.class;
	}

}
