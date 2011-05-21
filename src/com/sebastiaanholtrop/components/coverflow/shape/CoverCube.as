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
	import away3d.materials.BitmapMaterial;
	import away3d.primitives.Plane;
	
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
	import away3d.core.base.Mesh;
	import away3d.core.base.Object3D;
	import away3d.core.base.Vertex;
	import away3d.core.base.UV;
	import away3d.core.base.Face;
	
	/**
	 * A cube shaped geometry
	 * @author Sebastiaan Holtrop
	 */
	public class CoverCube extends Cover implements ICoverShape {
		
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
		public function CoverCube() {
			
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
			_depth = coverBitmap.width;
			
			// Create a bitmapdata with transparency for the cover and the reflection
			var coverBitmapData:BitmapData = new BitmapData(_width, _height, true, 0xff);
			coverBitmapData.draw(coverBitmap);
			
			// Create the reflection
			var reflection:BitmapReflect = new BitmapReflect(coverBitmap, 0.4, 100);
			var reflectionBitmapData:BitmapData = reflection.reflectionAsBitmapData;
			
			// Copy the reflection bitmapdata into the coverBitmapData
			coverBitmapData.copyPixels(reflectionBitmapData, reflectionBitmapData.rect, new Point(0, _height));
			
			// Create the Material to use for the Plane
			var material:BitmapMaterial = new BitmapMaterial(coverBitmapData, {smooth:true, debug:false});
			
			var reflectionMaterial:BitmapMaterial;
			if (_coverFlow.reflection) {
				reflectionMaterial = new BitmapMaterial(reflectionBitmapData, {smooth:true, debug:false});
			}
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
			_shape.addFace(new Face(v000c, v010c, v001c, material, uvd, uva, uvc));
			_shape.addFace(new Face(v010c, v011c, v001c, material, uva, uvb, uvc));
			
			//right face
			_shape.addFace(new Face(v100c, v101c, v110c, material, uvc, uvd, uvb));
			_shape.addFace(new Face(v110c, v101c, v111c, material, uvb, uvd, uva));
			
			//bottom face
			if (! _coverFlow.reflection) {
				_shape.addFace(new Face(v000c, v001c, v100c, material, uvb, uvc, uva));
				_shape.addFace(new Face(v001c, v101c, v100c, material, uvc, uvd, uva));
			}
			
			//top face
			_shape.addFace(new Face(v010c, v110c, v011c, material, uvc, uvd, uvb));
			_shape.addFace(new Face(v011c, v110c, v111c, material, uvb, uvd, uva));
			
			//front face
			_shape.addFace(new Face(v000c, v100c, v010c, material, uvc, uvd, uvb));
			_shape.addFace(new Face(v100c, v110c, v010c, material, uvd, uva, uvb));
			
			//back face
			_shape.addFace(new Face(v001c, v011c, v101c, material, uvd, uva, uvc));
			_shape.addFace(new Face(v101c, v011c, v111c, material, uvc, uva, uvb));
			
			if (_coverFlow.reflection) {
				//create the reflection
				var v000r:Vertex = new Vertex(-_width/2, -_height, -_depth/2);
				var v001r:Vertex = new Vertex(-_width/2, -_height, +_depth/2);
				var v010r:Vertex = new Vertex(-_width/2, 0, 		-_depth/2);
				var v011r:Vertex = new Vertex(-_width/2, 0, 		+_depth/2);
				var v100r:Vertex = new Vertex(+_width/2, -_height, -_depth/2);
				var v101r:Vertex = new Vertex(+_width/2, -_height, +_depth/2);
				var v110r:Vertex = new Vertex(+_width/2, 0, 		-_depth/2);
				var v111r:Vertex = new Vertex(+_width/2, 0, 		+_depth/2);
				
				//left face
				_shape.addFace(new Face(v000r, v010r, v001r, reflectionMaterial, uvd, uva, uvc));
				_shape.addFace(new Face(v010r, v011r, v001r, reflectionMaterial, uva, uvb, uvc));
				//right face
				_shape.addFace(new Face(v100r, v101r, v110r, reflectionMaterial, uvc, uvd, uvb));
				_shape.addFace(new Face(v110r, v101r, v111r, reflectionMaterial, uvb, uvd, uva));
				//bottom face
				//addFace(new Face(v000, v001, v100, bottom, uvb, uvc, uva));
				//addFace(new Face(v001, v101, v100, bottom, uvc, uvd, uva));
				//top face
				_shape.addFace(new Face(v010r, v110r, v011r, reflectionMaterial, uvc, uvd, uvb));
				_shape.addFace(new Face(v011r, v110r, v111r, reflectionMaterial, uvb, uvd, uva));
				//front face
				_shape.addFace(new Face(v000r, v100r, v010r, reflectionMaterial, uvc, uvd, uvb));
				_shape.addFace(new Face(v100r, v110r, v010r, reflectionMaterial, uvd, uva, uvb));
				//back face
				_shape.addFace(new Face(v001r, v011r, v101r, reflectionMaterial, uvd, uva, uvc));
				_shape.addFace(new Face(v101r, v011r, v111r, reflectionMaterial, uvc, uva, uvb));
			}
			
			// Set the "registration point" at the center
			if (! _coverFlow.reflection) {
				_shape.movePivot(0, _height/2, 0);
			}
			
			// Add the mouse click handler
			_shape.addOnMouseDown(this.mouseDownHandler);
			
			if (!_scheduleForRemoval) {
				this.dispatchEvent(new CoverFlowEvent(CoverFlowEvent.CREATIONCOMPLETE));
			}
		}
		
		private function ioErrorHandler(event:IOErrorEvent):void {
			//throw new IOError(event.text);
		}
		
		private function mouseDownHandler(event:Event):void {
			this.dispatchEvent(new CoverFlowEvent(CoverFlowEvent.COVERCLICKED));
		}
		
		/**
		 * If in the time between the init method call and the complete handler the 
		 * dataProvider's been changed, this method's called to prevent the cover 
		 * from adding itself to the scene. 
		 */
		public function scheduleForRemoval():void {
			_scheduleForRemoval = true;
		}
	}
}