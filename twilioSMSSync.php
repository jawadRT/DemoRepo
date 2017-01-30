<?php

set_time_limit(0);
error_reporting(0);
array_push($job_strings, 'twilioSMSSync');

function twilioSMSSync() {
    require_once("modules/rolus_SMS_log/rolus_SMS_log.php");
    $rolus_SMS_log = new rolus_SMS_log();
    try {
        $client = $rolus_SMS_log->getClient();
        if (!(is_object($client) && $client instanceof Services_Twilio))
            throw new settingsException('Cannot connect to Twilio', '3');
        $order_by = 'date_entered DESC';
        $where = " " . $rolus_SMS_log->table_name . ".`status` = 'sending' OR " . $rolus_SMS_log->table_name . ".`status`='scheduled' OR (" . $rolus_SMS_log->table_name . ".`status`='sent' AND " . $rolus_SMS_log->table_name . ".`cost` = 0.0000)";

        $list = $rolus_SMS_log->get_list($order_by, $where);

        if ($list['row_count'] > 0) {
            foreach ($list['list'] as $sms_log) {
                $rolus_SMS_log->updateStatus($sms_log->reference_id);
            }
        }
        get_twilio_sms_count();
    } catch (communicaitonException $e) {
        $GLOBALS['log']->fatal("Caught communicaitonException ('{$e->getMessage()}')\n{$e}\n");
    } catch (settingsException $e) {
        $GLOBALS['log']->fatal("Caught settingsException ('{$e->getMessage()}')\n{$e}\n");
    } catch (Exception $e) {
        $GLOBALS['log']->fatal("Caught Exception ('{$e->getMessage()}')\n{$e}\n");
    }
    return true;
}

//Getting SMS Count
function get_twilio_sms_count($next_page_uri = null) {
    require_once("modules/rolus_Twilio_Account/rolus_Twilio_Account.php");
    $rolus_twilio_account = BeanFactory::getBean('rolus_Twilio_Account', 1);
    $auth = $rolus_twilio_account->username . ':' . $rolus_twilio_account->pass;
    if (is_null($next_page_uri)) {
        $uri = 'https://api.twilio.com/2010-04-01/Accounts/' . $rolus_twilio_account->username . '/Messages.json';
    } else {
        $uri = 'https://api.twilio.com' . $next_page_uri;
    }
    $res = curl_init();
    curl_setopt($res, CURLOPT_URL, $uri);
    curl_setopt($res, CURLOPT_USERPWD, $auth); // authenticate
    curl_setopt($res, CURLOPT_RETURNTRANSFER, true); // don't echo 
    curl_setopt($res, CURLOPT_CUSTOMREQUEST, 'GET');
    curl_setopt($res, CURLOPT_SSL_VERIFYPEER, false);
    // send cURL
    $result = curl_exec($res);
    $http_status = curl_getinfo($res, CURLINFO_HTTP_CODE);
    $result = json_decode($result, true);
    $result["status_code"] = $http_status;

    if (isset($result['messages']) && count($result['messages']) > 0) {
        maintainRelevantSMS($result['messages']);
        if (isset($result['next_page_uri']) && !empty($result['next_page_uri'])) {
            get_twilio_sms_count($result['next_page_uri']);
        } else {
            return true;
        }
    } else {
        return true;
    }
}

