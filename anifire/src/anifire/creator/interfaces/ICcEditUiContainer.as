package anifire.creator.interfaces
{
	import anifire.creator.components.BodyShapeChooser;
	import anifire.creator.components.CcColorPickers;
	import anifire.creator.components.CcComponentPropertyInspectorSpark;
	import anifire.creator.components.CharPreviewer;
	import anifire.creator.components.ClothesChooser;
	import anifire.creator.components.ComponentThumbChooserSpark;
	import anifire.creator.components.DecorationPanel;
	import anifire.creator.components.ScaleChooserSpark;
	import anifire.creator.components.TopButtons;
	import anifire.creator.components.TypeChooserSpark;
	import spark.components.Group;

	public interface ICcEditUiContainer
	{
		function get eui_componentTypeChooser() : TypeChooserSpark;
		function get eui_charPreviewer() : CharPreviewer;
		function get eui_colorPicker() : CcColorPickers;
		function get eui_buttonBar() : TopButtons;
		function get eui_componentChooserViewStack() : Group;
		function get eui_componentThumbChooser() : ComponentThumbChooserSpark;
		function get eui_thumbPropertyInspector() : CcComponentPropertyInspectorSpark;
		function get eui_selectedDecoration() : DecorationPanel;
		function get eui_mainViewStack() : Group;
		function get eui_mainEditorComponentsContainer() : Group;
		function get eui_clothesChooser() : ClothesChooser;
		function get eui_charScaleChooser() : ScaleChooserSpark;
	}
}
