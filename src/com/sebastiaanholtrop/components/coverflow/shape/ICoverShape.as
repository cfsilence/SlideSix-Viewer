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
	import away3d.core.base.Object3D;
	
	import com.sebastiaanholtrop.components.coverflow.SebCoverFlow;
	
	import flash.events.IEventDispatcher;
	
	/**
	 * The interface which enables the coverFlow to switch beteen shapes. Every cover
	 * must implement this interface.
	 * @author Sebastiaan Holtrop
	 */
	public interface ICoverShape extends IEventDispatcher {
		
		/**
		 * The init method for this cover. This method loads the image from the url
		 * which is set in the data property.
		 * @param coverFlow the coverFlow which contains this cover
		 * @param view3D the away3d scene
		 * @param data the data object from the arrayCollection which was set
		 * as the dataProvider for the coverFlow
		 */
		function init(coverFlow:SebCoverFlow, view3D:View3D, data:Object):void;
		
		/**
		 * This getter returns the away3d Object3D geomytry.
		 * @return Object3D
		 */
		function get shape():Object3D;
		
		/**
		 * The initial x position for when the coverFlow is displayed in the horizontal
		 * direction.
		 * @return Number
		 */
		function get initialX():Number;
		function set initialX(value:Number):void;
		
		/**
		 * The initial x position for when the coverFlow is displayed in the vertical
		 * direction.
		 * @return Number
		 */
		function get initialY():Number;
		function set initialY(value:Number):void;
		
		/**
		 * If in the time between the init method call and the complete handler the 
		 * dataProvider's been changed, this method's called to prevent the cover 
		 * from adding itself to the scene. 
		 */
		function scheduleForRemoval():void;
	}
}