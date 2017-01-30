{*
/*********************************************************************************
 * SugarCRM Community Edition is a customer relationship management program developed by
 * SugarCRM, Inc. Copyright (C) 2004-2012 SugarCRM Inc.
 * 
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Affero General Public License version 3 as published by the
 * Free Software Foundation with the addition of the following permission added
 * to Section 15 as permitted in Section 7(a): FOR ANY PART OF THE COVERED WORK
 * IN WHICH THE COPYRIGHT IS OWNED BY SUGARCRM, SUGARCRM DISCLAIMS THE WARRANTY
 * OF NON INFRINGEMENT OF THIRD PARTY RIGHTS.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more
 * details.
 * 
 * You should have received a copy of the GNU Affero General Public License along with
 * this program; if not, see http://www.gnu.org/licenses or write to the Free
 * Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
 * 02110-1301 USA.
 * 
 * You can contact SugarCRM, Inc. headquarters at 10050 North Wolfe Road,
 * SW2-130, Cupertino, CA 95014, USA. or at email address contact@sugarcrm.com.
 * 
 * The interactive user interfaces in modified source and object code versions
 * of this program must display Appropriate Legal Notices, as required under
 * Section 5 of the GNU Affero General Public License version 3.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3,
 * these Appropriate Legal Notices must retain the display of the "Powered by
 * SugarCRM" logo. If the display of the logo is not reasonably feasible for
 * technical reasons, the Appropriate Legal Notices must display the words
 * "Powered by SugarCRM".
 ********************************************************************************/

*}
{php}	
	
	/*
	*	here licensing is being implemented to ensure that user has a validated license key to use this product
	*/
	
	$moduleName = "rolus_Twilio_Account";
	$account_bean = BeanFactory::getBean($moduleName);
	$account_bean->retrieve('1');	
	//if($account_bean->license_validator == true AND !empty($account_bean->license_key))
	if(isset($account_bean->license_validator))
	{
	
		$twilio_key = '49ad23bff7c9cb22652196f8c7b7889a';
		$user_key = $account_bean->license_key; // user input in settings
		$user_key = str_replace(' ', '', $user_key);
		$_REQUEST['key']=$user_key;
		require_once('modules/rolus_SMS_log/license/OutfittersLicense.php');
        $result = OutfittersLicense::validate(1);
    	if($result!='"Key does not exist."')
		//if(isset($statusCode) && ($statusCode=='200'))
		//if (true)
		{	
		{/php}
		{literal}
			<script type="text/javascript">					
				//$(".error_msgg").text("Validation: Successful").show().fadeOut(5000);					
				$(".call_maker").css({display:"block"});
			</script>				
		{/literal}	
		{php}
	// licensing if case ...
		if($GLOBALS['current_user']->voip_access == 'outbound' OR $GLOBALS['current_user']->voip_access == 'both')	
		{	
		/*$target_module = 'rolus_Twilio_Account';
		$class = $GLOBALS['beanList'][$target_module];
		require_once($GLOBALS['beanFiles'][$class]);
		$rolus_Twilio_Account = new $class();*/
		
		require_once("modules/rolus_Twilio_Account/rolus_Twilio_Account.php");
		$rolus_Twilio_Account = new rolus_Twilio_Account();
		
			
		try{
			$capability = $rolus_Twilio_Account->getCapability();
			$appsid = $rolus_Twilio_Account->getApplicationSid();	
			if(!(is_object($capability) && $capability instanceof Services_Twilio_Capability))
					throw new settingsException('Cannot connect to Twilio','3');
					
			$capability->allowClientOutgoing($appsid);
			$capability->allowClientIncoming($GLOBALS['current_user']->user_name);
			$token = $capability->generateToken();			
			
		} catch (communicaitonException $e) {		
			$GLOBALS['log']->fatal("Caught communicaitonException ('{$e->getMessage()}')\n{$e}\n");
		} catch (settingsException $e) {		
			$GLOBALS['log']->fatal("Caught settingsException ('{$e->getMessage()}')\n{$e}\n");
		} catch (Exception $e) {		
			$GLOBALS['log']->fatal("Caught Exception ('{$e->getMessage()}')\n{$e}\n");
		}
{/php}
		{literal}				
			<script type="text/javascript">									
							
			</script>
		{/literal}
{literal}
	<link type="text/css" rel="stylesheet" href="custom/include/call_css/style.css" />	
	<style type="text/css">	
	.phone_call_label
	{
		color:#FFFABF;
		font-weight:bold;
		font-size:16px;
	}
	.phone_value
	{
		font-size:12px;
		font-weight:bold;
		color:blue;
	}
	.phone_list
	{
		margin-left:-15px;		
		margin-top:0px;
		float:left;	
	}
	.phone_source
	{
		display:block;
		margin-left:20px;
		margin-top:-20px;
		padding:0;
		font:normal 24px/32px Arial, Helvetica, sans-serif;
		color:#333;
	}
	.call_maker	
	{
		width:20px;
		height:20px;
		border:none;
		float:right;
	}
	.phone_call_button
	{
		float:right;
		margin-top:25px;
		margin-right:30px;	
		cursor:default;	
	}
	.status_config
	{
		position:absolute;
		text-align:right;
		width:40px;
		float:right;
		margin-left:340px;
		margin-top:-10px;
		color:#32CD32;
		font-size:25px;
	}
	#sms_send
	{
		margin-right:5px;
	}
	#sms_type_switcher
	{
		position:absolute;
		margin-top:25px;
		margin-left:20px;
	}
	#SMSHandler_div
	{
		padding-top:10px;
	}		
	</style>
	<script type="text/javascript">
		/*
		*	This code snippet will dynamically add divs n update make call contents periodically(using long polling)
		*/
		var call_making_f = true; //for calls window
		var SMS_making_f = true; //for SMS window
		var sent_flag = false; // setting for sending sms only once 		
		var sms_callback = false; // setting for prompting user only once 
		var destination_number = ''; // both for Calls and SMS Conversation
		var source_number_SMS = ''; // only for SMS Conversation
		var SMS_window_open = false // check sms window is open or close
		var final_picked_date = ''; //use this flag to get the final date of the conversation to get the new SMS entered in database recently
		var call_sid = '';
		var ref_call_id = '';
		var call_status_timer=''; // for getting call's statuses
		var sms_fetch_history_timer = ''; // for getting SMS Conversation history from database
		var fetch_status_counter = 0;
		var destination_file = '';  //  variable for placing capability token to be used as  file name that will contain the destination number in case of browser to phone call
		var status_source_switch = false; // flag that will call the relevant function for getting final call status alternately after every 10 minutes
		var connection =''; // for creating new twilio device connection explicitly for making outbound browser to phone call				
		var browser_phone_call_sid = ''; // this will use as a custom call id generated on our side due to lackage of CallSid in twilio API for browser to phone call
		var plugin_initializer = '';
		var call_con_checker = false; 						
		var call_canceled = false; // this will become true when browser to phone call is being canceled by caller and not allowed to connect		
		var setupTimer = ''; // time interval after which our code will again call the twilio device setup method to validate the already generated token and make device ready for connections
		var setupTimeOut = 0; // time out interval after which code will alert that Twilio is not available
		//var call_div_opening = false;
		var deviceReady = false; //check if Twilio.Device.Ready listener is invoked
		var sourceSelected = false; //check if any of the source (number or browser) option is selected
		var isFlashInstalledError = false; //check if Flash Player is installed
		var smsIds= [];// containd ids of all sms in chat window
	</script>		
	<!--<script type="text/javascript" src="http://code.jquery.com/jquery-1.8.0.min.js"></script>-->
	<!--<script type="text/javascript" src="//static.twilio.com/libs/twiliojs/1.1/twilio.min.js"></script>-->
	<script type="text/javascript">			
		
		/*
		*	this will handle the outbound call via one of the phone numbers 
		*	configured for the currently logged-in user or through registered browser 
		*	for which there will be using twilio registered number also
		*/	
		
		$(document).ready(function(){	
		$(".call_maker").css({display:"block"});
		/*
		*	all this is the twilio call plugin class
		*/
		(function ($) {
			$.fn.callWindowStates = function (option) {				
				option = $.extend({}, $.fn.callWindowStates.option, option);				
					cw = $('#' + option.callsWrapper);
					cc = $('#' + option.callContents);
					sc = $('#' + option.callStatus);
					ct = $('#' + option.callType);
					tm = $('#' + option.twilioMessage);
					cd = $('.' + option.callDetails);
					cn = $('#' + option.callerName);
					cp = $('#' + option.callerPhone);
					acn = $('#' + option.addCallNotes);
					ma = $('#' + option.moreActions);
					map = $('#' + option.moreActionsPopup);
					ctd = $('#' + option.contactDetailLink);
					cld = $('#' + option.callDetailLink);
					cla = $('#' + option.callActionBtns);
					acl = $('#' + option.acceptCall);
					rcl = $('#' + option.rejectCall);
					ecl = $('#' + option.endCall);
					odis = $('#' + option.outDisabled);
					oen = $('#' + option.outEnabled);	
					cw.prepend('<img src="custom/include/call_images/twilio_icon.png"  id="RTLogo" />');		
					cw.prepend('<div class="windowActions" id="windowActions">');					
					wdActions = $('#windowActions');
					wdActions.append('<input type="button" title="Minimize" id="minimizeOperation" />');
					wdActions.append('<input type="button" title="Maximize" id="maximizeOperation" />');
					wdActions.append('<input type="button" title="Shading" id="shadeOperation" />');
					wdActions.append('<input type="button" title="Maximize" id="shadeMaxOperation" />');
					wdActions.append('<input type="button" title="Close" id="closeOperation" />');					
					
					$.fn.callSwitch(option.defaultState, option);

					minButton.click(function () {
						$.fn.callSwitch('min', option);
						
					});
					
					maxButton.click(function () {
						$.fn.callSwitch('max', option);
						if(cd.children().hasClass('actionBox')){
							ma.children().remove();
						}
						else
						cd.prepend(map);
					});
					
					shadeButton.click(function () {
						$.fn.callSwitch('shade', option);
						
					});
					
					shadeMaxButton.click(function () {									
						$.fn.callSwitch('shademax', option);
						if(cd.children().hasClass('actionBox')){
							ma.children().remove();
						}
						else
						cd.prepend(map);
					});
					
					closeButton.click(function () {
						$.fn.callSwitch('close', option);
					});											
			};

			$.fn.callWindowStates.option = {
				defaultState: 'min',
				callsWrapper: 'callWrapper',
				callContents: 'callContent',
				callStatus: 'callStatus',
				callType: 'callType',
				twilioMessage: 'outbound_log',
				callDetails: 'callDetailLink',
				callerName: 'callerName',
				callerPhone: 'callerPhone',
				addCallNotes: 'outbound_call_points_div',
				callActionBox: 'moreActions',
				contactDetailLink: 'contDetailLink',
				callDetailLink: 'outbound_call_detail',
				callActionBtns: 'callHandler_div',
				acceptCall: 'acceptCall',
				rejectCall: 'rejectCall',
				endCall: 'browser_endcall',
				outDisabled: 'outboundDisabled',
				outEnabled: 'source_call',
				moreActions: 'moreActions',
				moreActionsPopup: 'moreActionsPopup'
			};
			
			$.fn.callSwitch = function (state, option) {
				
				if(state == 'min' || state == 'shade'){
					ma.append(map);
				}
				else					
				closeButton = $('#closeOperation');
				maxButton = $('#maximizeOperation');
				shadeMaxButton = $('#shadeMaxOperation');
				minButton = $('#minimizeOperation');
				shadeButton = $('#shadeOperation');
				callpointsdiv = $('#outbound_call_points_div');
				switch (state) {
					case "max":
						cw.attr('class', option.callsWrapper);
						cw.show();						
						minButton.show();
						maxButton.hide();
						shadeButton.show();
						shadeMaxButton.hide();
						ct.show();
						acn.show();
						callpointsdiv.hide();						
						$("#source_numbers_div").show();
						$('#callWrapper').css({top:"60%"});
						if(call_con_checker == true)
						{
							$("#outbound_call_points_div").show();	
							$(".call_maker").attr("disabled","disabled");										
						}
						else if(call_con_checker == false)
						{
							$(".call_maker").removeAttr("disabled");
						}				
						break;
					case "min":
						if(call_con_checker == true)
						{								
							$("#minimizeOperation").removeAttr("disabled");														
							cw.attr('class', option.callsWrapper + 'minimized');
							cw.show();						
							maxButton.hide();
							shadeButton.show();
							shadeMaxButton.show();
							minButton.hide();
							ct.show();
							acn.hide();
							$(".call_maker").attr("disabled","disabled");
							$("#outbound_call_points_div").hide();
							$("#source_numbers_div").hide();
							$('#callWrapper').css({top:"96%"});
						}
						else if(call_con_checker == false)
						{
							//$("#minimizeOperation").attr({disabled:"disabled"});							
							$(".call_maker").removeAttr("disabled");
						}
						break;
					case "shade":
						if(call_con_checker == true)
						{							
							$("#shadeOperation").removeAttr("disabled");
							cw.attr('class', option.callsWrapper + 'shaded');
							cw.show();						
							minButton.show();
							maxButton.hide();
							shadeButton.hide();
							shadeMaxButton.show();
							ct.hide();
							acn.hide();
							ct.show();
							$(".call_maker").attr("disabled","disabled");
							$("#outbound_call_points_div").hide();
							$("#source_numbers_div").hide();
							$('#callWrapper').css({top:"97%"});
						}
						else if(call_con_checker == false)
						{
							//$("#shadeOperation").attr({disabled:"disabled"});
							$(".call_maker").removeAttr("disabled");
						}
						
						break;
					case "shademax":
						cw.attr('class', option.callsWrapper);
						cw.show();						
						minButton.show();
						maxButton.hide();
						shadeButton.show();
						shadeMaxButton.hide();
						ct.show();
						acn.show();
						callpointsdiv.hide();
						$('#callWrapper').css({top:"60%"});													
						$("#source_numbers_div").show();	
						if(call_con_checker == true)
						{
							$("#outbound_call_points_div").show();															
							$(".call_maker").attr("disabled","disabled");
						}
						else if(call_con_checker == false)
						{
							$(".call_maker").removeAttr("disabled");
						}	
						break;	
					case "close":
					cw.hide();												
					$(".call_maker").removeAttr("disabled");		
					$('input:radio[name=sourcenumbers]').removeAttr("disabled"); // removing the disabled attribute from the source numbers radio buttons
					if(call_con_checker == true)
					{
						connection.disconnect();
					}	
					makingCallDiv();//hiding or removing the created div					
				}
			}
		})(jQuery);
		
	//// twilio Call plugin code ended
	
		/*
		*	all this is the twilio SMS plugin class
		*/
		(function ($) {
			$.fn.SMSWindowStates = function (option) {				
				option = $.extend({}, $.fn.SMSWindowStates.option, option);				
					cw = $('#' + option.SMSWrapper);
					cc = $('#' + option.SMSContent);
					ct = $('#' + option.smsType);
					tm = $('#' + option.twilioMessage);					
					wsms = $('#' + option.writeSMSDiv);
					ma = $('#' + option.moreActions);									
					cla = $('#' + option.SMSActionBtns);
					ecl = $('#' + option.source_sms);
					oen = $('#' + option.outboundEnabled);	
					cw.prepend('<img src="custom/include/call_images/twilio_icon.png"  id="RTLogo" />');		
					cw.prepend('<div class="windowActionsSMS" id="windowActionsSMS">');					
					wdActions = $('#windowActionsSMS');
					/*wdActions.append('<input type="button" id="minimizeOperationSMS" />');
					wdActions.append('<input type="button" id="maximizeOperationSMS" />');
					wdActions.append('<input type="button" id="shadeOperationSMS" />');
					wdActions.append('<input type="button" id="shadeMaxOperationSMS" />');*/
					wdActions.append('<input type="button" title="Close" id="closeOperationSMS" />');					
					
					$.fn.SMSSwitch(option.defaultState, option);
					
					maxButton.click(function () {
						$.fn.SMSSwitch('max', option);
						if(cd.children().hasClass('actionBox')){
							ma.children().remove();
						}
						else
						cd.prepend(map);
					});
					
					closeButton.click(function () {
						$.fn.SMSSwitch('close', option);
					});											
			};

			$.fn.SMSWindowStates.option = {
				defaultState: 'min',
				SMSWrapper: 'SMSWrapper',
				SMSContent: 'SMSContent',
				smsType: 'smsType',
				twilioMessage: 'sms_log',								
				writeSMSDiv: 'outbound_SMS_write_div',
				callActionBox: 'sms_type_switcher',				
				SMSActionBtns: 'SMSHandler_div',				
				source_sms: 'source_sms',
				outEnabled: 'source_sms',
				moreActions: 'moreActions',				
			};
			
			$.fn.SMSSwitch = function (state, option) {
				if(state == 'min' || state == 'shade'){
					ma.append(map);
				}
				else
				closeButton = $('#closeOperationSMS');
				maxButton = $('#maximizeOperationSMS');				
				switch (state) {
					case "max":
						cw.attr('class', option.callsWrapper);
						cw.show();										
						ct.show();
						wsms.show();												
						$('#SMSWrapper').css({top:"60%"});				
						break;
					case "close":
					SMS_window_open = false;	
					cw.hide();									
					makingSMSDiv();//hiding or removing the created div					
				}
			}
		})(jQuery);	
		
		//// twilio SMS plugin code ended	
		/*
		*	setup a client-browser device after registering
		*/	
		
		window.onload = function settingUpTwilioDevice() {
				twilioDeviceSetup();
		}
		
		/*
		*	this function will check that if twilio JS library is not loaded in web page then inform end user 
		*	if loaded then verfiy the twilio capability token to make device capable to make outbound call and receive incoming call
		*/
		function twilioDeviceSetup() {	
			
			if(!window.Twilio)
			{
				alert("Twilio Library is not loaded, Reload Page or Contact to Network Administrator");				
			}
			else
			{
				setupTimer = setInterval(function() {					
					{/literal}
					
					{php}
						if($_REQUEST['debug'] == 'true')	
						{
					{/php}					
					{literal}
						
						console.log("with js and php debug ");
						console.log("Twilio Device Setup");
						var Setup_res = Twilio.Device.setup("{/literal}{php} echo $token; {/php}{literal}",{debug : true}); 
						console.log("Twilio Device Setup returned => "+Setup_res);
						
					{/literal}
					{php}
						}
						else
					{/php}
					
					{literal}
						var Setup_res = Twilio.Device.setup("{/literal}{php} echo $token; {/php}{literal}"); 																	
					if(Setup_res != null) // means the token has verified perfectly and twilio is ready to initiate call by returning verified Device Object
					{						
						$('#outbound_log').text('Running Device Setup');
						clearInterval(setupTimer);//to stop the timer or setInterval()
					}
					else
					{						
						setupTimeOut +=1;
						if(setupTimeOut == 120) //
						{
							alert("Twilio is not available, Refresh Page");
							clearInterval(setupTimer);//to stop the timer or setInterval()
							setupTimeOut = 0;
							$('#outbound_log').text('Invalid Connection,Refresh Page');			
						}							
					}					
				}, 1000);
			}// end else case in which twilio token authentication is verified	
			is_adobe_flash_installed();
		}// end twilio device capability token verification function	
			
		

		/*
		*	enabling click to call button for making call on checked radio button source number
		*/
	$(document).on('click','input:radio[name=sourcenumbers]',function(){
			if(deviceReady){
				enableCallButton();
			}
			else{
				sourceSelected = true;
			}
		});	
				
});	//ending $(document).ready(function(){}); //necessory for twilio initial functions for configuring sound device for outbound call via firefox
		function enableCallButton(){
			$('#source_call').attr({class:"outboundEnabled"});
			$('#source_call').removeAttr('disabled');
			$('#source_call').css({cursor:'pointer'});				
			$("#outbound_call_detail").css({display:"none"});
		}
		/*
		*	this will save the key points of current call in db during established call status
		*/	
		function saveNote(){
			var outbound_callpoints = $("#outbound_call_points").val();	
			$.ajax({	
				url:"index.php",
				type:"POST",
				dataType:"html",
				data:"module=Calls&action=outbound_call_recording&sugar_body_only=true&call_points="+outbound_callpoints+"&RefCallId="+ref_call_id,
				async:true,
				cache:false,
				success:function(response){	
					if(response == "true")
					{
						$("#call_points_save_status").text("saved").show().fadeOut(2000);
					}
				},
				error:function(jqXHR,textStatus,errorThrown)
				{
					if(jqXHR.readyState == 0)
					{
						alert("Internet Connection Problem");						
					}
					else
					{
						console.log("Error Occurred on Server side (while saving call points) :"+textStatus);
					}								
				}					
			});		
		}
</script>
<script type="text/javascript">
		/*
		*	this will make outbound browser call by connecting twilio device
		*/
		function call_from_browser()
		{
			call_canceled = false; // reset the flag before starting a new call without page refresh
			var dest_number = destination_number.replace("%2B","+");								
			connection = Twilio.Device.connect({"destination":dest_number,"RefCallId":ref_call_id,debug : true}); //optional param{} arguments (javascript object) send to your application (post/get)						
		}
		
		/*
		*	this will update the operator/user status in db to busy(executing call)
		*/
		function set_operator_status_busy()
		{
			$.ajax({
				url: 'index.php',
				type: 'POST',
				data:'module=Users&action=call_establish&sugar_body_only=true&connect=true',
				dataType: 'html',
				async: true,
				cache: false,		
				success: function(response){				
					//if(data){}				
				},
				error: function(jqXHR,textStatus,errorThrown)
				{			
					if(jqXHR.readyState == 0)
					{
						alert("Internet Connection Problem, Connect Internet within 10 to 15 otherwise Call will be disconnected!");						
					}
					else
					{
						console.log("Problem occurred on Server side(connect call ) : "+textStatus); 
					}					
				}
			});
			
			establish_browser_call();//update call status to established				
		}
		
		/*
		*	this will update the operator/user status in db to available(free to accept call)
		*/
		function set_operator_status_available()
		{
			$.ajax({
				url: 'index.php',
				type: 'POST',
				data:'module=Users&action=call_establish&sugar_body_only=true&connect=false',
				dataType: 'html',
				async: true,
				cache: false,
				success: function(response){
					//if(data){}				
				},
				error: function(jqXHR,textStatus,errorThrown)
				{
					if(jqXHR.readyState == 0)
					{
						alert("Internet Connection Problem");						
					}
					else
					{
						console.log("Problem Occur on Server side (disconnect call) : "+textStatus);
					}					
				}			
		   });		   
		}

		/*
		*	this will hangup the currently made call through browser
		*/
		function hangup_browser_call()
		{			
			$("#outbound_call_points_div").css({display:"none"});		
			$("#browser_endcall").css({display:"none"});
			$("#source_call").attr({class:"outboundDisabled"});
			$("#source_call").attr({disabled:"disabled"});
			$("#source_call").css({cursor:"default"});
			$("#source_call").css({display:"block"});		
			if(connection.status() == "pending")
			{
				connection.cancel({debug : true}); // cancel the current outbound pending connection 
			}	
			if(connection.status() == "closed")
			{								
				call_canceled = true; // it means call is canceled
			}
			else if(connection.status() == "open")
			{				
				connection.disconnect();					
			}	
		}
		
		/*
		*	this function will update the status of browser to phone call record to db and set to dialed
		*/
		function establish_browser_call()
		{						
			$.ajax({
				url:"index.php",
				type:"POST",
				dataType:"html",
				data:"module=Calls&action=outbound_call&sugar_body_only=true&call_status=dialed&RefCallId="+ref_call_id,
				async:true,
				cache:false,
				success:function(twilio_call_id)
				{								
					/*getting the twilio call id from db that was inserted in db in response of call back from twilio server
						during browser to phone call for performing any related further tasks*/										
				},
				error:function(jqXHR,textStatus,errorThrown)				
				{
					if(jqXHR.readyState == 0)
					{
						alert("Internet Connection Problem, Connect Internet within 10 to 15 otherwise Call will be disconnected!");						
					}
					else
					{
						console.log("error occurred on server side :(while updating call status to dialed)"+textStatus);
					}					
				},				
			});			
		}
		
		/*
		*	this function will update the status of browser to phone call record to db and set to Held
		*/
		function end_browser_call(final_call_status)
		{			
			$.ajax({
				url:"index.php",
				type:"POST",
				dataType:"html",
				data:"module=Calls&action=outbound_call&sugar_body_only=true&call_status="+final_call_status+"&RefCallId="+ref_call_id,
				async:true,
				cache:false,
				success:function(final_browser_call_status)
				{			
					// successful entry of browser to phone end call final status
				},
				error:function(jqXHR,textStatus,errorThrown)				
				{
					if(jqXHR.readyState == 0)
					{
						alert("Internet Connection Problem");						
					}
					else
					{
						console.log("error occurred on server side :(while updating call status to Held)");
					}					
				},				
			});
		}	
		
		/*
		*	this will make call div dynamically n destroy that if no needed
		*/
		function makingCallDiv() {			
			if (document.getElementById('outbound_call_div')) 
			{
				//code if element exists
			} 
			else { //code if element doesn't exist
				var newdiv = document.createElement('div');// creating new div element
				newdiv.setAttribute("id", "outbound_call_div"); //setting ID attribute of newly created div-element				
				document.body.appendChild(newdiv); // always appending newly created element at the last of the Body tag (for appending at desired place use other JS Apis)							
			}						
			toggle_diaplay();
		}
		
		/*		
		*	making call div displayed or hidden
		*/
		function toggle_diaplay() {
			call_making_f = !call_making_f;// make it false, if true
			if (call_making_f) {
				call_window_disappear();
			} else {
				call_window_appear();
			}			
		}
		
		/*
		*	making the calling div inside the newly created div
		*/
		function call_window_appear() {			
			obj = document.getElementById('outbound_call_div');
			var calling_div = '<div class="callWrapper" id="callWrapper" style="top:60%;position:fixed;" >';			
			calling_div += '<div class="callContent">';
			if(deviceReady){
				calling_div += '<div class="callStatus"><h1 id="callType" >Outbound Call</h1><h2 id="outbound_log" class="yellow">Ready</h2></div>';
			}
			else if(isFlashInstalledError){
				calling_div += '<div class="callStatus"><h1 id="callType" >Outbound Call</h1><h2 id="outbound_log" class="yellow">Unable to connect, Flash Player needed</h2></div>';
			}
			else{
				calling_div += '<div class="callStatus"><h1 id="callType" >Outbound Call</h1><h2 id="outbound_log" class="yellow">Wait! Establishing Connection</h2></div>';
			}
			calling_div += '<div id="source_numbers_div" class="callDetail">';
			/// adding the source numbers radio buttons for selection in "H3" html element		
			calling_div += '<div id="outbound_call_points_div" style="display:none;" class="input">';
			calling_div += '<label>Add Note:</label>';
			calling_div += '<div id="call_points_save_div" ><span class="status_config" id="call_points_save_status"></span></div>';
			calling_div += '<textarea id="outbound_call_points" ></textarea>';
			calling_div += '<input type="button" id="save_outbound_call_points" value="Save" onclick="saveNote();"/>';		
			calling_div += '</div>'; //end  outbound_call_points_div 
			
			calling_div += '</div>'; //end callDetail div
			
			calling_div += '<div id="callHandler_div" class="callAction">';						
			calling_div += '</div>'; //end callAction div
			
			calling_div += '</div>'; //end callContent div			
			calling_div += '</div>'; //end callWrapper div
			
			obj.innerHTML = calling_div;
			obj.style.display = 'block';		
		}
		
		/*
		*	making the call div hidden upon clicking the close button
		*/
		function call_window_disappear() {			
			obj = document.getElementById('outbound_call_div');			
			obj.innerHTML = '';
			obj.style.display = 'none';
			document.body.removeChild(obj);
		}
	
		/*
		*	this will take fetched source numbers from server side n display them on call div dynamically
		*/
		function outbound_source_numbers_UI(source_numbers,plugin_initializer)
		{			
			var html_radio = '<h3 style="color:#32CD32;text-align:center;margin-top:-5px;">Select Source to Call</h3>';
			html_radio += '<ul class="phone_list">';
			if(source_numbers.source == "false")
			{
				html_radio += '<li style="color:#32CD32;" >Source not configured!</li>';
				html_radio += '<li ><a href="{/literal}{php} print $GLOBALS["sugar_config"]["site_url"]."/index.php?module=rolus_Twilio_Account"; {/php}{literal}" target="_blank" style="display:block;margin:0px;padding:0px;color:#333;font:normal 24px/32px Arial, Helvetica, sans-serif;" ><h3>Configure Number!</h3></a></li>';
				html_radio += '</ul>';		
			}
			else if(source_numbers.source == "browser")//means only twilio source number is configured
			{
				html_radio += '<li ><input type="radio" name="sourcenumbers" id="from_browser" value="browser" ><span class="phone_source" style="color:#32CD32;" >From Browser</span></li>';	
				html_radio += '</ul>';		
				var outbound_call_button = '<input type="button" class="outboundDisabled" disabled="disabled" style="cursor:default;" id="source_call" title="Click To Call" onclick="get_ref_id_from_sugar()" >';		
				outbound_call_button += '<input type="button" class="endCall" style="display:none;" id="browser_endcall" title="Click To Hangup" onclick="hangup_browser_call()" >';		
				outbound_call_button += '<a href="#" id="outbound_call_detail" title="Call Detail" style="display:none;" target="_blank" class="moreActions enable"></a>';
			}
			else ////means only user source & twilio numbers are configured
			{
				$.each(source_numbers,function(key,value){
					if(value)
					{
						html_radio += '<li ><input type="radio" name="sourcenumbers" id="'+key+'" value="'+value+'" ><span class="phone_source" >'+value+'</span></li>';	
					}	
				});
				html_radio += '<li ><input type="radio" name="sourcenumbers" id="from_browser" value="browser" ><span class="phone_source" style="color:#32CD32;" >From Browser</span></li>';	
				html_radio += '</ul>';		
				var outbound_call_button = '<input type="button" class="outboundDisabled" disabled="disabled" style="cursor:default;" id="source_call" title="Click To Call" onclick="get_ref_id_from_sugar()" >';		
				outbound_call_button += '<input type="button" class="endCall" style="display:none;" id="browser_endcall" title="Click To Hangup" onclick="hangup_browser_call()" >';						
				outbound_call_button += '<a href="#" id="outbound_call_detail" style="display:none;" target="_blank" class="moreActions enable" ></a>';				
			}	
				
			$("#outbound_call_points_div").before(html_radio);
			$("#callHandler_div").html(outbound_call_button);							
			$(plugin_initializer).callWindowStates({
				defaultState		:	'max' //// max, min, shade 
			});			
			$("#outbound_call_div").children().eq(0).show();						
		}
		
		/*
		*	this will check the source or destination phone number whether it consists on repetition of any single digit or not
		*	returns true upon repetition and false otherwise
		*/
		function is_repeated_digit(phone_number)
		{
			var arr = '';
			arr = phone_number.split(''); //convert string to array
			var freq_of_num = 0;
			var rep_num ='';
			for(var i=0;i<arr.length;i++)
			{
				if(freq_of_num == 0)
				{
					rep_num = arr[i];
					freq_of_num++;
				}
				else if(freq_of_num >0)
				{
					if(arr[i]== rep_num)
					{
						freq_of_num++;
					}
					rep_num = arr[i];
				}
			}
			if(freq_of_num >= 6)
			{
				return true;        
			}
			else
			{
				return false;
			}
		}
		
		/*
		*	this will remove the special characters in the phone number n formate it accordingly
		*/
		function process_number(destination)
		{
			dest_number ='';
			dest_original = destination;
			dest_num = destination.replace(/[^0-9]/g,'');		
			if(dest_num.substr(0,2) == "00") 
			{
				dest_number = dest_num.replace("00","+");
				if(dest_number.length < 8 || is_repeated_digit(dest_number)) ///check for invalid number
				{				
					dest_number = false;
				}
			}
			else if(dest_original.substr(0,1) == "+")
			{
				dest_number = "+"+dest_num;
				if(dest_number.length < 8 || is_repeated_digit(dest_number))///check for invalid number(include alphabetical or alphanumerical phone number or single digit repeated phone number)
				{
					dest_number = false;
				}
			}
			else
			{
				if(dest_num.length < 6 || is_repeated_digit(dest_num))///check for invalid number
				{
					dest_number = false;
				}
				else
				{
					{/literal}
					{php} 
						require_once('modules/Administration/Administration.php');
						$admin = new Administration();
						$admin->retrieveSettings(); //will retrieve all settings from db
						$twilio_country_code = $admin->settings['MySettings_twilio_country_code'];
					{/php}
					{literal}			
					if (dest_num.substr(0,1) == "1" ){
						dest_number = "+"+dest_num;
					}
					else{
						dest_number = {/literal}{php} echo json_encode($twilio_country_code); {/php}{literal}+dest_num;
					}
				}
			}
			return dest_number;
		}
		
		/*
		*	this will make the call to the number passed to it
		*	this is also the parent function for making outbound call(via traditional phone or via browser)
		*/
		function make_call(destination,init_plugin_obj)
		{
			$(".call_maker").attr("disabled","disabled"); // disable all other buttons to make call while current one is in active state
			$("#phone_fax").attr("disabled","disabled"); // disable all other buttons to make call while current one is in active state
			plugin_initializer = init_plugin_obj; // placing the plugin trigger object			
			destination_number = process_number(destination);			
			if(destination_number == false)
			{
				alert("Invalid Destination Number ");
				$(".call_maker").removeAttr("disabled");	
				$("#phone_fax").removeAttr("disabled");	
			}
			else
			{
				makingCallDiv();//this will create dynamic div for making outbound call			
							
				$.ajax({//ajax call that will fetch all available source numbers of the caller saved in Sugar n saved in array or Object to become available for user to select source for making call
					url:"index.php",
					type:"POST",
					dataType:"json",
					data:"module=Users&action=fetch_source_numbers&sugar_body_only=true",
					async:true,
					cache:false,
					success:function(source_numbers)
					{
						outbound_source_numbers_UI(source_numbers,plugin_initializer);
						$("#minimizeOperation").hide();
						$("#shadeOperation").hide();					
					},
					error:function(jqXHR,textStatus,errorThrown)
					{
						if(jqXHR.readyState == 0)
						{
							alert("Internet Connection Problem");						
						}
						else
						{
							console.log("Error Occurred at server side(getting source numbers) : "+textStatus);						
						}
						
					}			
				});	
			}
		}
		
		/*
		*	this function will update the status of browser to phone call record to db and set to dialed
		*	this will save initial outbound record call to db
		*/
		function init_outbound_call(call_response)
		{
			/* twilio will return RestException Object when there occurred a problem with call making */
			if(call_response.ResponseXml.RestException)
			{
				$('#outbound_log').text("Call Failed");					
				var twilio_exception = call_response.ResponseXml.RestException;	
				alert(twilio_exception.Message+" "+"Refresh Page to make Call");				
			}
			else
			{
				call_con_checker = true;
				var Call_Sid = call_response.ResponseXml.Call.Sid;
				if(Call_Sid != "" || Call_Sid != null)
				{	
					related_id = "{/literal}{php}echo $_REQUEST['record'];{/php}{literal}";
					related_module = "{/literal}{php}echo $_REQUEST['module'];{/php}{literal}";
					call_sid = Call_Sid;
					
					$.ajax({
						url:"index.php",
						type:"POST",
						dataType:"html",
						data:"module=Calls&action=outbound_call&sugar_body_only=true&call_sid="+call_sid+"&RelatedModule="+related_module+"&RelatedId="+related_id+"&RefCallId="+ref_call_id,
						async:true,
						cache:false,
						success:function(initial_call_status)
						{
							if(initial_call_status == "call_initiated")// means call is initiated not answered yet
							{							
								timeout_init();//starting the setTimeout function to execute after every 10 seconds									
							}
						},
						error:function(jqXHR,textStatus,errorThrown)
						{
							if(jqXHR.readyState == 0)
							{
								alert("Internet Connection Problem");						
							}
							else
							{
								console.log("Error Occurred on Server side:(establishing call)!"+textStatus);
							}						
						}							
					});
				} // end inner if condition while checking the callsid
			}	
		}
		
		// this will actually make outbound call between source n destination 
		function call_from_source(source,destination_number)
		{
			$("#source_call").css({display:"none"});
			$("#browser_endcall").css({display:"none"}); 
			
			source = process_number(source);//process number for presence of the country code also
			if(source == false)
			{
				alert("Invalid Source Number");
			}
			else
			{	
				$('#outbound_log').text("Dialing...");					
				source_num = source.replace("+","%2B"); //encoding + character													
				destination_number = destination_number.replace("+","%2B"); //encoding + character													
				$.ajax({ 
					url:"index.php",
					type:"POST",
					dataType:"json",
					data:"module=Calls&action=make_outbound_call&sugar_body_only=true&source="+source_num+"&destination="+destination_number,
					async:true,
					cache:false,
					success:function(call_response)					
					{
						init_outbound_call(call_response);
					},
					error:function(jqXHR,textStatus,errorThrown)
					{						
						if(jqXHR.readyState == 0)
						{
							alert("Internet Connection Problem");						
						}
						else
						{
							console.log("Error Occurred at Server side(making call from source to source)");							
						}												
					}
				});	
			}			
		}
		
		/**
		*	This will make the call after twilio credentials verification and 
		*	Application Sid verification to make outbound call
		*/
		function call_making_with_verified_twilio_creds(is_verified)
		{
			if(is_verified == true) // initiate call only when twili call account settings are correct 
			{
				var source = $('input:radio[name=sourcenumbers]:checked').val();//getting value of the checked radio button											
				
				if(source != "browser")
				{
					source = process_number(source);
				}			
				source_num = source.replace("+","%2B");
				destination_num = destination_number.replace("+","%2B");
		
				if(source_num == destination_num)
				{
					alert("You are not allowed to make Call to same Destination number !");
					$(".call_maker").removeAttr("disabled");
					$("#phone_fax").removeAttr("disabled");
				}
				else if(source == false)
				{
					alert("Invalid Source Number");
					$(".call_maker").removeAttr("disabled");
					$("#phone_fax").removeAttr("disabled");
				}
				else
				{
					$('input:radio[name=sourcenumbers]').attr("disabled","disabled"); // disabling the selection of other radio button when one selected and pressed to make call
					
					related_id = "{/literal}{php} echo $_REQUEST['record'];{/php}{literal}";//current module's record id
					related_module = "{/literal}{php}echo $_REQUEST['module'];{/php}{literal}";				
					$.ajax({
						url:"index.php",
						type:"POST",
						dataType:"html",
						data:"module=Calls&action=outbound_call&sugar_body_only=true&RelatedModule="+related_module+"&RelatedId="+related_id+"&source="+source_num+"&destination="+destination_num+"&call_status=dialing",
						async:true,
						cache:false,
						success:function(sugar_call_id)
						{
							ref_call_id = sugar_call_id;
							make_outbound_call(ref_call_id);
						},
						error:function(jqXHR,textStatus,errorThrown)
						{
							if(jqXHR.readyState == 0)
							{
								alert("Internet Connection Problem");						
							}
							else
							{
								console.log("Error Occurred on server side(getting ref call id from sugar) :"+textStatus);
							}					
						}				
					});
				}//end inner if case
			}// end outer if case 
		}// end function 
		
		
		/**
		*	this will allow to send and receive sms messages after vrifying 
		*	twilio Account Sid , Auth Token and Application Sid
		*/
		function sms_sending_with_verified_twilio_creds(is_verified)
		{
			if(is_verified == true)
			{
				if($("#sms_message").val() == '')
				{
					return false;
				}
				else
				{				
					var sms_text_encodable = $("#sms_message").val();
					//var sms_text = encodeURIComponent(sms_text_encodable);// url encoding a message string					
					//var sms_text = escape(sms_text_encodable);// url encoding a message string										
					var sms_text=window.btoa(document.getElementById('sms_message').value);
					$("#sms_message").val('');	// use to get empty textarea to represent message is sent and will display in the history div later on in response of the long polling ajax call 
					if(sent_flag == false) //setting to send sms only once
					{
						sent_flag = true;
						sms_text  = encodeURIComponent(sms_text);
						$("#sms_log").text("Sending...");
						if(destination_number == false)
						{
							alert("Invalid destination number or twilio settings");
							sent_flag = false;															
							$("#sms_log").text("Failed");
						}
						else{
							$.ajax({//ajax call that will fetch all available source numbers of the caller saved in Sugar n saved in array or Object to become available for user to select source for making call
								url:"index.php",
								type:"POST",
								dataType:"html",
								data:"module=rolus_SMS_log&action=save&sugar_body_only=true&source_number="+source_number_SMS+"&destination_number="+destination_number+"&sms_text="+sms_text+"&direction=outgoing",
								async:true,
								cache:false,
								success:function(response)
								{
									if(response == "failed")
									{
										console.log('destination number is :'+destination_number);
										console.log('source number is :'+source_number_SMS);
										alert("Invalid destination number or twilio settings");
										sent_flag = false;															
										$("#sms_log").text("Failed");	
									}
									if(response == "sent")
									{
										sent_flag = false;															
										$("#sms_log").text("Sent");	
									}						
								},
								error:function(jqXHR,textStatus,errorThrown)
								{
									if(jqXHR.readyState == 0)
									{
										alert("Internet Connection Problem");						
									}
									else
									{
										console.log("Error Occurred at server side(sending Outbound SMS) : "+textStatus);
									}							
								}			
							});
						}				
					}
					return true;
				}						
			}			
		}
		
		/*
		*	this will verify the twilio call credentials by sending request to twilio before attempting to call
		*/
		function check_twilio_creds(is_call)
		{
			var is_verified = false;	
			if(sms_callback == false)
			{
				sms_callback = true;	
				$.ajax({
					url:"index.php",
					type:"POST",
					dataType:"json",
					data:"module=Calls&action=twilio_creds_verification&sugar_body_only=true",
					async:true,
					cache:false,
					success:function(is_twilio_verify)
					{										
						/*when twilio credentials are correct and application sid is correct */
						if(is_twilio_verify.twilio_creds == true && is_twilio_verify.appsid == true)
						{						
							is_verified = true;							
						}
						/*when twilio credentials are correct and application sid is invalid */
						else if(is_twilio_verify.twilio_creds == true && is_twilio_verify.appsid != true)
						{						
							is_verified = false;
							alert(is_twilio_verify.appsid);							
						}
						/*when twilio Server is unavailable or twilio credentials are invalid*/
						else
						{						
							is_verified = false;
							alert(is_twilio_verify.twilio_creds);							
						}	
						sms_callback = false; // to reset the error prompt window flag					
						if(is_call == true)//is_call == false means verify twilio creds before making call
						{
							/* it will initiate the call mainly after checking the twilio creds result */
							call_making_with_verified_twilio_creds(is_verified);	
						}
						else // is_call == false means now need verify twilio creds before sending sms
						{								
							sms_sending_with_verified_twilio_creds(is_verified);							
						}
						
						
					},
					error:function(jqXHR,textStatus,errorThrown)
					{						
						if(jqXHR.readyState == 0)
						{
							alert("Internet Connection Problem");						
						}
						else
						{
							console.log("Error Occurred on server side(verifying creds from twilio) :"+textStatus);
						}					
					}				
				});	
			}
		}
		
		/*
		*	this will make initial sugar call and return ref id of currently inserted call record
		*	for tracking outbound logging	
		*	this will also check source number for the availability of the country code	
		*/
		function get_ref_id_from_sugar()
		{	
			check_twilio_creds(true); // it will check before making call whether they are set and true									
		}
		
		/*
		*	this will actually call functions for making outbound call from the selected source or through browser(by radio button)
		*/
		function make_outbound_call(ref_call_id)
		{	
			var source = $('input:radio[name=sourcenumbers]:checked').val();//getting value of the checked radio button									
			if(source == "browser")
			{
				$("#source_call").css({display:"none"});
				$("#browser_endcall").css({display:"block"}); 
				$("#outbound_call_points_div").css({display:"block"});				
				$('#outbound_log').text("Dialing...");		
				call_from_browser();
			}
			else
			{
				$("#outbound_call_points_div").css({display:"block"});				
				//call_con_checker = true;
				call_from_source(source,destination_number);//make outbound call between source n destination 			
			}
		}
		
		//initiating the client side timer for getting final call status
		function timeout_init()
		{
			call_status_timer = setTimeout("timeout_trigger()",2000); // setting the timeout_trigger after every 5 seconds
		}
		
		// this will trigger the get_call_final_status_db function after every 10-Seconds to get final call status
		function timeout_trigger()
		{	
			if(status_source_switch == false)  
			{				
				get_call_final_status_twilio();//for testing purposes
			}
			else
			{				
				get_call_final_status_db();//for testing purposes
			}
		}
				
		// this will clear the current timeout timer after getting appropriate status
		function stop_status_getter()
		{
			clearTimeout(call_status_timer);
		}
		
		// this will try to get final outbound call status from DB on its turn, if not found, then status will be gotten from twilio server
		function get_status_from_db(call_sid)
		{
			// ajax call that will fetch the final call status(Held or canceled or rejected or busy)
			$.ajax({
				url:"index.php",
				type:"POST",

				dataType:"html",
				data:"module=Calls&action=outbound_endcall_status&sugar_body_only=true&source=db&call_sid="+call_sid,
				async:true,
				cache:false,
				success:function(final_call_status_db)
				{					
					if(final_call_status_db == "dialing" || final_call_status_db == "queued")
					{						
						$("#outbound_log").text("Dialing...");
						call_status_timer = setTimeout("timeout_trigger()",5000);
					}
					else if(final_call_status_db == "busy")
					{
						$("#outbound_log").text("Busy, Try Later");				
						//if first time call ends , re-arrange the getting status from sources(twilio/db) 
						if(status_source_switch == true)
						{
							status_source_switch = false;
						}
						stop_status_getter();
					}
					else if(final_call_status_db == "dialed")
					{
						$("#outbound_log").text("Dialed");						
						call_status_timer = setTimeout("timeout_trigger()",5000);
					}				
					else //means final call status has updated n now display to caller or user
					{
						if(final_call_status_db == "Held")// to place the call log in history sub panel
						{
							$("#outbound_log").text("Call Ended");					
						}
						else
						{
							$("#outbound_log").text(ucfirst(final_call_status_db));											
						}
						$("#outbound_call_points_div").css({display:"none"});
						call_con_checker = false;
						$("#browser_endcall").css({display:"none"}); 
						$("#browser_endcall").attr({disabled:"disabled"});
						$("#source_call").attr({class:"outboundDisabled"});
						$("#source_call").css({cursor:"default"});
						$("#source_call").attr({disabled:"disabled"});
						$("#source_call").css({display:"block"});					
						$("#outbound_call_detail").css({display:"block"});						
						$("#outbound_call_detail").attr({href:"{/literal}{php}echo $GLOBALS['sugar_config']['site_url'];{/php}{literal}"+"/index.php?action=DetailView&module=Calls&record="+ref_call_id});
						$("#outbound_call_detail").attr({title:"View Detail of the Call"});
						//if first time call ends , re-arrange the getting status from sources(twilio/db) 
						if(status_source_switch == true)
						{
							status_source_switch = false;
						}	
						stop_status_getter();
					}								
				},
				error:function(jqXHR,textStatus,errorThrown)
				{
					if(jqXHR.readyState == 0)
					{
						alert("Internet Connection Problem");						
					}
					else
					{
						console.log("Error Occurred on Server side(getting final call status) :"+textStatus);
					}						
				}									
			});	
		}
		
		// this function will update the final call status of currently initiated call with call_id = call_sid
		function get_call_final_status_db()
		{	
			fetch_status_counter += 10;
			if(fetch_status_counter == 120)
			{
				status_source_switch = true;
				fetch_status_counter = 0;
				call_status_timer = setTimeout("timeout_trigger()",5000);
			}
			else
			{
				get_status_from_db(call_sid);			
			}			
		}		
		
		//this will try to get final outbound call status from twilio server on its turn
		function get_status_from_twilio(call_sid)
		{
			// ajax call that will fetch the final call status directly from twilio server (Held or canceled or rejected or busy)
			$.ajax({
				url:"index.php",
				type:"POST",
				dataType:"html",
				data:"module=Calls&action=outbound_endcall_status&sugar_body_only=true&source=twilio&call_sid="+call_sid,
				async:true,
				cache:false,
				success:function(final_call_status_twilio)
				{
					if(final_call_status_twilio == "dialing" || final_call_status_twilio == "ringing" || final_call_status_twilio == "queued")
					{
						$("#outbound_log").text("Dialing...");						
						call_status_timer = setTimeout("timeout_trigger()",5000);
					}
					else if(final_call_status_twilio == "busy")
					{
						$("#outbound_log").text("Busy, Try Later");	
						//if first time call ends , re-arrange the getting status from sources(twilio/db) 
						if(status_source_switch == true)
						{
							status_source_switch = false;
						}	
						stop_status_getter();
					}
					else if(final_call_status_twilio == "dialed")
					{
						$("#outbound_log").text("Dialed");						
						status_source_switch = true; //stop getting status from twilio(as call is dialing to destination now) and start getting status from db 
						call_status_timer = setTimeout("timeout_trigger()",5000);
					}
					else
					{		
						if(final_call_status_twilio == "Held")
						{
							$("#outbound_log").text("Call Ended");
						}
						else
						{
							$("#outbound_log").text(ucfirst(final_call_status_twilio));
						}	
						$("#outbound_call_points_div").css({display:"none"});
						call_con_checker = false;
						$("#browser_endcall").css({display:"none"}); 
						$("#browser_endcall").attr({disabled:"disabled"});
						$("#source_call").css({cursor:"default"});
						$("#source_call").attr({class:"outboundDisabled"});
						$("#source_call").attr({disabled:"disabled"});
						$("#source_call").css({display:"block"});
						$("#outbound_call_detail").css({display:"block"});	
						$("#outbound_call_detail").attr({href:"{/literal}{php}echo $GLOBALS['sugar_config']['site_url'];{/php}{literal}"+"/index.php?action=DetailView&module=Calls&record="+ref_call_id});
						$("#outbound_call_detail").attr({title:"View Detail of the Call"});
						//if first time call ends , re-arrange the getting status from sources(twilio/db) 
						if(status_source_switch == true)
						{
							status_source_switch = false;
						}						
						stop_status_getter();
					}
				},
				error:function(jqXHR,textStatus,errorThrown)
				{
					if(jqXHR.readyState == 0)
					{
						alert("Internet Connection Problem");						
					}
					else
					{
						console.log("Error Occurred on Server side :(get final call status from Twilio server) "+textStatus);
					}					
				} 
			});		
		}
		//function that willl fetch the final call status from twilio server if after 2 minute, we couldn't get any final call status
		function get_call_final_status_twilio()
		{
			fetch_status_counter += 10;
			if(fetch_status_counter == 120)
			{
				status_source_switch = false;
				fetch_status_counter = 0;
				call_status_timer = setTimeout("timeout_trigger()",5000);
			}
			else
			{		
				get_status_from_twilio(call_sid);						
			}	
		}

		/*
		*	this will convert the callback statuses of the twilio call into Camel notation
		*/		
		function ucfirst(str) {		 
		  str += '';
		  var f = str.charAt(0).toUpperCase();
		  return f + str.substr(1);
		}
		//
		/*End Outbound Call Configuration and Management */
		
		/*Start Incoming and Outgoing SMS Configuration and Management*/
		//		
	
		/*
		*	this will swap the sms send and schedule buttons
		*/
		/*$("#sms_type_switcher").live("change",function(){			
			var checkbox = document.getElementById("sms_type_switcher");			
			if(checkbox.checked == true)
			{								
				$("#source_sms").attr({class:"outboundSchedule"});
				$("#sms_log").text("schedule SMS");
			}	
			else
			{					
				$("#source_sms").attr({class:"outboundSend"});	
				$("#sms_log").text("send SMS");
			}
		});*/
	
		/*
		*	this will make SMS div dynamically n destroy that if no needed
		*/
		function makingSMSDiv() {			
			if (document.getElementById('outbound_SMS_div')) 
			{
				//code if element exists
			} 
			else { //code if element doesn't exist
				var newdiv_sms = document.createElement('div');// creating new div element
				newdiv_sms.setAttribute("id", "outbound_SMS_div"); //setting ID attribute of newly created div-element				
				document.body.appendChild(newdiv_sms); // always appending newly created element at the last of the Body tag (for appending at desired place use other JS Apis)							
			}						
			toggle_diaplaySMS();
		}
		
		/*		
		*	making SMS div displayed or hidden
		*/
		function toggle_diaplaySMS() {
			SMS_making_f = !SMS_making_f;// make it false, if true
			if (SMS_making_f) {
				SMS_window_disappear();
			} else {
				SMS_window_appear();
			}			
		}
		
		/*
		*	making the SMS div inside the newly created div
		*/
		function SMS_window_appear() {	
			
			obj_sms = document.getElementById('outbound_SMS_div');
			var sms_div = '<div class="callWrapper" id="SMSWrapper" style="top:60%;position:fixed;" >';			
			sms_div += '<div class="callContent" id="SMSContent">';
			sms_div += '<div class="callStatus"><h1 id="smsType" >SMS Conversation</h1><h2 id="sms_log" class="yellow">Loading...</h2></div>';
			sms_div += '<div id="sms_detail_div" class="callDetail" >'; 
			
			sms_div += '<div class="smsView" id="sms_area" >';
			/*
			*	here all user and client sms conversation history will display in bubbles form	
			*/
			sms_div += '</div>'; //end smsView class
			
			/* Start Compose SMS */
			sms_div += '<div class="smsCompose">';
            sms_div += '<div class="smsText">';
            sms_div += '<textarea id="sms_message" ></textarea>';
            sms_div += '</div>';
            sms_div += '<input type="button" id="sms_sender" value="Send" title="Send" onclick="sendSMS()"/>';
            sms_div += '</div>';
			/* End Compose SMS */
			
			sms_div += '</div>'; //end sms_detail_div
			sms_div += '</div>'; //end callContent class	
			sms_div += '</div>'; //end callWrapper div
			
			obj_sms.innerHTML = sms_div;
			obj_sms.style.display = 'block';		
		}
		
		/*
		*	making the SMS div hidden upon clicking the close button
		*/
		function SMS_window_disappear() {			
			$(".call_maker").removeAttr("disabled");
			$("#phone_fax").removeAttr("disabled");
			obj_sms = document.getElementById('outbound_SMS_div');			
			obj_sms.innerHTML = '';
			obj_sms.style.display = 'none';
			document.body.removeChild(obj_sms);
		}
		
		/*
		*	this will initiate SMS Conversation set up and display the SMS Conversation History
		*/
		function sms_action_controlling(plugin_initializer_SMS)
		{		
			if (typeof plugin_initializer_SMS != 'undefined')
			{
				$(plugin_initializer_SMS).SMSWindowStates({
					defaultState		:	'max' //// max, min, shade
				});		
			}									
					
			$("#outbound_SMS_div").children().eq(0).show();
			
			return true; //returning true represents that the SMS Conversation has opened successfully
		}
	
		/*
		*	this will handle outgoing and incoming twilio SMS 	
		*/
		function send_sms(destination,init_plugin_obj)
		{
			smsIds= [];
			$(".call_maker").attr("disabled","disabled"); // disable all other buttons to make call while current one is in active state
			$("#phone_fax").attr("disabled","disabled"); // disable all other buttons to make call while current one is in active state
			plugin_initializer_SMS = init_plugin_obj; // placing the plugin trigger object			
			
			{/literal}{php} 
				$module_name = "rolus_Twilio_Account";
				$twilio_account_bean = BeanFactory::getBean($module_name);
				$twilio_account_bean->retrieve("1");
				$source_number = !empty($twilio_account_bean->phone_number) ? $twilio_account_bean->phone_number : "false";
			{/php}{literal}
			var source_num ="{/literal}{php}echo $source_number;{/php}{literal}";
			
			source_number_SMS = process_number(source_num); //processing source number 
			destination_number = process_number(destination); //processing destination number 			
			
			if(destination_number == source_number_SMS)
			{
				alert("Conversation cannot be made between same source and destination !");
				$(".call_maker").removeAttr("disabled");
				$("#phone_fax").removeAttr("disabled");
			}
			else if(destination_number == false || source_number_SMS == false)
			{
				alert("Invalid Source / Destination Number !");
				$(".call_maker").removeAttr("disabled");
				$("#phone_fax").removeAttr("disabled");
			}
			else
			{	
				source_number_SMS = source_number_SMS.replace("+","%2B");
				destination_number = destination_number.replace("+","%2B");
				
				makingSMSDiv();//this will create dynamic div for making outbound call			
				
				var res_flag = sms_action_controlling(plugin_initializer_SMS);			
				if(res_flag == true)
				{
					timeout_init_SMS(); // here start long pulling to fetch sms conversation history of a particular user and client					
				}
			}
		}
				
		/*
		*	this will send the Instant SMS Message to destination number and also save current SMS in Database
		*/
		function sendSMS(){		
			if($("#sms_message").val() == ''){
				$( ".smsText" ).animate({ backgroundColor: "#f00"}, 100, "swing", function(){$("#sms_log").text("Please type a message");});
				$( ".smsText" ).animate({ backgroundColor: "#fff"}, 1200, "swing", function(){$("#sms_log").text("");});
				return false;
			}
			else{
				check_twilio_creds(false);																
			}
		}
		//initiating the client side timer for getting sms history after every 5 seconds untill SMS conversation window will close
		function timeout_init_SMS()
		{
			SMS_window_open = true; // means sms window is opened
			sms_fetch_history_timer = setTimeout("timeout_trigger_SMS()",3000); // setting the timeout_trigger_SMS after every 5 seconds			
		}
		
		// this will trigger the get_SMS_history_db function after every 5-Seconds to get SMS Conversation history
		function timeout_trigger_SMS()
		{	
			get_SMS_history_db();
		}
				
		// this will clear the current timeout timer after clicking upon close button
		function stop_status_getter_SMS()
		{
			clearTimeout(sms_fetch_history_timer);
			final_picked_date = ''; // resetting the final date variable
		}
		
		/*
		*	this will continue to fetch SMS Conversation upon clicking of SMS conversation image
		*	this will display all and recent history in the SMS window to become visible to user
		*/
		function get_SMS_history_db()
		{	
			//final_picked_date = encodeURIComponent(final_picked_date); // making date urlencoded to pass through ajax calls
			var found = false;
			$.ajax({
				url:"index.php",
				data:"module=rolus_SMS_log&action=fetch_sms_conversation&sugar_body_only=true&source_number="+source_number_SMS+"&destination_number="+destination_number+"&final_picked_date="+final_picked_date,
				type: "POST",
				dataType:"json",
				async:true,
				cache:false,			
				success:function(SMS_Conversation)
				{			
					var final_date_picker = 0;
					
					if(SMS_Conversation.result != "empty") //check if there is some sms conversation in database relating to current destination number
					{						
						$.each(SMS_Conversation,function(index,unit_sms) //iterate through all sms objects					
						{	
							found = false;
							final_date_picker++;
							for (var k=0;k<smsIds.length;k++)
							{
								if (smsIds[k] == unit_sms.id)
								{
									found = true;
									if (typeof $('#'+unit_sms.id) !='undefined')
									{
									  $('#'+unit_sms.id).text(unit_sms.status+" "+unit_sms.date_entered);
									}
									break;
								}
							}
							if (found == false)
							{
							display_sms_conversation(unit_sms); // display outbound/inbound sms messages and date created	
							}
																										
							if(final_date_picker == SMS_Conversation.length)							
							{								
								final_picked_date = unit_sms.date_entered_query; //to query from database getting the date_entered of the latest sms fetched in a single current ajax call								
								final_picked_date = encodeURIComponent(final_picked_date);								
							}
							smsIds.push(unit_sms.id);					
						});
						
						//$("#sms_log").text("Fetched");
						$("#sms_log").text("");	
					}
					else
					{
						if(final_picked_date == '')
						{
							//$("#sms_log").text("No Conversation Found");
							$("#sms_log").text("");
						}							
					}		
					if(SMS_window_open == true)	
					{
						sms_fetch_history_timer = setTimeout("timeout_trigger_SMS()",3000); //restart ajax call to ensure polling and fetching the updated sms					
					}	
					else if(SMS_window_open == false)
					{
						final_picked_date = '';
					}
				},
				error:function(jqXHR,textStatus,errorThrown)
				{
					if(jqXHR.readyState == 0)
					{
						alert("Internet Connection Problem");						
					}
					else
					{
						console.log("Error Occurred at server side(getting SMS Conversation) : "+textStatus);
					}					
				}					
			});
		}
		
		/*
		*	this will display SMS conversation relating to outgoing direction 
		*/
		function display_sms_conversation(unit_sms)
		{			
			if(unit_sms.direction == "outgoing")	
			{
				display_sms_conversation_outbound(unit_sms);					
			}
			else if(unit_sms.direction == "incoming")	
			{
				display_sms_conversation_inbound(unit_sms);
			}			
		}
		
		/*
		*	this will append and display sms conversation div(bubble) for user's sms
		*/	
		function display_sms_conversation_outbound(unit_sms)
		{
			user_sms_div = '';
			/* Start User SMS area*/
			user_sms_div += '<div class="userSMS">';						
			user_sms_div += '<div class="chatBox"><span class="date" id ="'+unit_sms.id+'">'+unit_sms.status+" "+unit_sms.date_entered+'</span>';                        
			user_sms_div += '<div class="topRight">';
			user_sms_div += '<div class="topLeft">';
			user_sms_div += '<div class="bottomLeft">';
			user_sms_div += '<div class="bottomRight">';
			user_sms_div += '<div class="topCenter"></div>';
			user_sms_div += '<div class="leftCenter">';
			user_sms_div += '<div class="rightCenter">';			
			user_sms_div += '<div class="contentCenter"><p2>'+unit_sms.message+'</p2></div>';
			user_sms_div += '</div>'; // end rightCenter class
			user_sms_div += '</div>'; // end leftCenter class
			user_sms_div += '<div class="bottomCenter"></div>'; // end bottomRight class 
			user_sms_div += '</div>'; // end bottomLeft class
			user_sms_div += '</div>'; // end topRight class 
			user_sms_div += '</div>'; // end topLeft class 
			user_sms_div += '</div>'; // end date class 
			user_sms_div += '</div>'; // end chatBox class 
			user_sms_div += '</div>'; //end userSMS class
			user_sms_div += '<div class="clear"></div>';
			/* End User SMS area*/			
			
			// here adjust the placement of the user sms bubble in the sms view div
			if($(".clientSMS").length != 0)
			{				
				$(".smsView").append(user_sms_div);	
				$('.smsView').animate({scrollTop: $('.smsView').get(0).scrollHeight}, 50);								
			}
			else if($(".userSMS").length != 0)
			{				
				$(".smsView").append(user_sms_div);
				$('.smsView').animate({scrollTop: $('.smsView').get(0).scrollHeight}, 50);				
			}
			else
			{				
				$(".smsView").html(user_sms_div);				
				$('.smsView').animate({scrollTop: $('.smsView').get(0).scrollHeight}, 50);				
			}					
		}
		
		/*
		*	this will append and display sms conversation div(bubble) for client's sms
		*/	
		function display_sms_conversation_inbound(unit_sms)
		{
			client_sms_div = '';
		 	/* Start Client SMS area*/
			client_sms_div += '<div class="clientSMS">';			
			client_sms_div += '<div class="chatBox"><span class="date" id ="'+unit_sms.id+'">'+unit_sms.status+" "+unit_sms.date_entered+'</span>';			
			client_sms_div += '<div class="topLeft">';
			client_sms_div += '<div class="topRight">';
			client_sms_div += '<div class="bottomLeft">';
			client_sms_div += '<div class="bottomRight">';
			client_sms_div += '<div class="topCenter"></div>';
			client_sms_div += '<div class="leftCenter">';
			client_sms_div += '<div class="rightCenter">';
			client_sms_div += '<div class="contentCenter"><p2>'+unit_sms.message+'</p2>';			
			client_sms_div += '</div>'; //end contentCenter class
			client_sms_div += '</div>'; //end rightCenter class
			client_sms_div += '</div>'; // end leftCenter class
			client_sms_div += '<div class="bottomCenter"></div>'; // end bottomCenter class
			client_sms_div += '</div>'; // end bottomRight class
			client_sms_div += '</div>'; // end bottomLeft class
			client_sms_div += '</div>'; // end topRight class
			client_sms_div += '</div>'; // end chatBox class
			client_sms_div += '</div>'; //end chatBox  class			
			client_sms_div += '<div class="clear"></div>';
			client_sms_div += '</div>'; //end ClientSMS class			
			/* End Client SMS area*/
			
			// here adjust the placement of the client sms bubble in the sms view div
			if($(".clientSMS").length != 0)
			{				
				$(".smsView").append(client_sms_div);
				$('.smsView').animate({scrollTop: $('.smsView').get(0).scrollHeight}, 50);					
			}
			else if($(".userSMS").length != 0)
			{				
				$(".smsView").append(client_sms_div);
				$('.smsView').animate({scrollTop: $('.smsView').get(0).scrollHeight}, 50);				
			}
			else
			{						
				$(".smsView").html(client_sms_div);				
				$('.smsView').animate({scrollTop: $('.smsView').get(0).scrollHeight}, 50);				
			}
		}
		
		//
		/*End Incoming and Outgoing SMS Configuration and Management*/
		//
	</script>	
{/literal}

{php}
		 }//for user management		
	 	   else
		   {
			{/php}
			{literal}				
				<script type="text/javascript">	
                               
					$(".call_maker").css({display:"none"});
				</script>
			{/literal}
			{php}
		    }
		}
		else
		{
			{/php}
			{literal}				
				<script type="text/javascript">	
				
					$(".error_msgg").text("License is required").show().fadeOut(5000);					
					$(".call_maker").css({display:"none"});
				        $("#phone_fax").css({display:"none"});
				</script>
			{/literal}
			{php}
		}
	}	
{/php}
{literal}
	<span style="color:red;" class="error_msgg" ></span>	
{/literal}
{assign var="phone_type" value={{sugarvar key='name' string=true}} }

{if !empty({{sugarvar key='value' string=true}}) }
{assign var="phone_value" value={{sugarvar key='value' string=true}} }

{sugar_phone value=$phone_value usa_format="{{if !empty($vardef.validate_usa_format)}}1{{else}}0{{/if}}"}
<input type="image" title="Select Source To Call" class="call_maker" id="call_make" style="width:20px;height:20px;border:none;float:right;display:none;" onclick="make_call('{$phone_value}',this);"  src="custom/include/call_images/click_call.jpg" />
{if $phone_type!='phone_fax'}
<input type="image" title="Click to Start SMS Conversation" class="call_maker" id="sms_send" style="width:20px;height:20px;border:none;float:right;display:none;" onclick="send_sms('{$phone_value}',this);"  src="custom/include/call_images/click_sms.png" />
{/if}
{{if !empty($displayParams.enableConnectors)}}
{{sugarvar_connector view='DetailView'}}
{{/if}}
{/if}
