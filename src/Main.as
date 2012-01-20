package  
{
	import cepa.utils.ToolTip;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import org.papervision3d.core.geom.Lines3D;
	import org.papervision3d.core.geom.renderables.Line3D;
	import org.papervision3d.core.geom.renderables.Vertex3D;
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.core.proto.MaterialObject3D;
	import org.papervision3d.events.FileLoadEvent;
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.materials.shadematerials.CellMaterial;
	import org.papervision3d.materials.shadematerials.FlatShadeMaterial;
	import org.papervision3d.materials.shadematerials.GouraudMaterial;
	import org.papervision3d.materials.shadematerials.PhongMaterial;
	import org.papervision3d.materials.special.Letter3DMaterial;
	import org.papervision3d.materials.special.LineMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.parsers.DAE;
	import org.papervision3d.objects.primitives.PaperPlane;
	import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.objects.primitives.Sphere;
	import org.papervision3d.typography.Font3D;
	import org.papervision3d.typography.fonts.HelveticaBold;
	import org.papervision3d.typography.Text3D;
	import org.papervision3d.view.BasicView;
	import org.papervision3d.view.layer.ViewportLayer;
	/**
	 * ...
	 * @author Alexandre
	 */
	public class Main extends BasicView
	{
		/**
		 * Eixos x, y e z.
		 */
		private var eixos:CartesianAxis3D;
		
		/**
		 * Posição do click na tela.
		 */
		private var clickPoint:Point = new Point();
		
		private var planeX:Plane;
		private var planeY:Plane;
		private var planeZ:Plane;
		private var lines:Lines3D;
		private var intersecao:Sphere;
		private var interLetter:Text3D;
		private var containerP:DisplayObject3D;
		
		public var distance:Number = 100; 
		private var upVector:Number3D = new Number3D(0, 0, 1);
		
		private var balao:CaixaTexto;
		
		public function Main() 
		{
			super(650, 500, false, true);
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
			
			startRendering();
		}
		
		private function init(e:Event = null):void
		{
			this.scrollRect = new Rectangle(0, 0, 650, 500);
			stage.scaleMode = StageScaleMode.SHOW_ALL;
			
			eixos = new CartesianAxis3D();
			
			scene.addChild(eixos);
			
			camera.target = null;
			
			rotating(null);
			
			info.addEventListener(MouseEvent.CLICK, showInfo);
			instructions.addEventListener(MouseEvent.CLICK, showCC);
			btnInst.addEventListener(MouseEvent.CLICK, openInst);
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, initRotation);
			resetButton.addEventListener(MouseEvent.CLICK, resetCamera);
			
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, viewZoom);
			zoomIn.addEventListener(MouseEvent.CLICK, viewZoom);
			zoomOut.addEventListener(MouseEvent.CLICK, viewZoom);
			setChildIndex(zoomIn, numChildren - 1);
			setChildIndex(zoomOut, numChildren - 1);
			
			var infoTT:ToolTip = new ToolTip(info, "Informações", 12, 0.8, 100, 0.6, 0.6);
			var instTT:ToolTip = new ToolTip(instructions, "Instruções", 12, 0.8, 100, 0.6, 0.6);
			var resetTT:ToolTip = new ToolTip(resetButton, "Reiniciar", 12, 0.8, 100, 0.6, 0.6);
			
			addChild(infoTT);
			addChild(instTT);
			addChild(resetTT);
			
			setChildIndex(xis, numChildren - 1);
			setChildIndex(ypsolon, numChildren - 1);
			setChildIndex(ze, numChildren - 1);
			
			adicionaListenerCampos();
			
			initCampos();
			
			lookAtP();
			
			balao = new CaixaTexto();
			addChild(balao);
			balao.visible = false;
		}
		
		private function openInst(e:MouseEvent):void 
		{
			instScreen.openScreen();
			setChildIndex(instScreen, numChildren - 1);
		}
		
		private function showInfo(e:MouseEvent):void 
		{
			aboutScreen.openScreen();
			setChildIndex(aboutScreen, numChildren - 1);
		}
		
		private function showCC(e:MouseEvent):void 
		{
			infoScreen.openScreen();
			setChildIndex(infoScreen, numChildren - 1);
		}
		
		private var zoom:Number = 40;
		private function viewZoom(e:MouseEvent):void
		{
			if(e.type == MouseEvent.MOUSE_WHEEL){
				if(e.delta > 0)
				{
					if(zoom < 120) zoom +=  5;
				}
				if(e.delta < 0)
				{
					if (zoom > 40) zoom -=  5;
				}
			}else {
				if (e.target is ZoomIn) {
					if(zoom < 120) zoom +=  5;
				}else {
					if (zoom > 40) zoom -=  5;
				}
			}
			this.camera.zoom = zoom;
		}
		
		private function initCampos():void
		{
			xis.text = "25";
			ypsolon.text = "25";
			ze.text = "25";
			
			drawPlane("x", 25);
			drawPlane("y", 25);
			drawPlane("z", 25);
			
			lookAtP();
		}
		
		private function adicionaListenerCampos():void
		{
			xis.addEventListener(KeyboardEvent.KEY_UP, changeHandler);
			ypsolon.addEventListener(KeyboardEvent.KEY_UP, changeHandler);
			ze.addEventListener(KeyboardEvent.KEY_UP, changeHandler);
			
			xis.addEventListener(FocusEvent.FOCUS_OUT, changeHandler);
			ypsolon.addEventListener(FocusEvent.FOCUS_OUT, changeHandler);
			ze.addEventListener(FocusEvent.FOCUS_OUT, changeHandler);
			
		}
		
		private function changeHandler(e:Event):void 
		{
			if(e is KeyboardEvent){
				if(KeyboardEvent(e).keyCode == Keyboard.ENTER){
					changePlanes(e.target.name);
				}
			}else {
				changePlanes(e.target.name);
			}
		}
		
		private function changePlanes(name:String):void
		{
			switch(name)
			{
				case "xis":
					if (Number(xis.text) > eixos.maxDist) xis.text = String(eixos.maxDist);
					if (Number(xis.text) < 0) xis.text = "0";
					if (xis.text == "") removePlane("x");
					else drawPlane("x", Number(xis.text));
					break;
				case "ypsolon":
					if (Number(ypsolon.text) > eixos.maxDist) ypsolon.text = String(eixos.maxDist);
					if (Number(ypsolon.text) < 0) ypsolon.text = "0";
					if (ypsolon.text == "") removePlane("y");
					else drawPlane("y", Number(ypsolon.text));
					break;
				case "ze":
					if (Number(ze.text) > eixos.maxDist) ze.text = String(eixos.maxDist);
					if (Number(ze.text) < 0) ze.text = "0";
					if (ze.text == "") removePlane("z");
					else drawPlane("z", Number(ze.text));
					break;
				
				default:
					return;
			}
			verifyNeedOfBallon(name);
		}
		
		private function verifyNeedOfBallon(name:String):void 
		{
			switch(name)
			{
				case "xis":
					if (xis.text == "") {
						if (ypsolon.text == "" && ze.text == "") { //todos nulos
							balao.setText("Com todos os parâmetros nulos não existem planos nem interseções.");
						}else if (ypsolon.text == "") {//x e y nulos
							balao.setText("Com dois parâmetros nulos existe apenas 1 plano sem interseções.");
						}else if (ze.text == "") {//x e z nulos
							balao.setText("Com dois parâmetros nulos existe apenas 1 plano sem interseções.");
						}else {//x nulo
							balao.setText("Com esse parâmetro nulo existem apenas 2 planos, sendo que a interseção entre eles forma uma reta.");
						}
						balao.x = xis.x + xis.width + 20;
						balao.y = xis.y;					
					}else {
						balao.visible = false;
					}
					break;
				case "ypsolon":
					if (ypsolon.text == "") {
						if (xis.text == "" && ze.text == "") { //todos nulos
							balao.setText("Com todos os parâmetros nulos não existem planos nem interseções.");
						}else if (xis.text == "") {//x e y nulos
							balao.setText("Com dois parâmetros nulos existe apenas 1 plano sem interseções.");
						}else if (ze.text == "") {//y e z nulos
							balao.setText("Com dois parâmetros nulos existe apenas 1 plano sem interseções.");
						}else {//y nulo
							balao.setText("Com esse parâmetro nulo existem apenas 2 planos, sendo que a interseção entre eles forma uma reta.");
						}
						balao.x = ypsolon.x + ypsolon.width + 20;
						balao.y = ypsolon.y;					
					}else {
						balao.visible = false;
					}
					break;
				case "ze":
					if (ze.text == "") {
						if (ypsolon.text == "" && xis.text == "") { //todos nulos
							balao.setText("Com todos os parâmetros nulos não existem planos nem interseções.");
						}else if (ypsolon.text == "") {//z e y nulos
							balao.setText("Com dois parâmetros nulos existe apenas 1 plano sem interseções.");
						}else if (xis.text == "") {//x e z nulos
							balao.setText("Com dois parâmetros nulos existe apenas 1 plano sem interseções.");
						}else {//z nulo
							balao.setText("Com esse parâmetro nulo existem apenas 2 planos, sendo que a interseção entre eles forma uma reta.");
						}
						balao.x = ze.x + ze.width + 20;
						balao.y = ze.y;					
					}else {
						balao.visible = false;
					}
					break;
				
				default:
					return;
			}
		}
		
		private function drawPlane(plano:String, coordenada:Number):void
		{
			var material:ColorMaterial;
			var portLayer:ViewportLayer;
			
			switch (plano)
			{
				case "x":
					if (planeX != null) 
					{
						scene.removeChild(planeX);
					}
					material = new ColorMaterial(0xFF0000, 0.25);
					
					planeX = new Plane(material, eixos.maxDist, eixos.maxDist, 10, 10);
					
					scene.addChild(planeX);
					
					//portLayer = viewport.getChildLayer(planeX);
					//portLayer.alpha = 0.5;
					
					planeX.x = coordenada;
					planeX.y = eixos.maxDist / 2;
					planeX.z = -eixos.maxDist / 2;
					planeX.localRotationY = 90;
					break;
				case "y":
					if (planeY != null) 
					{
						scene.removeChild(planeY);
					}
					material = new ColorMaterial(0x00FF00, 0.25);
					
					planeY = new Plane(material, eixos.maxDist, eixos.maxDist, 10, 10);
					
					scene.addChild(planeY);
					
					//portLayer = viewport.getChildLayer(planeY);
					//portLayer.alpha = 0.5;
					
					planeY.x = eixos.maxDist / 2;
					planeY.y = coordenada;
					planeY.z = -eixos.maxDist / 2;
					planeY.localRotationX = 90;
					break;
				case "z":
					if (planeZ != null) 
					{
						scene.removeChild(planeZ);
					}
					material = new ColorMaterial(0x0000FF, 0.25);
					
					planeZ = new Plane(material, eixos.maxDist, eixos.maxDist, 10, 10);
					
					scene.addChild(planeZ);
					
					//portLayer = viewport.getChildLayer(planeZ);
					//portLayer.alpha = 0.5;
					
					planeZ.x = eixos.maxDist / 2;
					planeZ.y = eixos.maxDist / 2;
					planeZ.z = -coordenada;
					break;
					
				default:
					return;
			}
			material.doubleSided = true;
			
			drawIntersections();
		}
		
		private function removePlane(plane:String):void
		{
			switch (plane)
			{
				case "x":
					if (planeX != null) 
					{
						scene.removeChild(planeX);
						planeX = null;
					}
					break;
				case "y":
					if (planeY != null) 
					{
						scene.removeChild(planeY);
						planeY = null;
					}
					break;
				case "z":
					if (planeZ != null) 
					{
						scene.removeChild(planeZ);
						planeZ = null;
					}
					break;
					
				default:
					return;
			}
			
			removePoint();
			drawIntersections();
		}
		
		private function removePoint():void
		{
			if(intersecao != null)
			{
				if (interLetter != null) 
				{
					containerP.removeChild(interLetter);
					intersecao.removeChild(containerP);
					interLetter = null;
					containerP = null;
				}
				
				scene.removeChild(intersecao);
				intersecao = null;
			}
		}
		
		private function drawIntersections():void
		{
			if (lines == null)
			{
				lines = new Lines3D();
				scene.addChild(lines);
				
				var portLayerLines:ViewportLayer = viewport.getChildLayer(lines);
				portLayerLines.forceDepth = true;
				portLayerLines.screenDepth = 1;
			}
			else lines.removeAllLines();
			
			var lineMaterial:LineMaterial = new LineMaterial(0x000000);
			
			var linhaXini:Vertex3D;
			var linhaXfim:Vertex3D;
			var linhaX:Line3D;
			
			var linhaYini:Vertex3D;
			var linhaYfim:Vertex3D;
			var linhaY:Line3D;
			
			var linhaZini:Vertex3D;
			var linhaZfim:Vertex3D;
			var linhaZ:Line3D;
			
			
			if (planeX != null && planeY != null && planeZ != null)
			{
				for (var i:int = 0; i < eixos.maxDist; i=i+2)
				{
					//X e Y
					linhaXini = new Vertex3D(Number(xis.text), Number(ypsolon.text), -i);
					linhaXfim = new Vertex3D(Number(xis.text), Number(ypsolon.text), -i-1);
					linhaX = new Line3D(lines, lineMaterial, 1, linhaXini, linhaXfim);
					lines.addLine(linhaX);
					
					//X e Z
					linhaYini = new Vertex3D(Number(xis.text), i, -Number(ze.text));
					linhaYfim = new Vertex3D(Number(xis.text), i+1, -Number(ze.text));
					linhaY = new Line3D(lines, lineMaterial, 1, linhaYini, linhaYfim);
					lines.addLine(linhaY);
					
					//Y e Z
					linhaZini = new Vertex3D(i, Number(ypsolon.text), -Number(ze.text));
					linhaZfim = new Vertex3D(i+1, Number(ypsolon.text), -Number(ze.text));
					linhaZ = new Line3D(lines, lineMaterial, 1, linhaZini, linhaZfim);
					lines.addLine(linhaZ);
				}
				
				var interMaterial:FlatShadeMaterial = new FlatShadeMaterial(null, 0x000000, 0x000000);
				
				if(intersecao == null)
				{
					intersecao = new Sphere(interMaterial, 0.5);
					scene.addChild(intersecao);
				}
				
				var portLayerInter:ViewportLayer = viewport.getChildLayer(intersecao);
				portLayerInter.forceDepth = true;
				portLayerInter.screenDepth = 1;
				
				intersecao.x = Number(xis.text);
				intersecao.y = Number(ypsolon.text);
				intersecao.z = -Number(ze.text);
				
				if (interLetter == null) 
				{
					var letterMaterial:Letter3DMaterial = new Letter3DMaterial(0x000000);
					letterMaterial.doubleSided = true;
					
					var fonte:Font3D = new HelveticaBold();
					
					var ponto:String = "P";
					
					interLetter = new Text3D(ponto, fonte, letterMaterial);
					
					containerP = new DisplayObject3D();
					
					containerP.addChild(interLetter);
					intersecao.addChild(containerP);
					containerP.scale = 0.02;
					containerP.x = 1.5;
					containerP.y = 1.5;
					containerP.z = 0;
					interLetter.rotationY = 180;
					
					lookAtP();
					
				}
				
			}
			else if (planeX != null && planeY != null)
			{
				for (i = 0; i < eixos.maxDist; i=i+2)
				{
					//X e Y
					linhaXini = new Vertex3D(Number(xis.text), Number(ypsolon.text), -i);
					linhaXfim = new Vertex3D(Number(xis.text), Number(ypsolon.text), -i-1);
					linhaX = new Line3D(lines, lineMaterial, 1, linhaXini, linhaXfim);
					lines.addLine(linhaX);
				}
			}
			else if (planeX != null && planeZ != null)
			{
				for (i = 0; i < eixos.maxDist; i=i+2)
				{
					//X e Z
					linhaYini = new Vertex3D(Number(xis.text), i, -Number(ze.text));
					linhaYfim = new Vertex3D(Number(xis.text), i+1, -Number(ze.text));
					linhaY = new Line3D(lines, lineMaterial, 1, linhaYini, linhaYfim);
					lines.addLine(linhaY);
				}
			}
			else if (planeY != null && planeZ != null)
			{
				for (i = 0; i < eixos.maxDist; i=i+2)
				{
					//Y e Z
					linhaZini = new Vertex3D(i, Number(ypsolon.text), -Number(ze.text));
					linhaZfim = new Vertex3D(i+1, Number(ypsolon.text), -Number(ze.text));
					linhaZ = new Line3D(lines, lineMaterial, 1, linhaZini, linhaZfim);
					lines.addLine(linhaZ);
				}
			}
			
		}
		
		private function lookAtP():void 
		{
			if(containerP != null) containerP.lookAt(camera, upVector);
			
			eixos.text3dX.lookAt(camera, upVector);
			eixos.text3dY.lookAt(camera, upVector);
			eixos.text3dZ.lookAt(camera, upVector);
			
			eixos.text10x.lookAt(camera, upVector);
			eixos.text10y.lookAt(camera, upVector);
			eixos.text10z.lookAt(camera, upVector);
		}
		
		public var theta2:Number = -2.4188; 
		public var phi2:Number = 10.4537;
		private function initRotation(e:MouseEvent):void 
		{
			if (e.target is TextField || e.target is CaixaTexto) return;
			//{
				clickPoint.x = stage.mouseX;
				clickPoint.y = stage.mouseY;
				stage.addEventListener(Event.ENTER_FRAME, rotating);
				stage.addEventListener(MouseEvent.MOUSE_UP, stopRotating);
			//}
		}
		
		private function rotating(e:Event):void 
		{
			if(e != null){
				var deltaTheta:Number = (stage.mouseX - clickPoint.x) * Math.PI / 180;
				var deltaPhi:Number = (stage.mouseY - clickPoint.y) * Math.PI / 180;
				
				theta2 += deltaTheta;
				phi2 += deltaPhi;
				
			
				clickPoint = new Point(stage.mouseX, stage.mouseY);
			}
			
			camera.x = distance * Math.cos(theta2) * Math.sin(phi2);
			camera.y = distance * Math.sin(theta2) * Math.sin(phi2);
			camera.z = distance * Math.cos(phi2);
			
			look();
			lookAtP();
		}
		
		private function stopRotating(e:MouseEvent):void 
		{
			stage.removeEventListener(Event.ENTER_FRAME, rotating);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopRotating);
			//trace(theta2, phi2);
		}
		
		public function look():void {
			if (Math.sin(phi2) < 0) upVector = new Number3D(0, 0, -1);
			else upVector = new Number3D(0, 0, 1);
			
			camera.lookAt(eixos, upVector);
		}
		
		private function resetCamera(e:MouseEvent):void
		{
			theta2 = -2.4188;
			phi2 = 10.4537;
			
			zoom = 40;
			this.camera.zoom = zoom;
			
			rotating(null);
			
			removePlane("x");
			removePlane("y");
			removePlane("z");
			
			initCampos();
			balao.visible = false;
		}
		
	}
}