function maintainRelevantSMS($messages) {
    $messages_array = array();
    $message_ids = array();
    $direction_map = array(
        'inbound' => 'incoming',
        'outbound' => 'outgoing',
        'outbound-api' => 'outgoing',
        'outbound-reply' => 'outgoing',
    );
    $account_module = 'rolus_Twilio_Account';
    $account_bean = BeanFactory::getBean($account_module);
    $account_bean->retrieve('1');
    // Get the messages
    foreach ($messages as $message) {
        $message_data = $message;
        // If the messages are associated with the number stored in the Twiliio Account then get the data.
        if ((string) $message_data['to'] == $account_bean->phone_number || (string) $message_data['from'] == $account_bean->phone_number) {
            $message_ids[] = (string) $message_data['sid'];
            $data = array(
                'reference_id' => (string) $message_data['sid'],
                'date_sent' => gmdate('Y-m-d H:i:s', strtotime((string) $message_data['date_sent'])),
                'account' => (string) $message_data['account_sid'],
                'destinaiton' => (string) $message_data['to'],
                'origin' => (string) $message_data['from'],
                'message' => (string) $message_data['body'],
                'status' => (string) $message_data['status'],
                'direction' => $direction_map[(string) $message_data['direction']],
                'cost' => (string) $message_data['price'],
                'url' => (string) $message_data['uri'],
            );
            if (strtotime((string) $message_data['date_sent']) > strtotime('2012-11-14 17:0:00 +0000')) {
                if ((string) $message_data['direction'] == 'inbound') {
                    $messages_array['incoming'][] = $data;
                } else if (preg_match('/outbound/i', (string) $message_data['direction'])) {
                    $messages_array['outgoing'][] = $data;
                }
            }
        }
    }
    // Get the records already saved in the system
    $query = "SELECT `reference_id`,`status`,`need_sync`,`id` FROM rolus_sms_log WHERE reference_id IN ('" . implode("','", $message_ids) . "')";
    $already_synced = array();
    $existing_data = array();
    $rs = $GLOBALS['db']->query($query);
    while ($row = $GLOBALS['db']->fetchByAssoc($rs)) {
        $already_synced[] = $row['reference_id'];
        $existing_data[$row['reference_id']] = $row;
    }
    // Sync the Incoming messages
    require_once('modules/rolus_SMS_log/rolus_SMS_log.php');
    foreach ($messages_array['incoming'] as $incoming_message) {
        $sms_log = new rolus_SMS_Log();

        if (!in_array($incoming_message['reference_id'], $already_synced)) {
            $sms_log->assigned_user_id = '1';
            $sms_log->from_sync = "TwilioSync";
            $sms_log->reference_id = $incoming_message['reference_id'];
            $sms_log->date_sent = $incoming_message['date_sent'];
            $sms_log->account = $incoming_message['account'];
            $sms_log->destinaiton = $incoming_message['destinaiton'];
            $sms_log->origin = $incoming_message['origin'];
            $sms_log->message = $incoming_message['message'];
            $sms_log->status = $incoming_message['status'];
            $sms_log->direction = $incoming_message['direction'];
            $sms_log->cost = $incoming_message['cost'];
            $sms_log->url = $incoming_message['url'];
            if ($sms_log->direction == "inbound" || $sms_log->direction == "incoming")
                $sms_log->save();
        }
    }
    // Sync the Outgoing messages
    foreach ($messages_array['outgoing'] as $outgoing_message) {
        $sms_log = new rolus_SMS_Log();
        if (!in_array($outgoing_message['reference_id'], $already_synced) || $existing_data[$outgoing_message['reference_id']]['need_sync'] == '1') {
            if (in_array($outgoing_message['reference_id'], $already_synced)) {
                $sms_log->id = $existing_data[$outgoing_message['reference_id']]['id'];
            }
            $sms_log->assigned_user_id = '1';
            $sms_log->from_sync = "TwilioSync";
            $sms_log->reference_id = $outgoing_message['reference_id'];
            $sms_log->date_sent = $outgoing_message['date_sent'];
            $sms_log->account = $outgoing_message['account'];
            $sms_log->destinaiton = $outgoing_message['destinaiton'];
            $sms_log->origin = $outgoing_message['origin'];
            $sms_log->message = $outgoing_message['message'];
            if ($outgoing_message['status'] == 'delivered') {
                $sms_log->status = "sent";
            } else {
                $sms_log->status = $outgoing_message['status'];
            }
            //$sms_log->status = $outgoing_message['status'];
            $sms_log->direction = $outgoing_message['direction'];
            $sms_log->cost = $outgoing_message['cost'];
            $sms_log->url = $outgoing_message['url'];
            $sms_log->save();
        }
    }
    // Send out the schedules SMSs
    $order_by = 'date_entered DESC';
    $where = " " . $rolus_SMS_log->table_name . ".`status` = 'scheduled' AND " . $rolus_SMS_log->table_name . ".`direction`='outgoing' AND '" . gmdate('Y-m-d H:i:s') . "' >= date_sent";
    $list = $rolus_SMS_log->get_list($order_by, $where);
    if ($list['row_count'] > 0) {
        foreach ($list['list'] as $sms_log) {
            $sms_log->sendSMS();
            $sms_log->from_sync = "TwilioSync";
            $sms_log->save();
        }
    }
}
