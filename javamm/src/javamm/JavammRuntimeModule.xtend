/*
 * generated by Xtext
 */
package javamm

import com.google.inject.Binder
import com.google.inject.name.Names
import javamm.scoping.JavammImportedNamespaceScopeProvider
import javamm.scoping.JavammQualifiedNameProvider
import javamm.validation.JavammConfigurableIssueCodes
import javamm.validation.JavammDiagnosticConverter
import org.eclipse.xtext.naming.IQualifiedNameProvider
import org.eclipse.xtext.scoping.IScopeProvider
import org.eclipse.xtext.scoping.impl.AbstractDeclarativeScopeProvider
import org.eclipse.xtext.validation.ConfigurableIssueCodesProvider
import org.eclipse.xtext.validation.IDiagnosticConverter

/** 
 * Use this class to register components to be used at runtime / without the Equinox extension registry.
 */
class JavammRuntimeModule extends AbstractJavammRuntimeModule {

	def Class<? extends IDiagnosticConverter> bindIDiagnosticConverter() {
		return JavammDiagnosticConverter
	}

	override Class<? extends IQualifiedNameProvider> bindIQualifiedNameProvider() {
		return JavammQualifiedNameProvider
	}

	override Class<? extends ConfigurableIssueCodesProvider> bindConfigurableIssueCodesProvider() {
		return JavammConfigurableIssueCodes
	}

	override void configureIScopeProviderDelegate(Binder binder) {
		binder.bind(IScopeProvider).annotatedWith(
			Names.named(AbstractDeclarativeScopeProvider.NAMED_DELEGATE)).to(JavammImportedNamespaceScopeProvider)
	}
}