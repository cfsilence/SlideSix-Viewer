/**
 * This work is licensed under a Creative Commons Attribution 3.0 Unported License
 * 
 * Read the full license here:
 * http://creativecommons.org/licenses/by/3.0/
 * 
 * Author:  Sebastiaan Holtrop
 * Blog:    http://www.sebastiaanholtrop.com
 */
package com.sebastiaanholtrop.reflection {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	import flash.events.EventDispatcher;
	import flash.utils.describeType;
	import mx.core.IContainer;
	import mx.core.Container;
	import mx.core.UIComponent;
	
	/**
	 * A class to create iTunes-like reflections. A reflection source needs to be a Bitmap.
	 * The reflection can be retrieved as a BitmapData or as a Sprite.
	 * @author Sebastiaan Holtrop
	 */	
	public class BitmapReflect extends EventDispatcher {
		
		private var _sourceBitmap:Bitmap;
		private var _reflectionBmd:BitmapData;
		private var _gradientBmd:BitmapData;
		private var _updateTimer:Timer;
		
		private var _alpha:Number;
		private var _ratio:Number;
		private var _distance:Number;
		
		/**
		 * Constructor
		 * @param sourceBitmap the bitmap to be reflected
		 * @param alpha 
		 * @param ratio
		 * @param distance
		 * @return void
		 */
		public function BitmapReflect(sourceBitmap:Bitmap, alpha:Number = 0.5, ratio:Number = 50, distance:Number = 0) {
			
			this._sourceBitmap = sourceBitmap;
			
			this._alpha = alpha;
			this._ratio = ratio;
			this._distance = distance;
			
			this.redraw();
		}
		
		/**
		 * @private
		 */
		private function bitmapToFlippedBitmapData():void {
			
			this._reflectionBmd = new BitmapData(this._sourceBitmap.width, this._sourceBitmap.height, true, 0xFFFFFF);
			
			var flipMatrix:Matrix = new Matrix();
			flipMatrix.scale(1, -1);
			flipMatrix.translate(0, this._sourceBitmap.height);
			
			this._reflectionBmd.draw(this._sourceBitmap, flipMatrix);
		}
		
		/**
		 * @private
		 */
		private function createGradientBitmapData():void {
			
			var gradientSprite:Sprite = new Sprite();
			
			var colors:Array = [0xFFFFFF, 0xFFFFFF];
		 	var alphas:Array = [this.alpha, 0];
		  	var ratios:Array = [0, this.ratio];
			var rotation:Number = 0.5;
			
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(_sourceBitmap.width, _sourceBitmap.height, rotation * Math.PI, 0, 0);
			
			gradientSprite.graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, matrix, SpreadMethod.PAD);
		    gradientSprite.graphics.drawRect(0, 0, _sourceBitmap.width, _sourceBitmap.height);
			
			_gradientBmd = new BitmapData(_sourceBitmap.width, _sourceBitmap.height, true, 0xFFFFFF);
			_gradientBmd.draw(gradientSprite);
		}
		
		/**
		 * Returns the sourceBitmap as a BitmapData
		 * @return BitmapData
		 * 
		 */		
		public function get reflectionAsBitmapData():BitmapData {
			return _reflectionBmd;
		}
		
		/**
		 * Returns the sourceBitmap as a Sprite
		 * @return Sprite
		 * 
		 */		
		public function get reflectionAsSprite():Sprite {
			var reflectionBm:Bitmap = new Bitmap(this._reflectionBmd);
			var reflectionSprite:Sprite = new Sprite();
			reflectionSprite.addChild(reflectionBm);
			return reflectionSprite;
		}
		
		/**
		 * 
		 * @private
		 * 
		 */		
		protected function set sourceBitmap(sourceBitmap:Bitmap):void {
			this._sourceBitmap = sourceBitmap;
		}
		public function get sourceBitmap():Bitmap {
			return _sourceBitmap;
		}
		
		/**
		 * @param alpha
		 */		
		public function set alpha(alpha:Number):void {
			this._alpha = alpha;
			this.redraw();
		}
		public function get alpha():Number {
			return this._alpha;
		}
		
		/**
		 * @param ratio
		 */		
		public function set ratio(ratio:Number):void {
			this._ratio = ratio;
			this.redraw();
		}
		public function get ratio():Number {
			return _ratio;
		}
		
		/**
		 * @param distance
		 */		
		public function set distance(distance:Number):void {
			_distance = distance;
		}
		public function get distance():Number {
			return _distance;
		}
		
		/**
		 * To enforce a redraw of the reflection
		 */		
		public function redraw():void {
			
			this.bitmapToFlippedBitmapData();
			this.createGradientBitmapData();
			
			_reflectionBmd.copyChannel(this._gradientBmd, new Rectangle(0, 0, _sourceBitmap.width, _sourceBitmap.height), new Point(0, 0), 8, 8);
		}
	}
}