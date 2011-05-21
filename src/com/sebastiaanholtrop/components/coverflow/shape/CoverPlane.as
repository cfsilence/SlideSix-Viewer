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
	import away3d.core.base.Face;
	import away3d.core.base.Mesh;
	import away3d.core.base.Object3D;
	import away3d.core.base.UV;
	import away3d.core.base.Vertex;
	import flash.events.MouseEvent;
	import mx.controls.ToolTip;
	import mx.utils.ObjectUtil;
	
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
	import away3d.core.base.Object3D;
	import flash.filters.BitmapFilterType;
	import away3d.core.base.Mesh;
	import away3d.primitives.Plane;
	import mx.core.Application;
	
	/**
	 * Dispatched when this cover is clicked. This is an internal event to tell 
	 * the coverFlow it has to animate the clicked cover
	 */
	[Event(name="coverClicked", type="com.sebastiaanholtrop.components.coverflow.event.CoverFlowEvent")]
	
	/**
	 * A plane shaped geometry
	 * @author Sebastiaan Holtrop
	 */
	public class CoverPlane extends Cover implements ICoverShape {
		
		private var _coverFlow:SebCoverFlow;
		private var _view3D:View3D;
		private var _data:Object;
		private var _image:Image;
		private var _shape:Mesh;
		private var _width:Number;
		private var _height:Number;
		private var _scheduleForRemoval:Boolean = false;
		/**
		 * Constructor.
		 */
		public function CoverPlane() {
			
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
			
			_coverFlow = coverFlow;
			_view3D = view3D;
			_data = data;
			
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
			
			
			_shape = new Mesh();
			
			var coverBitmapData:BitmapData = new BitmapData(_width, _height, true, 0xff);
			coverBitmapData.draw(coverBitmap);
			
			
			var coverMaterial:BitmapMaterial = new BitmapMaterial(coverBitmapData, {smooth:true, debug:false});
			
			
			var uva:UV = new UV(1, 1);
			var uvb:UV = new UV(0, 1);
			var uvc:UV = new UV(0, 0);
			var uvd:UV = new UV(1, 0);
			
			//create the cover plane
			var v000a:Vertex = new Vertex(-_width/2, 0,			0);
			var v010a:Vertex = new Vertex(-_width/2, +_height,	0);
			var v100a:Vertex = new Vertex(+_width/2, 0,			0);
			var v110a:Vertex = new Vertex(+_width/2, +_height,	0);
			
			_shape.addFace(new Face(v000a, v100a, v010a, coverMaterial, uvc, uvd, uvb));
			_shape.addFace(new Face(v100a, v110a, v010a, coverMaterial, uvd, uva, uvb));
			
			
			if (_coverFlow.reflection) {
				
				var reflection:BitmapReflect = new BitmapReflect(coverBitmap, 0.4, 100);
				var reflectionSprite:Sprite = reflection.reflectionAsSprite;
				var reflectionBitmapData:BitmapData = new BitmapData(_width, _height, true, 0xff);
				
				var flipMatrix:Matrix = new Matrix();
				flipMatrix.scale(1, -1);
				flipMatrix.translate(0, _height);
				reflectionBitmapData.draw(reflectionSprite, flipMatrix);
				
				var reflectionMaterial:BitmapMaterial = new BitmapMaterial(reflectionBitmapData, {smooth:true, debug:false});
				
				var v000b:Vertex = new Vertex(-_width/2, 0,			0);
				var v010b:Vertex = new Vertex(-_width/2, -_height,	0);
				var v100b:Vertex = new Vertex(+_width/2, 0,			0);
				var v110b:Vertex = new Vertex(+_width/2, -_height,	0);
				
				
				_shape.addFace(new Face(v100b,v000b,  v010b, reflectionMaterial,  uvd,uvc, uvb));
				_shape.addFace(new Face( v110b,v100b, v010b, reflectionMaterial,  uva,uvd, uvb));
				
			}
			else {
				
				// Set the "registration point" at the center
				_shape.movePivot(0, _height/2, 0);
			}
			
			_shape.bothsides = _coverFlow.bothsides;
			
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