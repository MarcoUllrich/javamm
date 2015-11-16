/*
 * generated by Xtext
 */
package javamm.serializer;

import java.util.List;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtext.serializer.acceptor.SequenceFeeder;
import org.eclipse.xtext.serializer.sequencer.ISemanticNodeProvider.INodesForEObjectProvider;
import org.eclipse.xtext.xbase.XExpression;

import com.google.inject.Inject;

import javamm.javamm.JavammXMemberFeatureCall;
import javamm.services.JavammGrammarAccess;
import javamm.services.JavammGrammarAccess.XMemberFeatureCallElements;

public class JavammSemanticSequencer extends AbstractJavammSemanticSequencer {

	@Inject
	private JavammGrammarAccess grammarAccess;

	@Override
	protected void sequence_XMemberFeatureCall(EObject context, JavammXMemberFeatureCall featureCall) {
		INodesForEObjectProvider nodes = createNodeProvider(featureCall);
		SequenceFeeder acceptor = createSequencerFeeder(featureCall, nodes);
		XMemberFeatureCallElements memberFeatureCallElements= grammarAccess.getXMemberFeatureCallAccess();

		acceptor.accept(memberFeatureCallElements.getJavammXMemberFeatureCallMemberCallTargetAction_1_1_0_0_0(), featureCall.getArrayAccessExpression().getArray());

		acceptor.accept(memberFeatureCallElements.getIndexesXExpressionParserRuleCall_1_1_0_0_2_0(), featureCall.getIndexes().get(0), 0);

		// feature=[JvmIdentifiableElement|ID]
		acceptor.accept(memberFeatureCallElements.getFeatureJvmIdentifiableElementIdOrSuperParserRuleCall_1_1_1_0_1(), featureCall.getFeature());

		// (explicitOperationCall?='(' (memberCallArguments+=XShortClosure | (memberCallArguments+=XExpression memberCallArguments+=XExpression*))?)? memberCallArguments+=XClosure? 
		if (featureCall.isExplicitOperationCallOrBuilderSyntax()) {
			if (featureCall.isExplicitOperationCall())
				acceptor.accept(memberFeatureCallElements.getExplicitOperationCallLeftParenthesisKeyword_1_2_2_0_0());
			List<XExpression> arguments = featureCall.getMemberCallArguments();
			if (!arguments.isEmpty()) {
				int diff = 0;
				if (featureCall.isExplicitOperationCall()) {
					if (arguments.size() - diff > 0)
						acceptor.accept(memberFeatureCallElements.getMemberCallArgumentsXExpressionParserRuleCall_1_1_2_1_0_0(), arguments.get(0), 0);
					for (int i = 1; i < arguments.size() - diff; i++)
						acceptor.accept(memberFeatureCallElements.getMemberCallArgumentsXExpressionParserRuleCall_1_1_2_1_1_1_0(), arguments.get(i), i);
				}
			}
		}
		acceptor.finish();
	}

}
