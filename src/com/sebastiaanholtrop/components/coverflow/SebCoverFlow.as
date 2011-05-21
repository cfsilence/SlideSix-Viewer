/**
 * This work is licensed under a Creative Commons Attribution 3.0 Unported License
 * 
 * Read the full license here:
 * http://creativecommons.org/licenses/by/3.0/
 * 
 * Author:  Sebastiaan Holtrop
 * Blog:    http://www.sebastiaanholtrop.com
 * Date:    27 november 2008
 * Version: 2.2.0
 */
package com.sebastiaanholtrop.components.coverflow {
	
	import away3d.containers.View3D;
	import away3d.core.base.Object3D;
	import away3d.core.clip.RectangleClipping;
	import away3d.core.math.Number3D;
	import away3d.materials.WireframeMaterial;
	import away3d.primitives.Plane;
	import away3d.primitives.WirePlane;
	import com.sebastiaanholtrop.components.coverflow.shape.Cover;
	import flash.display.DisplayObject;
	import mx.controls.Alert;
	import mx.controls.Text;
	import mx.events.ListEvent;
	import mx.utils.ObjectUtil;
	
	import caurina.transitions.Tweener;
	
	import com.sebastiaanholtrop.components.coverflow.event.CoverFlowEvent;
	import com.sebastiaanholtrop.components.coverflow.shape.CoverBoard;
	import com.sebastiaanholtrop.components.coverflow.shape.CoverCube;
	import com.sebastiaanholtrop.components.coverflow.shape.CoverPlane;
	import com.sebastiaanholtrop.components.coverflow.shape.ICoverShape;
	import com.sebastiaanholtrop.utils.ArrayCollectionUtils;
	
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	import mx.core.UIComponent;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.events.PropertyChangeEvent;
	import mx.managers.HistoryManager;
	import mx.managers.IFocusManagerComponent;
	import mx.managers.IHistoryManagerClient;
	
	/**
	 * Dispatched when the selectedIndex property changes
	 */
	[Event(name="change", type="flash.events.Event")]
	/**
	 * Dispatched when the coverFlow is finished animating. If the selectedIndex is changed while animating
	 * this event will still only be dispached after the animation has finished
	 */
	[Event(name="animationComplete", type="flash.events.Event")]
	/**
	 * Once a cover has been selected and the coverFlow has finished animating and you click the cover this
	 * event will be dispached
	 */	
	[Event(name = "selectedCoverClicked", type = "flash.events.Event")]
	[Event(name = "selectedCoverMousedOver", type = "flash.events.Event")]
	/**
	 * If you set the dataProvider with a prefilled ArrayCollection, this event will be dispached after 
	 * the coverFlow has loaded all of the images and had created all of the covers
	 */
	[Event(name="coverInitComplete", type="flash.events.Event")]
	
	/**
	 * @author Sebastiaan Holtrop
	 * @mxml 
	 * <pre>
	 * 	&lt;seb:SebCoverFlow 
	 * 		id="" 
	 * 		reflection="true | false" 
	 *		bothsides="true | false" 
	 * 		shape="planeshape | cubeshape | boardshape" 
	 * 		direction="horizontaldirection | verticaldirection" 
	 * 		dataProvider="<i>No default</i>" 
	 * 		
	 * 		<b>Gaps angles and distances</b>
	 * 		itemGap="120"
	 * 		selectedItemGap="120"
	 * 		flippoint="120" 
	 * 		flipAngle="-80" 
	 * 		rotationAngle="0" 
	 * 		selectedItemZoom="-200" 
	 * 		
	 * 		<b>Camera</b>
	 * 		cameraOffsetX="0" 
	 * 		cameraOffsetY="0" 
	 * 		cameraOffsetZ="-1133"
	 * 	
	 * 		<b>Events</b>
	 * 		change="<i>No default</i>" 
	 * 		animationComplete="<i>No default</i>" 
	 * 		selectedCoverClicked="<i>No default</i>"  /&gt;
	 */
	public class SebCoverFlow extends UIComponent implements IFocusManagerComponent, IHistoryManagerClient {
		
		private var _enableHistory:Boolean;
		private var _selectedIndex:int;
		private var _dataProvider:ArrayCollection;
		private var _itemsDirty:Boolean;
		
		private var _mask:Sprite;
		private var _viewContainer:UIComponent;
		private var _view3D:View3D;
		private var _children:ArrayCollection;
		private var _pointOfInterest:Number3D;
		
		private var _itemGap:Number = 120;
		private var _selectedItemGap:Number = 120;
		private var _flippoint:Number = 120;
		private var _flipAngle:Number = -90;
		private var _rotationAngle:Number = 0;
		
		private var _shape:String = "planeshape";
		private var _direction:String = "horizontaldirection";
		private var _reflection:Boolean = true;
		private var _bothsides:Boolean = false;
		private var _selectedItemZoom:Number = -200;
		private var _cameraOffsetX:Number = 0;
		private var _cameraOffsetY:Number = 0;
		private var _cameraOffsetZ:Number = -1133;
		
		private var _state:String = "init";
		
		public static const PLANESHAPE:String = "planeshape";
		public static const CUBESHAPE:String = "cubeshape";
		public static const BOARDSHAPE:String = "boardshape";
		
		public static const VERTICALDIRECTION:String = "verticaldirection";
		public static const HORIZONTALDIRECTION:String = "horizontaldirection";
		
		public static const VERSION:String = "2.2.0";
		
		/**
		 * Constructor.
		 */
		public function SebCoverFlow():void {
			
			// Initialisation of private variables
			_view3D = new View3D();
			_viewContainer = new UIComponent();
			_children = new ArrayCollection();
			_pointOfInterest = new Number3D();
			_dataProvider = new ArrayCollection();
			_selectedIndex = -1;
			
			// Put the camera in place, see:
			// http://www.sebastiaanholtrop.com/archives/13
			_view3D.camera.z = _cameraOffsetZ;
			_view3D.camera.lookAt(_pointOfInterest);
			
			// add the container as a child to this
			this.addChild(_viewContainer);
			
			// add the view3D as a child to the viewContainer
			this._viewContainer.addChild(_view3D);
			
			// add a wireplane, so we can see what's going on
			//var wireplane:WirePlane = new WirePlane({material:new WireframeMaterial(), width:4000, height:4000, segments:10, x:0 , y:0, z: 0});
			//_view3D.scene.addChild(wireplane);
			
			this.addEventListener(MouseEvent.MOUSE_WHEEL, _mouseWheelEventHandler);
			this.addEventListener(Event.ADDED_TO_STAGE, _addedToStageEventHandler);
		}
		
		
		/**
		 * @private
		 * @param data
		 * @param location
		 */
		private function _addCover(data:Object, location:int):void {
			
			var cover:ICoverShape;
			
			switch (_shape) {
				case SebCoverFlow.PLANESHAPE:
					cover = new CoverPlane();
				break;
				case SebCoverFlow.CUBESHAPE:
					cover = new CoverCube();
				break;
				case SebCoverFlow.BOARDSHAPE:
					cover = new CoverBoard();
				break;
			}
			
			cover.init(this, _view3D, data);
			cover.addEventListener(CoverFlowEvent.COVERCLICKED, _coverClickedHandler);
			cover.addEventListener(CoverFlowEvent.CREATIONCOMPLETE, _coverCreationComleteHandler);
			
			if (location > _children.length) {
				_children.addItem(cover);
			}
			else {
				_children.addItemAt(cover, location);
        	}
        	
        	// the first created cover, set the selectedIndex to 
			// Dispatch a change event
			if (_selectedIndex == -1 && _children.length == 1) {
				this.selectedIndex = 0;
			}
        }
		
		/**
		 * @private
		 * @param data
		 * @param fromLocation
		 * @param toLocation
		 * TODO
		 */
		private function _moveCover(data:Object, fromLocation:int, toLocation:int):void {
			
		}
		
		/**
		 * @private
		 */
		private function _removeAllCovers():void {
			
			this.selectedIndex = 0;
			for (var i:uint = 0; i < _children.length; i++) {
        		var cover:ICoverShape = _children.getItemAt(i) as ICoverShape;
        		if (cover.shape != null) {
	        		_view3D.scene.removeChild(cover.shape);
        		}
        		else {
        			cover.scheduleForRemoval();
        		}
        	}
        	_children.removeAll();
        	
        	_render();
		}
		
		/**
		 * @private
		 * @param data
		 * @param location
		 */
		private function _replaceCover(data:Object, location:int):void {
			
			// Get the cover to replace
			var cover:ICoverShape = _children.getItemAt(location) as ICoverShape;
			cover.init(this, _view3D, data);
			
        	// Remove the plane from the scene
        	if (cover.shape != null) {
	        	_view3D.scene.removeChild(cover.shape);
	        }
        	
        	// Create a new cover
			_children.setItemAt(cover, location);
		}
		
		/**
		 * @private
		 * @param data
		 * @param location
		 */
		private function _removeCover(data:Object, location:int):void {
			
			if (_children.length > location) {
				
				// Get the cover
				var cover:ICoverShape = _children.getItemAt(location) as ICoverShape;
				// Delete the cover from the scene
				if (cover.shape != null) {
					_view3D.scene.removeChild(cover.shape);
				}
				// Remove the item from the children list
				_children.removeItemAt(location);
				
				_lineUpCovers();
				_render();
			}
		}
		
		
		/**
		 * @private
		 * @param data
		 * @param location
		 */
		private function _refreshCovers():void {
			
			_removeAllCovers();
			
			for (var i:uint = 0; i < _dataProvider.length; i++) {
				_addCover(_dataProvider.getItemAt(i), i);
			}
		}
		
		/**
		 * @private
		 */
		private function _setCoverAngles():void {
			
			for (var i:uint = 0; i < _children.length; i++) {
				
				var cover:ICoverShape = _children.getItemAt(i) as ICoverShape;
				
				if (cover.shape != null) {
					
					var distance:Number;
					var rotationPercentage:Number;
					
					if (_direction == SebCoverFlow.HORIZONTALDIRECTION) {
						
						distance = this._pointOfInterest.x - cover.initialX;
						
						if (distance > _flippoint) {
							
							// rotation!!!!!!
							cover.shape.rotationX = _rotationAngle;
							
							// rotationY, z and x
							cover.shape.rotationY = _flipAngle;
							cover.shape.z = 0;
							cover.shape.x = cover.initialX - _selectedItemGap / 2;
						}
						else if (distance < -_flippoint) {
							
							
							// rotation!!!!!!
							cover.shape.rotationX = -_rotationAngle;
							
							
							// rotationY, z and x
							cover.shape.rotationY = - _flipAngle;
							cover.shape.z = 0;
							cover.shape.x = cover.initialX + _selectedItemGap / 2;
						}
						else {
							
							rotationPercentage = (100 / _flippoint * distance) / 100;
							
							// rotation!!!!!!
							cover.shape.rotationX = _rotationAngle * rotationPercentage;
							
							
							// rotationY, z and x
							cover.shape.rotationY = (_flipAngle * rotationPercentage);
							cover.shape.z = _selectedItemZoom * (1 - Math.abs(rotationPercentage));
							cover.shape.x = cover.initialX - (_selectedItemGap / 2 * rotationPercentage);
						}
						
					}
					else if (_direction == SebCoverFlow.VERTICALDIRECTION) {
						
						distance = this._pointOfInterest.y - cover.initialY;
						
						// new !!!
						//var offsetX:Number = 220;
						
						if (distance > _flippoint) {
							
							// rotationY, z and x	
							cover.shape.rotationX = _flipAngle;
							
							// rotation!!!!!!
							cover.shape.rotationY = _rotationAngle;
							
							cover.shape.z = 0;
							cover.shape.y = cover.initialY - _selectedItemGap / 2;
						}
						else if (distance < -_flippoint) {
							
							// rotationY, z and x
							cover.shape.rotationX = - _flipAngle;
							
							// rotation!!!!!!
							cover.shape.rotationY = -_rotationAngle;
							
							cover.shape.z = 0;
							cover.shape.y = cover.initialY + _selectedItemGap / 2;
						}
						else {
							
							rotationPercentage = (100 / _flippoint * distance) / 100;
							
							// rotationY, z and x
							cover.shape.rotationX = (_flipAngle * rotationPercentage);
							
							// rotation!!!!!!
							cover.shape.rotationY = (_rotationAngle * rotationPercentage);
							
							
							cover.shape.x =  Math.abs(rotationPercentage); // * offsetX
							
							cover.shape.z = _selectedItemZoom * (1 - Math.abs(rotationPercentage));
							cover.shape.y = cover.initialY - (_selectedItemGap / 2 * rotationPercentage);
						}
						
					}
				}
			}
		}
		/**
		 * @private
		 */
		private function _setCamera():void {
			
			_view3D.camera.x = _pointOfInterest.x + _cameraOffsetX;
			_view3D.camera.y = _pointOfInterest.y + _cameraOffsetY;
			_view3D.camera.z = _cameraOffsetZ;
			
			this._view3D.camera.lookAt(this._pointOfInterest);
		}
		
		/**
		 * @private
		 * @param fromIndex
		 * @param toIndex
		 */
		private function _tween(fromIndex:uint, toIndex:uint):void {
			
			var time:Number = 2;
			
			// Compare the old index to the new index, if it's just one
			// position different, set the time to one sec instead of two
			if (Math.abs(fromIndex - toIndex) == 1) {
				time = 1;
			}
			
			// Tween from the current position to the new position
			if (!isNaN(_children.getItemAt(toIndex).initialX)) {
				
				if (_direction == SebCoverFlow.HORIZONTALDIRECTION) {
					Tweener.addTween(_pointOfInterest, {x: _children.getItemAt(toIndex).initialX, time:time, onUpdate:_render, onComplete:_tweenerOnCompleteHandler});
					
					_state = "animating";
				}
				else if (_direction == SebCoverFlow.VERTICALDIRECTION) {
					Tweener.addTween(_pointOfInterest, {y: _children.getItemAt(toIndex).initialY, time:time, onUpdate:_render, onComplete:_tweenerOnCompleteHandler});
					
					_state = "animating";
				}
			}
		}
		
		/**
		 * @private
		 */
		private function _lineUpCovers():void {
			
			// Line up the covers
			for (var i:Number = 0; i < _children.length; i++) {
				var currentCover:ICoverShape = _children.getItemAt(i) as ICoverShape;
				
				if (currentCover.shape != null) {
					
					var heightOffset:Number = currentCover.shape.objectHeight;
					
					currentCover.initialX = _itemGap * i;
					currentCover.initialY = - (_itemGap * i);
					
					if (_direction == SebCoverFlow.HORIZONTALDIRECTION) {
						
						currentCover.shape.x = _itemGap * i;
					}
					else if (_direction == SebCoverFlow.VERTICALDIRECTION) {
						
						currentCover.shape.y = - (_itemGap * i);
					}
				}
			}
		}
		
		/**
		 * @private
		 */
		private function _render():void {
			
			if (this.stage != null) {
				
				_setCoverAngles();
				_setCamera();
				_view3D.render();
			}
		}
		
		override protected function createChildren():void {
			
		}
		
		override protected function measure():void {
			
		}
		
		override protected function commitProperties():void {
			
		}
		
		/**
		 * @param unscaledWidth
		 * @param unscaledHeight
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			// Set the clipping of the 3D scene to make sure only the visible 
			// elements are rendered
			var clipping:RectangleClipping = new RectangleClipping(-this.width/2, -this.height/2, this.width/2, this.height/2);
			_view3D.clip = clipping;
			
			// Set a mask on the view3D
			if (_mask != null) {
				this.removeChild(_mask);
			}
			_mask = new Sprite();
			_mask.x = 0;
			_mask.y = 0;
			_mask.graphics.beginFill(0xFF0000, 1);
			_mask.graphics.drawRect(0, 0, this.width, this.height);
			_mask.graphics.endFill();
			_mask.alpha = .35;
			_mask.mouseEnabled = false;
			this.addChild(_mask);
			
			_view3D.mask = _mask;
			
			_view3D.x = this.width * 0.5;
			_view3D.y = this.height * 0.5;
			_render();
		}
	
		/**
		 * @private
		 */	
		private function _addedToStageEventHandler(event:Event):void {
			_render();
		}
		
		/**
		 * @private
		 */
		private function _tweenerOnCompleteHandler():void {
			_state = "static";
			
			_render();
			
			this.dispatchEvent(new Event("animationComplete"));
		}
		
        /**
         * @private
         * @param event
         */
        private function _dataChangeHandler(event:CollectionEvent):void {
        	
			switch (event.kind) {
        		case CollectionEventKind.ADD:
        			for (var i:uint = 0; i < event.items.length; i++) {
        				_addCover(event.items[i] as Object, event.location);
        			}
        		break;
        		case CollectionEventKind.MOVE:
        			
        			// TODO
					//this.moveCover(event.items[i] as Object, event.oldLocation, event.location);
        			
        		break;
        		case CollectionEventKind.REFRESH:
        			
        			_refreshCovers();
					
        		break;
        		case CollectionEventKind.REMOVE:
        			
        			_removeCover(event.items[0] as Object, event.location);
        			
        		break;
        		case CollectionEventKind.REPLACE:
        			
        			var propertyChangeEvent:PropertyChangeEvent = event.items[0] as PropertyChangeEvent;
        			_replaceCover(propertyChangeEvent.newValue as Object, event.location);
        			
        		break;
        		case CollectionEventKind.RESET:
					
					_removeAllCovers();
					
        		break;
        		case CollectionEventKind.UPDATE:
        			
        		break;
        		
        	}
        	
			_itemsDirty = true;
			this.invalidateProperties();
			this.invalidateSize();
        }
		
		
		/**
		 * @private
		 * @param event
		 */		
		private function _coverClickedHandler(event:CoverFlowEvent):void {
		
			var cover:ICoverShape = event.currentTarget as ICoverShape;
			if (this.selectedIndex != _children.getItemIndex(cover)) {
				this.selectedIndex = _children.getItemIndex(cover);
			}
			else if (_state == "static" || _state == "complete") {
				
				this.dispatchEvent(new Event("selectedCoverClicked"));
			}
		}
		
		/**
		 * @private
		 * @param event
		 */
		private function _coverCreationComleteHandler(event:CoverFlowEvent):void {
			
			// Add the newly loaded cover to the scene
			var cover:ICoverShape = event.currentTarget as ICoverShape;
			if (cover.shape != null) {
				_view3D.scene.addChild(cover.shape);
			}
			
			_lineUpCovers();
			
			// All of the covers are created and we're in the init
			// state, so let the world know the covers are created
			if ((_children.length == _dataProvider.length) && (_state == "init")) {
				this.dispatchEvent(new Event("coverInitComplete"));
				_state = "complete";
			}
			
			_render();
		}
		
		/**
		 * The elements in the dataProvider ArrayCollection must contain a source (String) property 
		 * containing the url from which the image is loaded
		 */		
		[Bindable]
		public function set dataProvider(value:ArrayCollection):void {
			
			if (_dataProvider != null) {
				_dataProvider.removeEventListener(CollectionEvent.COLLECTION_CHANGE, _dataChangeHandler, false);
				_removeAllCovers();
			}
			
			_dataProvider = value;
			
			for (var i:Number = 0; i < _dataProvider.length; i++) {
				_addCover(_dataProvider.getItemAt(i), i);
			}
			
			_dataProvider.addEventListener(CollectionEvent.COLLECTION_CHANGE, _dataChangeHandler, false, 0, true);
			
			_itemsDirty = true;
			this.selectedIndex = 0;
			this.invalidateProperties();
			this.invalidateSize();
		}
		
		public function get dataProvider():ArrayCollection {
			return _dataProvider;
		}
		
		/**
		 * Setting this property causes the coverFlow to animate to that index. If the new selectedIndex
		 * is the same as current selectedIndex nothing happens.
		*/
		[Bindable("change")]
		public function set selectedIndex(value:int):void {
			
			if (value == _selectedIndex) {
				this.dispatchEvent(new Event("selectItem"));
				
			    return;
			}
			
			// Make sure the new selectedIndex is within the range
			// of the _children ArrayCollection
			if (value < 0 || value >= _children.length) {
				return;
			}
			
			// Tween to the new index
			_tween(_selectedIndex, value);
			
			// Set our private property
			_selectedIndex = value;
			
			// And dispatch a change event
			this.dispatchEvent(new Event("change"));
			
			// Save the history
			if (_enableHistory) HistoryManager.save();
		}
		public function get selectedIndex():int {
			return _selectedIndex;
		}
		
		/**
		* This is the gap (in Away3D coordinates) between the covers
		*/
		[Bindable]
		public function set itemGap(value:Number):void {
			
			_itemGap = value;
			
			_lineUpCovers();
			
			if (_children.length > 0) {
				var cover:ICoverShape = _children.getItemAt(_selectedIndex) as ICoverShape;
				if (cover.shape != null) {
					_pointOfInterest.x = cover.shape.x;
				}
			}
			
			_render();
		}
		
		public function get itemGap():Number {
			return _itemGap;
		}
		
		/**
		* The distance (in Away3D coordinates) between the selected item and the preceiding and succeding covers
		*/
		[Bindable]
		public function set selectedItemGap(value:Number):void {
			_selectedItemGap = value;
			_render();
		}
		public function get selectedItemGap():Number {
			return _selectedItemGap;
		}
		
		/**
		* The distance (in Away3D coordinates) from which the covers start to turn into the selected position
		*/
		[Bindable]
		public function set flippoint(value:Number):void {
			_flippoint = value;
			_render();
		}
		public function get flippoint():Number {
			return _flippoint;
		}
		
		/**
		* The direction of the reflection
		*/
		[Bindable]
		public function set reflection(value:Boolean):void {
			
			_reflection = value;
			
			_pointOfInterest = new Number3D();
			_setCamera();
			
			dataProvider.refresh();
		}
		public function get reflection():Boolean {
			return _reflection;
		}
		
		/**
		* The direction of the cover items, horizontal or vertical
		*/
		[Inspectable]
		public function set direction(value:String):void {
			_direction = value;
			
			_pointOfInterest = new Number3D();
			_setCamera();
			
			dataProvider.refresh();
		}
		public function get direction():String {
			return _direction;
		}
		
		
		/**
		 * If set to true, both sides (front and back) of the geometry are rendered.
		 * The default is set  to false. Setting this property to true will decrease 
		 * performance because twice as much polygons need to be rendered, so only set 
		 * this to true if the back sides of the geometry really must be visible.
		 */
		[Inspectable]
		public function set bothsides(value:Boolean):void {
			_bothsides = value;
			
			_pointOfInterest = new Number3D();
			_setCamera();
			
			dataProvider.refresh();
		}
		public function get bothsides():Boolean {
			return _bothsides;
		}
		
		
		
		
		/**
		* The shape of the cover Items
		*/
		[Bindable]
		public function set shape(value:String):void {
			_shape = value;
			
			_pointOfInterest = new Number3D();
			_setCamera();
			
			dataProvider.refresh();
		}
		public function get shape():String {
			return _shape;
		}
		
		/**
		* The angle (in degrees) of the not selected covers
		*/
		[Bindable]
		public function set flipAngle(value:Number):void {
			_flipAngle = value;
			_render();
		}
		public function get flipAngle():Number {
			return _flipAngle;
		}
		
		
		/**
		* The angle (in degrees) of the not selected covers
		*/
		[Bindable]
		public function set rotationAngle(value:Number):void {
			_rotationAngle = value;
			_render();
		}
		public function get rotationAngle():Number {
			return _rotationAngle;
		}
		
		
		/**
		* The z position (in Away3D coordinates) of the selected item
		*/
		[Bindable]
		public function set selectedItemZoom(value:Number):void {
			_selectedItemZoom = value;
			_render();
		}
		public function get selectedItemZoom():Number {
			return _selectedItemZoom;
		}
		
		/**
		* The x position (in Away3D coordinates) of the camera
		*/
		[Bindable]
		public function set cameraOffsetX(value:Number):void {
			_cameraOffsetX = value;
			_render();
		}
		public function get cameraOffsetX():Number {
			return _cameraOffsetX;
			_render();
		}
		
		/**
		* The y position (in Away3D coordinates) of the camera
		*/
		[Bindable]
		public function set cameraOffsetY(value:Number):void {
			_cameraOffsetY = value;
			_render();
		}
		public function get cameraOffsetY():Number {
			return _cameraOffsetY;
		}
		
		/**
		* The z position (in Away3D coordinates) of the camera
		*/
		[Bindable]
		public function set cameraOffsetZ(value:Number):void {
			_cameraOffsetZ = value;
			_render();
		}
		public function get cameraOffsetZ():Number {
			return _cameraOffsetZ;
		}
		
		
		//************************************************************************************
        // History Managment
        //************************************************************************************
        
		public function saveState():Object {
			if (_enableHistory == false) return {};
			return { selectedIndex: _selectedIndex };
		}
		
		public function loadState(state:Object):void {
			
			if (_enableHistory == false) return;
			
			var selectedIndex:uint = state ? int(state.selectedIndex) : 0;
			
			// disable the historymanagement temporarily to set the selectedIndex
			_enableHistory = false;
			_selectedIndex = selectedIndex;
			_enableHistory = true;
		}
		
		
		private function _mouseWheelEventHandler(event:MouseEvent):void {
			
			if (event.delta > 0) {
				this.selectedIndex = Math.max(0, selectedIndex - 1);
			}
			else {
				this.selectedIndex = Math.min(_dataProvider.length - 1, _selectedIndex + 1);
			}
			event.bubbles
		}
		
		
		override protected function keyDownHandler(event:KeyboardEvent):void {
			
			//super.keyDownHandler(event);
			
			//Alert.show(event.keyCode.toString());
			
			switch (event.keyCode) {
				case Keyboard.LEFT:
					if (_direction == SebCoverFlow.HORIZONTALDIRECTION) {
						this.selectedIndex = Math.max(0, selectedIndex - 1);
						event.stopPropagation();
					}
				break;
				case Keyboard.RIGHT:
					if (_direction == SebCoverFlow.HORIZONTALDIRECTION) {
						this.selectedIndex = Math.min(_dataProvider.length - 1, _selectedIndex + 1);
						event.stopPropagation();
					}
				break;
				case Keyboard.UP:
					this.dispatchEvent(new Event("selectedCoverClicked"));
					if (_direction == SebCoverFlow.VERTICALDIRECTION) {
						this.selectedIndex = Math.max(0, selectedIndex - 1);
						event.stopPropagation();
					}
				break;
				case Keyboard.DOWN:
					if (_direction == SebCoverFlow.VERTICALDIRECTION) {
						this.selectedIndex = Math.min(_dataProvider.length - 1, _selectedIndex + 1);
						event.stopPropagation();
					}
				break;
				case Keyboard.ENTER:
					this.dispatchEvent(new Event("selectedCoverClicked"));
					event.stopPropagation();
				break;
			}
		}
	}
}