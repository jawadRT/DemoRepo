<?php

if (!defined('sugarEntry') || !sugarEntry) die('Not A Valid Entry Point');

require_once('include/generic/SugarWidgets/SugarWidgetField.php');

class SugarWidgetFieldTwillioPhone extends SugarWidgetField
{
    function displayList($layout_def)
    {
		$name = $layout_def['name'];
		$value = $layout_def['fields'][strtoupper($layout_def['name'])];
		if(empty($value)){
			return "";
		}
		if($this->checkLisenceValidation()){
			return $value.$this->getFieldTpl($name, $value);
		}
		return $value;
    }
	
	function checkLisenceValidation(){
		
		$moduleName = "rolus_Twilio_Account";
		$account_bean = BeanFactory::getBean($moduleName);
		$account_bean->retrieve('1');
		$GLOBALS['log']->debug("license_validator : ".json_encode($account_bean->license_validator));
		if(isset($account_bean->license_validator))
		{
			$user_key = $account_bean->license_key; // user input in settings
			$user_key = str_replace(' ', '', $user_key);
			$_REQUEST['key']=$user_key;
			require_once('modules/rolus_SMS_log/license/OutfittersLicense.php');
			$result = OutfittersLicense::validate(1);
			$GLOBALS['log']->debug("license_validator result: ".json_encode($result));
			if($result!='"Key does not exist."')
			{
				if($GLOBALS['current_user']->voip_access == 'outbound' || $GLOBALS['current_user']->voip_access == 'both')	
				{
					return true;
				}
			}
		}
		return false;
	}
	
	function getFieldTpl($type = '', $value){
		$str = '<input type="image" title="Select Source To Call" class="call_maker" id="call_make" style="width:20px;height:20px;border:none;float:right;" onclick="make_call('."'$value'".', this);"  src="custom/include/call_images/click_call.jpg" />';
		if (strpos($type, 'fax') === false) {
			$str .= '<input type="image" title="Click to Start SMS Conversation" class="call_maker" id="sms_send" style="width:20px;height:20px;border:none;float:right;" onclick="send_sms('."'$value'".', this);"  src="custom/include/call_images/click_sms.png" />';
		}
		return $str;
	}
}

?>