/*****************************************************************************************
 --------------------------------------------------------------------------------------
    Version#       Date                           Author                    Description
    --------------------------------------------------------------------------------------
    1.0         20-Jan-2017                     Vivek Kumar               Initial Version
    --------------------------------------------------------------------------------------
*******************************************************************************************/
trigger AccountTrigger on Account (before insert, before update, after insert, after update) {
    Boolean isActive = TTN_TriggerHandler.run('TTN_Account_Trigger');
    if(isActive) {
        if(Trigger.isBefore && Trigger.isInsert)
        {
            TTN_AccountTriggerHandler.beforeInsert(Trigger.New);
        }
        if(Trigger.isBefore && Trigger.isUpdate)
        {
            TTN_AccountTriggerHandler.beforeUpdate(Trigger.New, Trigger.OldMap);
        }
        if(Trigger.isAfter && Trigger.isInsert)
        {
            TTN_AccountTriggerHandler.afterInsert(Trigger.New);
        }
        if(Trigger.isAfter && Trigger.isUpdate)
        {
            TTN_AccountTriggerHandler.afterUpdate(Trigger.New, Trigger.OldMap);
        }
    }
}