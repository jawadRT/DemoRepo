<?php

function saveField_Custom($field, $id, $module, $value)
{
    global $current_user;
    $bean = BeanFactory::getBean($module, $id);

    if (is_object($bean) && $bean->id != "") {

        if ($bean->field_defs[$field]['type'] == "multienum") {
            $bean->$field = encodeMultienumValue($value);
        }else if ($bean->field_defs[$field]['type'] == "relate" || $bean->field_defs[$field]['type'] == 'parent'){
            $save_field = $bean->field_defs[$field]['id_name'];
            $bean->$save_field = $value;
            if ($bean->field_defs[$field]['type'] == 'parent') {
                $bean->parent_type = $_REQUEST['parent_type'];
                $bean->fill_in_additional_parent_fields(); // get up to date parent info as need it to display name
            }
        }else if ($bean->field_defs[$field]['type'] == "currency"){
			if (stripos($field, 'usdollar')) {
				$newfield = str_replace("_usdollar", "", $field);
				$bean->$newfield = $value;
			}
			else{
				$bean->$field = $value;
			}
            
        }else{
            $bean->$field = $value;
        }

        $check_notify = FALSE;

        if (isset( $bean->fetched_row['assigned_user_id']) && $field == "assigned_user_name") {
            $old_assigned_user_id = $bean->fetched_row['assigned_user_id'];
            if (!empty($value) && ($old_assigned_user_id != $value) && ($value != $current_user->id)) {
                $check_notify = TRUE;
            }
        }

        $bean->save($check_notify);
        return getDisplayValue_Custom($bean, $field);
    } else {
        return false;
    }

}

function getDisplayValue_Custom($bean, $field, $method = "save")
{
    if (file_exists("custom/modules/Accounts/metadata/listviewdefs.php")) {
        $metadata = require("custom/modules/Accounts/metadata/listviewdefs.php");
    } else {
        $metadata = require("modules/Accounts/metadata/listviewdefs.php");
    }

    $listViewDefs = $listViewDefs['Accounts'][strtoupper($field)];

    $fieldlist[$field] = $bean->getFieldDefinition($field);

    if(is_array($listViewDefs)){
        $fieldlist[$field] = array_merge($fieldlist[$field], $listViewDefs);
    }
	if($fieldlist[$field]['type'] == "phone"){
		$value = formatDisplayValue_Custom($bean, $bean->$field, $fieldlist[$field], $method);
	}
	else{
		$value = formatDisplayValue($bean, $bean->$field, $fieldlist[$field], $method);
	}


    return $value;
}

function formatDisplayValue_Custom($bean, $value, $vardef, $method = "save")
{
    global $app_list_strings, $timedate;

    //Fake the params so we can pass the values through the sugarwidgets to get the correct display html.

    $GLOBALS['focus'] = $bean;
    $_REQUEST['record'] = $bean->id;
    $vardef['fields']['ID'] = $bean->id;
    $vardef['fields'][strtoupper($vardef['name'])] = $value;

	require_once("custom/include/generic/SugarWidgets/SugarWidgetFieldTwillioPhone.php");
	$SugarWidgetFieldTwillioPhone = new SugarWidgetFieldTwillioPhone($vardef);
	$value = $SugarWidgetFieldTwillioPhone->displayList($vardef);
	
    return $value;
}

?>