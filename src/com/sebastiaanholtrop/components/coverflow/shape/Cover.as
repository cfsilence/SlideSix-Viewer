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
	
	import flash.events.EventDispatcher;
	
	/**
	 * The superclass of all Cover shapes. Every cover must extend this class. This
	 * is an abstract class and it should not be instantiated directly.
	 * @author Sebastiaan Holtrop
	 */
	public class Cover extends EventDispatcher {
		
		private var _initialX:Number;
		private var _initialY:Number;
		
		/**
		 * The initial x position for when the coverFlow is displayed in the horizontal
		 * direction.
		 * @return Number
		 */
		public function get initialX():Number {
			return _initialX;
		}
		public function set initialX(value:Number):void {
			_initialX = value;
		}
		
		/**
		 * The initial x position for when the coverFlow is displayed in the vertical
		 * direction.
		 * @return Number
		 */
		public function get initialY():Number {
			return _initialY;
		}
		public function set initialY(value:Number):void {
			_initialY = value;
		}
	}
}