/**
 * This work is licensed under a Creative Commons Attribution 3.0 Unported License
 * 
 * Read the full license here:
 * http://creativecommons.org/licenses/by/3.0/
 * 
 * Author:  Sebastiaan Holtrop
 * Blog:    http://www.sebastiaanholtrop.com
 */
package com.sebastiaanholtrop.components.coverflow.shape {
	
	import away3d.containers.View3D;
	import away3d.core.base.Face;
	import away3d.core.base.Mesh;
	import away3d.core.base.Object3D;
	import away3d.core.base.UV;
	import away3d.core.base.Vertex;
	import away3d.events.MouseEvent3D;
	import away3d.materials.BitmapMaterial;
	import away3d.materials.ColorMaterial;
	
	import com.sebastiaanholtrop.components.coverflow.SebCoverFlow;
	import com.sebastiaanholtrop.components.coverflow.event.CoverFlowEvent;
	import com.sebastiaanholtrop.reflection.BitmapReflect;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import mx.controls.Image;
	
	/**
	 * Dispatched when this cover is clicked. This is an internal event to tell 
	 * the coverFlow it has to animate the clicked cover
	 */
	[Event(name="coverClicked", type="com.sebastiaanholtrop.components.coverflow.event.CoverFlowEvent")]
	
	/**
	 * A board shaped geometry
	 * @author Sebastiaan Holtrop
	 */
	public class CoverBoard extends Cover implements ICoverShape {
		
		private var _coverFlow:SebCoverFlow;
		private var _view3D:View3D;
		private var _data:Object;
		private var _image:Image;
		private var _shape:Mesh;
		private var _width:Number;
		private var _height:Number;
		private var _depth:Number;
		private var _scheduleForRemoval:Boolean = false;
		
		/**
		 * Constructor.
		 */
		public function CoverBoard() {
			
		}
		
		/**
		 * The init method for this cover. This method loads the image from the url
		 * which is set in the data property.
		 * @param coverFlow the coverFlow which contains this cover
		 * @param view3D the away3d scene
		 * @param data the data object from the arrayCollection which was set
		 * as the dataProvider for the coverFlow
		 */
		public function init(coverFlow:SebCoverFlow, view3D:View3D, data:Object):void {
			
			// Initialisation of private variables
			_coverFlow = coverFlow;
			_view3D = view3D;
			_data = data;
			
			// use an image to render the Cover
			_image = new Image();
			_image.addEventListener(Event.COMPLETE, this.completeHandler);
			_image.addEventListener(IOErrorEvent.IO_ERROR, this.ioErrorHandler);
			_image.load(data.source);
		}
		
		/**
		 * This getter returns the away3d Object3D geomytry.
		 * @return Object3D
		 */
		public function get shape():Object3D {
			return _shape;
		}
		
		/**
		 * @private
		 * @param event
		 */		
		private function completeHandler(event:Event):void {
			
			var coverBitmap:Bitmap = event.currentTarget.content as Bitmap;
			var coverSprite:Sprite = event.currentTarget as Sprite;
			
			_width = coverBitmap.width;
			_height = coverBitmap.height;
			_depth = 50;
			
			// Create a bitmapdata with transparency for the cover and the reflection
			var coverBitmapData:BitmapData = new BitmapData(_width, _height, true, 0xff);
			coverBitmapData.draw(coverBitmap);
			
			// Create the Materials
			var material:BitmapMaterial = new BitmapMaterial(coverBitmapData, {smooth:true, debug:false});
			var colorMaterial:ColorMaterial = new ColorMaterial(0xFFFFFF, {alpha:0.2});
			
			_shape = new Mesh();
			
			var uva:UV = new UV(1, 1);
			var uvb:UV = new UV(0, 1);
			var uvc:UV = new UV(0, 0);
			var uvd:UV = new UV(1, 0);
			
			//create the cube
			var v000c:Vertex = new Vertex(-_width/2, 0, 		-_depth/2);
			var v001c:Vertex = new Vertex(-_width/2, 0, 		+_depth/2);
			var v010c:Vertex = new Vertex(-_width/2, +_height, -_depth/2);
			var v011c:Vertex = new Vertex(-_width/2, +_height, +_depth/2);
			var v100c:Vertex = new Vertex(+_width/2, 0, 		-_depth/2);
			var v101c:Vertex = new Vertex(+_width/2, 0, 		+_depth/2);
			var v110c:Vertex = new Vertex(+_width/2, +_height, -_depth/2);
			var v111c:Vertex = new Vertex(+_width/2, +_height, +_depth/2);
			
			//left face
			_shape.addFace(new Face(v000c, v010c, v001c, colorMaterial, uvd, uva, uvc));
			_shape.addFace(new Face(v010c, v011c, v001c, colorMaterial, uva, uvb, uvc));
			
			//right face
			_shape.addFace(new Face(v100c, v101c, v110c, colorMaterial, uvc, uvd, uvb));
			_shape.addFace(new Face(v110c, v101c, v111c, colorMaterial, uvb, uvd, uva));
			
			//bottom face
			_shape.addFace(new Face(v000c, v001c, v100c, colorMaterial, uvb, uvc, uva));
			_shape.addFace(new Face(v001c, v101c, v100c, colorMaterial, uvc, uvd, uva));
			
			//top face
			_shape.addFace(new Face(v010c, v110c, v011c, colorMaterial, uvc, uvd, uvb));
			_shape.addFace(new Face(v011c, v110c, v111c, colorMaterial, uvb, uvd, uva));
			
			//front face
			_shape.addFace(new Face(v000c, v100c, v010c, material, uvc, uvd, uvb));
			_shape.addFace(new Face(v100c, v110c, v010c, material, uvd, uva, uvb));
			
			//back face
			//_shape.addFace(new Face(v001c, v011c, v101c, rollOverMaterial, uvd, uva, uvc));
			//_shape.addFace(new Face(v101c, v011c, v111c, rollOverMaterial, uvc, uva, uvb));
			
			// Set the "registration point" at the center
			if (! _coverFlow.reflection) {
				_shape.movePivot(0, _height/2, 0);
			}
			
			// Add the mouse handlers
			_shape.addOnMouseDown(this.mouseDownHandler);
			
			if (!_scheduleForRemoval) {
				this.dispatchEvent(new CoverFlowEvent(CoverFlowEvent.CREATIONCOMPLETE));
			}
		}
		
		/**
		 * If in the time between the init method call and the complete handler the 
		 * dataProvider's been changed, this method's called to prevent the cover 
		 * from adding itself to the scene. 
		 */
		public function scheduleForRemoval():void {
			_scheduleForRemoval = true;
		}
		
		/**
		 * @private
		 * @param event
		 */		
		private function ioErrorHandler(event:IOErrorEvent):void {
			//throw new IOError(event.text);
		}
		
		/**
		 * 
		 * @param event
		 */		
		private function mouseDownHandler(event:Event):void {
			this.dispatchEvent(new CoverFlowEvent(CoverFlowEvent.COVERCLICKED));
		}
	}
}