/*
 * generated by Xtext
 */
package javamm;

import javamm.typesystem.JavammTypeComputer;

import org.eclipse.xtext.xbase.typesystem.computation.ITypeComputer;


/**
 * Use this class to register components to be used at runtime / without the Equinox extension registry.
 */
public class JavammRuntimeModule extends javamm.AbstractJavammRuntimeModule {

	@Override
	public Class<? extends ITypeComputer> bindITypeComputer() {
		return JavammTypeComputer.class;
	}
}
