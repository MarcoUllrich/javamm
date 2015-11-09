/*
 * generated by Xtext
 */
package javamm;

import org.eclipse.xtext.conversion.IValueConverterService;
import org.eclipse.xtext.generator.IGenerator;
import org.eclipse.xtext.naming.IQualifiedNameProvider;
import org.eclipse.xtext.scoping.impl.AbstractDeclarativeScopeProvider;
import org.eclipse.xtext.validation.ConfigurableIssueCodesProvider;
import org.eclipse.xtext.validation.IDiagnosticConverter;
import org.eclipse.xtext.xbase.compiler.XbaseCompiler;
import org.eclipse.xtext.xbase.controlflow.IEarlyExitComputer;
import org.eclipse.xtext.xbase.imports.RewritableImportSection;
import org.eclipse.xtext.xbase.scoping.featurecalls.OperatorMapping;
import org.eclipse.xtext.xbase.typesystem.computation.ITypeComputer;
import org.eclipse.xtext.xbase.typesystem.internal.ExpressionArgumentFactory;
import org.eclipse.xtext.xbase.validation.ImplicitReturnFinder;

import com.google.inject.Binder;
import com.google.inject.name.Names;

import javamm.compiler.JavammJvmModelGenerator;
import javamm.compiler.JavammXbaseCompiler;
import javamm.controlflow.JavammEarlyExitComputer;
import javamm.conversion.JavammValueConverterService;
import javamm.imports.JavammRewritableImportSection.JavammRewritableImportSectionFactory;
import javamm.scoping.JavammImportedNamespaceScopeProvider;
import javamm.scoping.JavammOperatorMapping;
import javamm.scoping.JavammQualifiedNameProvider;
import javamm.typesystem.JavammExpressionArgumentFactory;
import javamm.typesystem.JavammTypeComputer;
import javamm.validation.JavammConfigurableIssueCodes;
import javamm.validation.JavammDiagnosticConverter;
import javamm.validation.JavammImplicitReturnFinder;


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

	public Class<? extends IDiagnosticConverter> bindIDiagnosticConverter() {
		return JavammDiagnosticConverter.class;
	}
	
	public Class<? extends RewritableImportSection.Factory> bindRewritableImportSection$Factory() {
		return JavammRewritableImportSectionFactory.class;
	}

	public Class<? extends ImplicitReturnFinder> bindImplicitReturnFinder() {
		return JavammImplicitReturnFinder.class;
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

	public Class<? extends IEarlyExitComputer> bindIEarlyExitComputer() {
		return JavammEarlyExitComputer.class;
	}

	@Override
	public Class<? extends ConfigurableIssueCodesProvider> bindConfigurableIssueCodesProvider() {
		return JavammConfigurableIssueCodes.class;
	}

	@Override
	public void configureIScopeProviderDelegate(Binder binder) {
		binder.bind(org.eclipse.xtext.scoping.IScopeProvider.class)
				.annotatedWith(
						Names.named(AbstractDeclarativeScopeProvider.NAMED_DELEGATE))
				.to(JavammImportedNamespaceScopeProvider.class);
	}
}
