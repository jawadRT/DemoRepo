<?php
include_once("include/MVC/Controller/SugarController.php");
include_once("custom/include/InlineEditing/InlineEditing.php");
include_once("include/InlineEditing/InlineEditing.php");

class CustomHomeController extends SugarController{
	
	public function action_getEditFieldHTML(){

        if($_REQUEST['field'] && $_REQUEST['id'] && $_REQUEST['current_module']){

            $html = getEditFieldHTML($_REQUEST['current_module'], $_REQUEST['field'], $_REQUEST['field'] , 'EditView', $_REQUEST['id']);
            echo $html;
        }

    }
	
    public function action_saveHTMLField(){
        if($_REQUEST['field'] && $_REQUEST['id'] && $_REQUEST['current_module']){

            echo saveField_Custom($_REQUEST['field'], $_REQUEST['id'], $_REQUEST['current_module'], $_REQUEST['value'], $_REQUEST['view']);

        }

    }
    public function action_getDisplayValue(){
		$GLOBALS['log']->fatal("CustomHomeController");

        if($_REQUEST['field'] && $_REQUEST['id'] && $_REQUEST['current_module'] ){

            $bean = BeanFactory::getBean($_REQUEST['current_module'],$_REQUEST['id']);

            if(is_object($bean) && $bean->id != ""){
                echo getDisplayValue_Custom($bean, $_REQUEST['field'],"close");
            }else{
                echo "Could not find value.";
            }

        }

    }
	
    public function action_getValidationRules(){
        global $app_strings, $mod_strings;

        if($_REQUEST['field'] && $_REQUEST['id'] && $_REQUEST['current_module'] ){

            $bean = BeanFactory::getBean($_REQUEST['current_module'],$_REQUEST['id']);

            if(is_object($bean) && $bean->id != ""){

                $fielddef = $bean->field_defs[$_REQUEST['field']];

                if(!$fielddef['required']){
                    $fielddef['required'] = false;
                }

                if($fielddef['name'] == "email1" || $fielddef['email2']){
                    $fielddef['type'] = "email";
                    $fielddef['vname'] = "LBL_EMAIL_ADDRESSES";
                }

                if($app_strings[$fielddef['vname']]){
                    $fielddef['label'] = $app_strings[$fielddef['vname']];
                }else{
                    $fielddef['label'] = $mod_strings[$fielddef['vname']];
                }

                $validate_array = array('type' => $fielddef['type'], 'required' => $fielddef['required'],'label' => $fielddef['label']);

                echo json_encode($validate_array);
            }

        }

    }
    
    public function action_getRelateFieldJS(){
        
        global $beanFiles, $beanList;
        
        $fieldlist = array();
        $view = "EditView";

        if (!isset($focus) || !($focus instanceof SugarBean)){
            require_once($beanFiles[$beanList[$_REQUEST['current_module']]]);
            $focus = new $beanList[$_REQUEST['current_module']];
        }

        // create the dropdowns for the parent type fields
        $vardefFields[$_REQUEST['field']] = $focus->field_defs[$_REQUEST['field']];

        require_once("include/TemplateHandler/TemplateHandler.php");
        $template_handler = new TemplateHandler();
        $quicksearch_js = $template_handler->createQuickSearchCode($vardefFields, $vardefFields, $view);
        $quicksearch_js = str_replace($_REQUEST['field'], $_REQUEST['field'] . '_display', $quicksearch_js);

        if($_REQUEST['field'] != "parent_name") {
            $quicksearch_js = str_replace($vardefFields[$_REQUEST['field']]['id_name'], $_REQUEST['field'], $quicksearch_js);
        }

        echo $quicksearch_js;

    }
}