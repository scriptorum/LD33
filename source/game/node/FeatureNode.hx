package game.node;

import ash.core.Node;
import game.component.Feature;
import flaxen.component.Position;

class FeatureNode extends Node<FeatureNode>
{
	public var feature:Feature;
	public var position:Position;
}