package mm.screens {
	
	import com.smartfoxserver.v2.SmartFox;
	import com.smartfoxserver.v2.core.SFSEvent;
	import com.smartfoxserver.v2.entities.*;
	import com.smartfoxserver.v2.entities.UserPrivileges;
	import com.smartfoxserver.v2.entities.data.*;
	import com.smartfoxserver.v2.entities.variables.*;
	import com.smartfoxserver.v2.requests.*;
	import com.smartfoxserver.v2.requests.buddylist.GoOnlineRequest;
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	import mm.Main;
	import flash.display3D.IndexBuffer3D;
	import flash.ui.GameInput;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import com.hurlant.crypto.symmetric.NullPad;
	import flash.ui.GameInput;
	import flash.ui.Keyboard;
	import flash.geom.ColorTransform;
	
	import flash.media.Sound;
	import flash.media.SoundTransform;
	import flash.media.SoundChannel;
	import flash.net.SharedObject;
	import flash.geom.Rectangle;
	
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import com.greensock.*;
	import com.greensock.easing.*;
	import com.greensock.plugins.TweenPlugin; 
	import com.greensock.plugins.VisiblePlugin;
	
	import com.adobe.crypto.MD5;
	
	import flash.text.*;
	
	import mm.profile.Profile;
	import mm.screens.MapScreen;
	import mm.ScrollBar;
	import mm.ModScreenUtils;
	import mm.utils.StringEdit;
	import mm.rooms.Location;
	
	import flash.ui.Mouse;
	import mm.entities.Furniture;
	import mm.rooms.House;
	import mm.entities.Avatar;
	import mm.Valentine;
	
	public class GameScreen extends MovieClip {
		
		private var so:SharedObject = SharedObject.getLocal("mirkomir");
		private var msgCount;
		private var scrollBar;
		private const MSG_MAX:int = 100;
		private var soundChannel:SoundChannel;
		private var volume:Number;
		
		public function GameScreen() 
		{
			//
			// Инициализация
			//
			
			TweenPlugin.activate([VisiblePlugin]);
			
			Main.main.addEventListener(KeyboardEvent.KEY_DOWN, reportKeyDown);
			
			this.mouseChildren = true;
			
			//
			// halloween quest
			//
			
			/*
			this.chatPanel.btnValentine.addEventListener(MouseEvent.CLICK, Main.Presents.Init);
			/*this.chatPanel.counterValentine.lblCount.text = Main.sfs.mySelf.getVariable("valentines").getIntValue().toString();
			if(Main.sfs.mySelf.getVariable("valentines").getIntValue() < 1)
				this.chatPanel.counterValentine.visible = false;
				*/
			
			//
			// furniturePanel
			//
			
			var fp = this.furniturePanel;
			fp.visible = false;
			
			//
			// chatPanel
			//
			
			var cp = this.chatPanel;
			
			for each (var IO:InteractiveObject in cp)
				IO.tabEnabled = false;
			
			cp.btnSmiles.addEventListener(MouseEvent.CLICK, btnSmilesClick);
			cp.btnFriends.addEventListener(MouseEvent.CLICK, btnFriendsClick);
			cp.btnProfile.addEventListener(MouseEvent.CLICK, btnProfileClick);
			cp.btnVolume.addEventListener(MouseEvent.CLICK, btnVolumeClick);
			cp.btnList.addEventListener(MouseEvent.CLICK, btnListClick);
			
			cp.btnHouse.stop();
			cp.btnHouse.mouseChildren = false;
			cp.btnHouse.buttonMode = true;
			cp.btnHouse.addEventListener(MouseEvent.CLICK, btnHouseClick);
			cp.btnHouse.icon.gotoAndStop(4);
			
			cp.btnChatHistory.addEventListener(MouseEvent.CLICK, btnChatHistoryClick);
			cp.btnChat.addEventListener(MouseEvent.CLICK, btnChatClick);
			
			cp.btnVolume.stop();
			cp.btnVolume.mouseChildren = false;
			cp.btnVolume.buttonMode = true;
			cp.btnVolume.tabEnabled = false;
			
			if (so.data.soundVolume == null)
				volume = 0.5;
			else
				volume = so.data.soundVolume;
			
			cp.btnFriendsNotification.visible = false;
			
			//
			// chatPanelMinimised
			//
			
			var cpm = this.chatPanelMinimised;
			
			for each (var IOcpm:InteractiveObject in cpm)
				IOcpm.tabEnabled = false;
			
			cpm.btnSmiles.addEventListener(MouseEvent.CLICK, btnSmilesClick);
			cpm.btnVolume.addEventListener(MouseEvent.CLICK, btnVolumeClick);
			
			cpm.btnChatHistory.addEventListener(MouseEvent.CLICK, btnChatHistoryClick);
			cpm.btnChat.addEventListener(MouseEvent.CLICK, btnChatClick);
			
			cpm.btnVolume.stop();
			cpm.btnVolume.mouseChildren = false;
			cpm.btnVolume.buttonMode = true;
			cpm.btnVolume.tabEnabled = false;
			
			//
			// locationPanel
			//
			
			var lcp = this.locationPanel;
			
			lcp.lblName.text = "";
			lcp.btnMap.addEventListener(MouseEvent.CLICK, locationPanelBtnMapClick);
			lcp.btnMap.tabEnabled = false;
			
			//
			// balancePanel
			//
			
			var bp = this.balancePanel;
			
			bp.lblRegular.text = "0";
			bp.lblDonate.text = "0";
			bp.btnAdd.addEventListener(MouseEvent.CLICK, balancePanelBtnAddClick);
			bp.btnAdd.tabEnabled = false;
			
			//
			// smilesPanel
			//
			
			var sp:MovieClip = this.smilesPanel;
			
			sp.blendMode = BlendMode.LAYER;
			sp.visible = false;
			
			for each (var DO:DisplayObject in sp)
				if (DO.name.indexOf("btn_") >= 0)
				{
					DO.addEventListener(MouseEvent.CLICK, smilesPanelBtnClick);
					
					var mc:MovieClip = DO as MovieClip;
					mc.stop();
					mc.buttonMode = true;
				}
			
			//
			// volumePanel
			//
			
			var vp = this.volumePanel;
			
			vp.visible = false;
			
			var sg = vp.sliderGroup;
			
			sg.slider.buttonMode = true;
			sg.slider.tabEnabled = false;
			sg.sliderArea.buttonMode = true;
			sg.sliderArea.tabEnabled = false;
			sg.sliderArea.useHandCursor = true;
			
			sg.slider.addEventListener(MouseEvent.MOUSE_DOWN, volumePanelSliderMouseDown);
			sg.sliderArea.addEventListener(MouseEvent.MOUSE_DOWN, volumePanelSliderAreaMouseDown);
			
			//
			// listPanel
			//
			
			var lstp = this.listPanel;
			
			lstp.blendMode = BlendMode.LAYER;
			lstp.visible = false;
			
			lstp.btnHelp.addEventListener(MouseEvent.CLICK, listPanelBtnHelpClick);
			lstp.btnHelp.tabEnabled = false;
			lstp.btnFullScreen.addEventListener(MouseEvent.CLICK, listPanelBtnFullScreenClick)
			lstp.btnFullScreen.tabEnabled = false;
			lstp.btnRating.addEventListener(MouseEvent.CLICK, listPanelBtnRatingClick)
			lstp.btnRating.tabEnabled = false;
			
			//
			// chatHistoryPanel
			//
			
			var chp = this.chatHistoryPanel;
			chp.blendMode = BlendMode.LAYER;
			chp.visible = false;
			chp.lblEmpty.mouseEnabled = false;
			chp.lblEmpty.text = "История чата пуста";
			
			msgCount = 0;
			
			var scrl = chp.scrollbar;
			scrl.area.slider.stop();
			scrl.visible = false;
			
			//
			// modPanel
			//
			
			var mp = this.modPanel;
			
			mp.visible = false;
			
			if(Main.sfs.mySelf.isModerator() || Main.sfs.mySelf.isAdmin())
			{
				mp.visible = true;
				
				mp.btnMod.addEventListener(MouseEvent.CLICK, modPanelBtnModClick);
				mp.btnMZ.addEventListener(MouseEvent.CLICK, modPanelBtnMZClick);
				mp.btnInvisible.addEventListener(MouseEvent.CLICK, modPanelBtnInvisibleClick);
				
				if (so.data.modMZ != null)
					if(so.data.modMZ)
						Main.dzAllow = true;
				
				if(so.data.modInvisible != null)
					Main.sfs.send(new GoOnlineRequest(so.data.modInvisible));
			}
		}
		
		public function destroy():void
		{
			if(soundChannel)
				soundChannel.stop();
		}
		
		public function setHouseEditButton(state:Boolean):void
		{
			var cp = this.chatPanel;
			
			if(state)
			{
				cp.btnHouse.removeEventListener(MouseEvent.CLICK, btnHouseClick);
				cp.btnHouse.addEventListener(MouseEvent.CLICK, btnHouseEditClick);
				cp.btnHouse.icon.gotoAndStop(26);
			}
			else
			{
				cp.btnHouse.removeEventListener(MouseEvent.CLICK, btnHouseEditClick);
				cp.btnHouse.addEventListener(MouseEvent.CLICK, btnHouseClick);
				cp.btnHouse.icon.gotoAndStop(4);
			}
		}
		
		public function setLocation(setValue:String):void
		{
			this.locationPanel.lblName.text = setValue;
		}
		
		public function setBalanceRegular(setValue:String):void
		{
			this.balancePanel.lblRegular.text = setValue;
		}
		
		public function setBalanceDonate(setValue:String):void
		{
			this.balancePanel.lblDonate.text = setValue;
		}
		
		private function reportKeyDown(event:KeyboardEvent)
		{
			if (event.keyCode == Keyboard.ENTER)
				sendChatMessage();
		}
		
		//
		// furniturePanel
		//
		
		private var fpscroll:ScrollBar;
		private var inv:ISFSArray;
		
		public function initFurniturePanel(responseParams:ISFSObject):void
		{
			var gs:GameScreen = Main.gameScreen;
			var fp:MovieClip = gs.furniturePanel;
			
			inv = responseParams.getSFSArray("inventory");
			
			Main.roomScreen.allowDragFurniture();
			
			TweenLite.killTweensOf(gs.modPanel);
			TweenLite.killTweensOf(gs.chatPanel);
			TweenLite.killTweensOf(gs.locationPanel);
			TweenLite.killTweensOf(gs.balancePanel);
			TweenLite.killTweensOf(fp);
			
			if(Main.sfs.mySelf.isModerator() || Main.sfs.mySelf.isAdmin())
				TweenLite.to(gs.modPanel, 0.2, {visible:false, alpha:0});
			TweenLite.to(gs.chatPanel, 0.2, {visible:false, alpha:0});
			TweenLite.to(gs.locationPanel, 0.2, {visible:false, alpha:0});
			TweenLite.to(gs.balancePanel, 0.2, {visible:false, alpha:0});
			
			if(gs.smilesPanel.visible)
				TweenLite.to(gs.smilesPanel, 0.2, {y:"20", visible:false, alpha:0});
			if(gs.volumePanel.visible)
				TweenLite.to(gs.volumePanel, 0.2, {y:"20", visible:false, alpha:0});
			if(gs.listPanel.visible)
				TweenLite.to(gs.listPanel, 0.2, {y:"20", visible:false, alpha:0});
			if(gs.chatHistoryPanel.visible)
				TweenLite.to(gs.chatHistoryPanel, 0.2, {y:"20", visible:false, alpha:0});
			
			TweenLite.fromTo(fp, 0.2, {alpha:0, visible:true}, {alpha:1});
			
			fp.scrollbar.area.slider.stop();
			
			fp.btnSave.addEventListener(MouseEvent.CLICK, furniturePanelBtnSaveClick);
			fp.btnSave.tabEnabled = false;
			fp.btnCancel.addEventListener(MouseEvent.CLICK, furniturePanelBtnCancelClick);
			fp.btnCancel.tabEnabled = false;
			
			furniturePanelUpdate();
			
			var lc:Location = Main.roomScreen as Location;
			lc.showPlayers(false);
			
			Main.main.removeChild(Main.main.getChildByName("dls"));
			trace('инитпан');
		}
		
		public function destroyFurniturePanel():void
		{
			var gs:GameScreen = Main.gameScreen;
			var fp:MovieClip = gs.furniturePanel;
			
			TweenLite.killTweensOf(gs.modPanel);
			TweenLite.killTweensOf(gs.chatPanel);
			TweenLite.killTweensOf(gs.locationPanel);
			TweenLite.killTweensOf(gs.balancePanel);
			TweenLite.killTweensOf(fp);
			
			if(Main.sfs.mySelf.isModerator() || Main.sfs.mySelf.isAdmin())
				TweenLite.fromTo(gs.modPanel, 0.2, {alpha:0, visible:true}, {alpha:1});
			TweenLite.fromTo(gs.chatPanel, 0.2, {alpha:0, visible:true}, {alpha:1});
			TweenLite.fromTo(gs.locationPanel, 0.2, {alpha:0, visible:true}, {alpha:1});
			TweenLite.fromTo(gs.balancePanel, 0.2, {alpha:0, visible:true}, {alpha:1});
			TweenLite.to(fp, 0.2, {visible:false, alpha:0});
			
			fp.btnSave.removeEventListener(MouseEvent.CLICK, furniturePanelBtnSaveClick);
			fp.btnCancel.removeEventListener(MouseEvent.CLICK, furniturePanelBtnCancelClick);
			
			var lc:Location = Main.roomScreen as Location;
			lc.showPlayers(true);
			
			trace('дестройпан');
		}
		
		private function furniturePanelBtnSaveClick(event:MouseEvent):void
		{
			var dataLoadingScreen:DataLoadingScreen = new DataLoadingScreen();
			dataLoadingScreen.name = "dls";
			Main.main.addChild(dataLoadingScreen);
			
			var hs:House = Main.roomScreen as House;
			hs.saveFurniture();
			
			destroyFurniturePanel();
		}
		
		private function furniturePanelBtnCancelClick(event:MouseEvent):void
		{
			Main.roomScreen.allowDragFurniture(false);
			destroyFurniturePanel();
			
			var dataLoadingScreen:DataLoadingScreen = new DataLoadingScreen();
			dataLoadingScreen.name = "dls";
			Main.main.addChild(dataLoadingScreen);
			
			var hs:House = Main.roomScreen as House;
			hs.cancelFurniture();
		}
		
		public function showFurniturePanel(visible:Boolean = true):void
		{
			var fp:MovieClip = this.furniturePanel
			
			TweenLite.killTweensOf(fp);
			
			if(visible)
			{
				TweenLite.fromTo(fp, 0.2, {alpha:0, visible:true}, {alpha:1});
				
				fp.mouseChildren = true;
				fp.mouseEnabled = true;
			}
			else
			{
				TweenLite.to(fp, 0.2, {visible:false, alpha:0});
				
				fp.mouseChildren = false;
				fp.mouseEnabled = false;
			}
		}
		
		private function furnitureListItemMouseUp(event:MouseEvent):void
		{
			Main.gameScreen.showFurniturePanel(true);
			
			Mouse.show();
			
			var dla:DataLoadingAnim = event.target as DataLoadingAnim;
			
			dla.stopDrag();
			
			dla.removeEventListener(MouseEvent.MOUSE_UP, furnitureListItemMouseUp);
			
			dla.parent.removeChild(dla);
		}
		
		private function furnitureListItemMouseDown(event:MouseEvent):void
		{
			showFurniturePanel(false);
			
			
			var ind:int = getElementById(int(event.target.name));
			
			var index = event.target.name;
			
			var item:ISFSObject = inv.getElementAt(ind);
		
			Mouse.hide();
		
			var dla:DataLoadingAnim = new DataLoadingAnim();
			dla.name = "fur_dla";
			dla.scaleX = 0.3;
			dla.scaleY = 0.3;
			
			Main.main.addChild(dla);
			dla.startDrag(true);
			
			dla.addEventListener(MouseEvent.MOUSE_UP,  furnitureListItemMouseUp);
			
			var request:URLRequest = new URLRequest('https://playxcat.ru/storage/' + inv.getSFSObject(ind).getUtfString("hash") + ".swf?v" + Math.random());
			var loader = new Loader();
			loader.name = index;
			loader.load(request);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);
			
			function loadComplete(event:Event):void
			{
				event.target.loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,loadComplete);
				
				if(Main.main.getChildByName("fur_dla"))
				{
					var dla:MovieClip = Main.main.getChildByName("fur_dla") as MovieClip;
					dla.removeEventListener(MouseEvent.MOUSE_UP,  furnitureListItemMouseUp);
					dla.stopDrag();
					Main.main.removeChild(dla);
					
					var item:ISFSObject = inv.getSFSObject(getElementById(int(event.target.loader.name)));
					
					// удаление из инвентаря
					if(item.getInt("count") > 0)
					{
						var count:int = item.getInt("count");
						item.removeElement("count");
						item.putInt("count", count - 1);
					}
					furniturePanelUpdate();
					
					var lc:House = Main.roomScreen as House;
					lc.addFurniture(event.target.loader.content.object, item);
				}
			}
		}
		
		private function furniturePanelUpdate():void
		{
			var gs:GameScreen = Main.gameScreen;
			
			var fp:MovieClip = gs.furniturePanel;
			
			for(var i:int = fp.field.content.numChildren - 1; i >= 0; i--)
			{
				var fr:MovieClip = fp.field.content.getChildAt(i) as MovieClip;
				var check:Boolean = false;
				
				for(var j:int = 0; j < inv.size(); j++)
					if(inv.getSFSObject(j).getInt("id").toString() == fr.name && inv.getSFSObject(j).getInt("count") > 0)
					{
						check = true;
						break;
					}
				
				if(!check)
				{
					fp.field.content.removeChild(fr);
					
					if(fp.field.content.x <= -80)
					   fp.field.content.x += 80;
				}
			}
			
			var mod:int = 0;
			
			for(var i:int = 0; i < inv.size(); i++)
			{
				if(fp.field.content.getChildByName(inv.getSFSObject(i).getInt("id")))
				{
					trace('есть');
					var fli:FurniturePanelListItem = fp.field.content.getChildByName(inv.getSFSObject(i).getInt("id")) as FurniturePanelListItem;
					fli.x = mod*80;
					fli.counter.lblCount.text = inv.getSFSObject(i).getInt("count");
					
					var colorTrans = new ColorTransform();
					
					if(mod%2 == 0)
						colorTrans.color = 0x7EB7BE
					else
						colorTrans.color = 0x68ABB3;
						
					fli.background.transform.colorTransform = colorTrans;
					fp.field.content.setChildIndex(fli, 0);
				}
				else if(inv.getSFSObject(i).getInt("count") > 0)
				{
					var fli:FurniturePanelListItem = new FurniturePanelListItem();
					fli.stop();
					fli.buttonMode = true;
					fli.tabEnabled = false;
					fli.mouseChildren = false;
					fli.x = mod*80;
					fli.name = String(inv.getSFSObject(i).getInt("id"));
					fli.addEventListener(MouseEvent.MOUSE_DOWN, furnitureListItemMouseDown);
					
					fli.counter.visible = true;
					fli.counter.lblCount.text = inv.getSFSObject(i).getInt("count");
					
					var colorTrans = new ColorTransform();
					
					if(mod%2 == 0)
						colorTrans.color = 0x7EB7BE
					else
						colorTrans.color = 0x68ABB3;
						
					fli.background.transform.colorTransform = colorTrans;
					
					var dla:DataLoadingAnim = new DataLoadingAnim();
					dla.name = "dla";
					dla.scaleX = 0.3;
					dla.scaleY = 0.3;
					fli.icon.addChild(dla);
					
					var request:URLRequest = new URLRequest('https://playxcat.ru/storage/' + inv.getSFSObject(i).getUtfString("hash") + ".swf?v" + Math.random());
					var loader = new Loader();
					loader.name = String(inv.getSFSObject(i).getInt("id"));
					loader.load(request);
					loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);
					
					function loadComplete(event:Event):void
					{
						event.target.loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,loadComplete);
						
						var id = event.target.loader.name;
						
						var icon:MovieClip = event.target.loader.content.icon as MovieClip;
						icon.x = 0;
						icon.y = 0;
						
						var fli:MovieClip = fp.field.content.getChildByName(id);
						
						fli.icon.removeChild(fli.icon.getChildByName("dla"));
						fli.icon.addChild(icon);
					}
					
					fp.field.content.addChildAt(fli, 0);
				}
				
				if(inv.getSFSObject(i).getInt("count") > 0)
					mod++;
			}
			
			if(fp.field.content.numChildren == 0)
				fp.lblEmpty.text = "Инвентарь пуст";
			else
				fp.lblEmpty.text = "";
			
			fp.scrollbar.visible = false;
			
			if(fpscroll)
				fpscroll.destroy();
			
			var modifer:int = 10;
			
			if(fp.field.content.width - modifer > fp.field.mask.width)
			{				
				fp.scrollbar.visible = true;
					
				fpscroll = new ScrollBar(fp.field, fp.scrollbar, Main.main.stage, 80, false, modifer, true);
			}
		}
		
		private function getElementById(id:int):int
		{
			var index:int = -1;
			
			for(var i:int = 0; i < inv.size(); i++)
				if(inv.getSFSObject(i).getInt("id") == id)
				{
					index = i;
					break;
				}
			
			return index;
		}
		
		public function furniturePanelAddItem(fr:Furniture):void
		{
			if(getElementById(fr._id) != -1)
			{
				var item:ISFSObject = inv.getSFSObject(getElementById(fr._id));
				var count:int = item.getInt("count");
				item.removeElement("count");
				item.putInt("count", count + 1);
			}
			else
			{
				var item:ISFSObject = new SFSObject;
				item.putInt("id", fr._id);
				item.putInt("type", fr.type);
				item.putInt("count", 1);
				item.putUtfString("hash", fr.hash);
				
				inv.addSFSObject(item);
			}
			
			furniturePanelUpdate();
		}
		
		//
		// chatPanel
		//
		
		private function btnSmilesClick(event:MouseEvent):void
		{
			var sp = this.smilesPanel;
			
			if(sp.visible)
				TweenLite.to(sp, 0.2, {y:"20", visible:false, alpha:0});
			else
				TweenLite.fromTo(sp, 0.2, {y:480, alpha:0, visible:true}, {y:"-20", alpha:1});
		}
		
		private function btnFriendsClick(event:MouseEvent):void
		{
			var dataLoadingScreen:DataLoadingScreen = new DataLoadingScreen();
			dataLoadingScreen.name = "dls";
			Main.main.addChild(dataLoadingScreen);
			
			var params:ISFSObject = new SFSObject();
			params.putUtfString("name", Main.sfs.mySelf.name);

			Main.sfs.send(new ExtensionRequest("friendlist", params));
		}
		
		private function btnProfileClick(event:MouseEvent):void
		{
			var dataLoadingScreen:DataLoadingScreen = new DataLoadingScreen();
			dataLoadingScreen.name = "dls";
			Main.main.addChild(dataLoadingScreen);
			
			var params:ISFSObject = new SFSObject();
			params.putUtfString("name", Main.sfs.mySelf.name);

			Main.sfs.send(new ExtensionRequest("profile", params));
		}
		
		private function btnVolumeClick(event:MouseEvent):void
		{
			var vp = this.volumePanel;
			
			if(vp.visible)
				TweenLite.to(vp, 0.2, {y:"20", visible:false, alpha:0});
			else
				TweenLite.fromTo(vp, 0.2, {y:520, alpha:0, visible:true}, {y:"-20", alpha:1});
		}
		
		public function setSound(hash:String):void
		{
			var sound:Sound;
			
			/*if(locName == "club")
			{
				sound = new Sound(new URLRequest("https://194.87.94.217:8000/stream"));
				sound.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			}
			else
			{*/
				sound = new Sound(new URLRequest('https://playxcat.ru/storage/' + hash + ".mp3"));
				sound.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			//}
			
			function ioErrorHandler(event:IOErrorEvent):void
			{
				sound = new Sound(new URLRequest('https://playxcat.ru/storage/' + hash + ".mp3"));
				
				/*if (soundChannel)
				{
					soundChannel.stop();
				}*/
				soundChannel = sound.play(0,999);
				
				setSoundVolume(volume);
				/*if (mute)
				{
					MovieClip(Game.gameScreen).bottomPanel.volumeGroup.volumeButton.volumeIcon.gotoAndStop(1);
					soundChannel.soundTransform = new SoundTransform(0,0);
				}*/
			}

			/*if (soundChannel)
			{
				soundChannel.stop();
			}*/
			soundChannel = sound.play(0,999);
			setSoundVolume(volume);
			/*if (mute)
			{
				Game.gameScreen.bottomPanel.volumeGroup.volumeButton.volumeIcon.gotoAndStop(1);
				soundChannel.soundTransform = new SoundTransform(0,0);
			}*/
		}
		
		public function destroySound():void
		{
			soundChannel.stop();
		}
		
		private function setSoundVolume(vol:Number):void
		{
			this.chatPanel.btnVolume.icon.gotoAndStop(8 + 5 - (Math.floor((100 - vol * 100) / 33) + 1));
			this.chatPanelMinimised.btnVolume.icon.gotoAndStop(8 + 5 - (Math.floor((100 - vol * 100) / 33) + 1));
			this.volumePanel.sliderGroup.slider.y =  -  vol * this.volumePanel.sliderGroup.sliderArea.height + 27;
			soundChannel.soundTransform = new SoundTransform(vol,0);
			so.data.soundVolume = vol;
		}
		
		// TODO
		
		private function btnHouseClick(event:MouseEvent):void
		{
			var params:ISFSObject = new SFSObject();
			params.putUtfString("location", "house_" + Main.sfs.mySelf.name);
			Main.sfs.send(new ExtensionRequest("joinroom", params));
		}
		
		private function btnHouseEditClick(event:MouseEvent):void
		{
			var dataLoadingScreen:DataLoadingScreen = new DataLoadingScreen();
			dataLoadingScreen.name = "dls";
			Main.main.addChild(dataLoadingScreen);
			
			Main.sfs.send(new ExtensionRequest("furniture.get"));
		}
		
		private function btnListClick(event:MouseEvent):void
		{
			var lp = this.listPanel;
			
			if(lp.visible)
				TweenLite.to(lp, 0.2, {y:"20", visible:false, alpha:0});
			else
				TweenLite.fromTo(lp, 0.2, {y:480, alpha:0, visible:true}, {y:"-20", alpha:1});
		}
		
		private function btnChatHistoryClick(event:MouseEvent):void
		{
			var chp = this.chatHistoryPanel;
			
			if(chp.visible)
				TweenLite.to(chp, 0.2, {y:"20", visible:false, alpha:0});
			else
				TweenLite.fromTo(chp, 0.2, {y:400, alpha:0, visible:true}, {y:"-20", alpha:1});
		}

		private function btnChatClick(event:MouseEvent):void
		{
			sendChatMessage();
		}
		
		//
		// chatHistoryPanel
		//
		
		public function chpAddMessage(sender:String, msg:String):void
		{
			var chp = this.chatHistoryPanel;
			var chm:ChatHistoryMessage = new ChatHistoryMessage();
			var btn:MovieClip = chm.btnProfile;
			
			if(chp.lblEmpty.text != "")
				chp.lblEmpty.text = "";
			
			btn.buttonMode = true;
			btn.mouseChildren = false;
			btn.lblName.text = sender;
			btn.lblName.width = 0;
			btn.lblName.autoSize = TextFieldAutoSize.CENTER;
			btn.lblName.x = 0;
			btn.addEventListener(MouseEvent.CLICK, namePanelClick);
			
			btn.background.width = btn.lblName.width;
			btn.slash.x = btn.lblName.width;
			
			chm.lblMsg.width = chp.field.mask.width - btn.width;
			chm.lblMsg.x = btn.width;
			chm.lblMsg.text = msg;
			
			var colorTrans = new ColorTransform();
			colorTrans.color = 0x4E9EA7;
			
			if((msgCount % 2) != 0)
				chm.background.transform.colorTransform = colorTrans;
			
			var heightModifer = 10;
			
			/*if(msgCount > MSG_MAX)
			{
				chm.y = 10 * (chm.height - heightModifer);
				
				chp.field.content.removeChildAt(chp.field.content.numChildren - 1);
				for(var i:int = 0; i < chp.field.content.numChildren; i++)
				{
					chp.field.content.getChildAt(i).y -= 25;
				}
			}
			else*/
				chm.y = msgCount * (chm.height - heightModifer);
			
			chp.field.content.addChildAt(chm, 0);
			TweenLite.from(chm, 0.2, {alpha:0});
			
			if(chp.field.content.height - heightModifer > chp.field.mask.height)
			{
				chp.scrollbar.visible = true;
				
				if(scrollBar)
					scrollBar.destroy();
					
				scrollBar = new ScrollBar(chp.field, chp.scrollbar, Main.main.stage, 25, true, heightModifer);
				
				if(-chm.y + chp.field.mask.height + (chm.height - heightModifer) >= chp.field.content.y)
				{
					/*if(msgCount > MSG_MAX)
						TweenLite.fromTo(chp.field.content, 0.2, {y:"25"}, {y:-chp.field.content.height + 200 + heightModifer});
					else*/	
						TweenLite.to(chp.field.content, 0.2, {y:-chp.field.content.height + 200 + heightModifer});
					
				}
			}
			
			msgCount++;
			
			function namePanelClick(event:MouseEvent):void
			{
				var dataLoadingScreen:DataLoadingScreen = new DataLoadingScreen();
				dataLoadingScreen.name = "dls";
				Main.main.addChild(dataLoadingScreen);
		
				var params:ISFSObject = new SFSObject();
				params.putUtfString("name", event.target.lblName.text);
	
				Main.sfs.send(new ExtensionRequest("profile", params));
			}
		}
		
		//
		// locationPanel
		//
		
		private function locationPanelBtnMapClick(event:MouseEvent):void
		{
			if(!Main.main.getChildByName("scrn_map"))
				var mapScreen:MapScreen = new MapScreen();
		}
		
		//
		// balancePanel
		//
		
		private function balancePanelBtnAddClick(event:MouseEvent):void
		{
			navigateToURL(new URLRequest('https://playxcat.ru/donate'), "_blank");
		}
		
		//
		// smilesPanel
		//
		
		private function smilesPanelBtnClick(event:MouseEvent):void
		{
			TweenLite.to(this.smilesPanel, 0.2, {y:"20", visible:false, alpha:0});
			
			sendChatMessage("#BUBBLE#::" + event.target.name.substr(4));
		}
		
		//
		// volumePanel
		//
		
		private function volumePanelSliderMouseDown(event:MouseEvent):void
		{
			var sg = this.volumePanel.sliderGroup;
			var bounds = new Rectangle(0,sg.sliderArea.y,0,sg.sliderArea.height);
			sg.slider.startDrag(true, bounds);

			this.mouseChildren = false;
			this.addEventListener(MouseEvent.MOUSE_UP, sliderUp);
			this.addEventListener(MouseEvent.MOUSE_MOVE, sliderMove);
		}
		
		private function sliderUp(event:MouseEvent):void
		{
			var sg = this.volumePanel.sliderGroup;
			sg.slider.stopDrag();
			this.mouseChildren = true;
			this.removeEventListener(MouseEvent.MOUSE_UP, sliderUp);
			this.removeEventListener(MouseEvent.MOUSE_MOVE, sliderMove);
		}

		private function sliderMove(event:MouseEvent):void
		{
			sliderChangePos();
		}

		private function volumePanelSliderAreaMouseDown(event:MouseEvent):void
		{
			var sg = this.volumePanel.sliderGroup;
			sg.slider.y = event.localY + sg.sliderArea.y;
			sliderChangePos();
		}

		public function sliderChangePos():void
		{
			var sg = this.volumePanel.sliderGroup;
			sg.slider.gotoAndStop("_down");
			volume = Math.abs((sg.slider.y + sg.sliderArea.y) / sg.sliderArea.height);
			setSoundVolume(volume);
		}
		
		//
		// listPanel
		//
		
		private function listPanelBtnHelpClick(event:MouseEvent):void
		{
			navigateToURL(new URLRequest('https://playxcat.ru/help'), "_blank");
			
			TweenLite.to(this.listPanel, 0.2, {y:"20", visible:false, alpha:0});
		}
		
		private function listPanelBtnFullScreenClick(event:MouseEvent):void
		{
			if (Main.main.stage.displayState == StageDisplayState.NORMAL)
				Main.main.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			else
				Main.main.stage.displayState = StageDisplayState.NORMAL;
				
			TweenLite.to(this.listPanel, 0.2, {y:"20", visible:false, alpha:0});
		}
		
		private function listPanelBtnRatingClick(event:MouseEvent):void
		{
			var dls:DataLoadingScreen = new DataLoadingScreen();
			dls.name = "dls"
			Main.main.addChild(dls);
			
			var params:ISFSObject = new SFSObject();

			Main.sfs.send(new ExtensionRequest("rating", params));
			
			TweenLite.to(this.listPanel, 0.2, {y:"20", visible:false, alpha:0});
		}
		
		//
		// modPanel
		//
		
		private function modPanelBtnMZClick(event:MouseEvent):void
		{
			if(Main.dzAllow)
				Main.dzAllow = false;
			else
				Main.dzAllow = true;
				
			so.data.modMZ = Main.dzAllow;
		}
		
		private function modPanelBtnModClick(event:MouseEvent):void
		{
			ModScreenUtils.init();
		}
		
		private function modPanelBtnInvisibleClick(event:MouseEvent):void
		{
			so.data.modInvisible = Main.sfs.buddyManager.myOnlineState;
			Main.sfs.send(new GoOnlineRequest(!Main.sfs.buddyManager.myOnlineState));
		}

		private function sendChatMessage(msg:String = "")
		{
			if(msg == "")
			{
				var target:MovieClip;
				
				if(this.chatPanel.visible)
					target = this.chatPanel;
				else
					target = this.chatPanelMinimised;
				
				if (StringEdit.trim(target.txtChat.text) != "")
				{
					Main.sfs.send( new PublicMessageRequest(StringEdit.trim(target.txtChat.text), null, Main.sfs.joinedRooms[0]) );
	
					target.txtChat.text = "";
				}
			}
			else
			{
				Main.sfs.send( new PublicMessageRequest(msg, null, Main.sfs.joinedRooms[0]));
			}
		}
		
	}
	
}
