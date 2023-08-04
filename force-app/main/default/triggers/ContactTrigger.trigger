/*****************************************************************************************
 --------------------------------------------------------------------------------------
    Version#       Date                           Author                    Description
    --------------------------------------------------------------------------------------
    1.0         21-Jan-2020                     Vivek Kumar               Initial Version
    --------------------------------------------------------------------------------------
*******************************************************************************************/
trigger ContactTrigger on Contact (before insert, before update, after insert, after update) {
    Boolean isActive = TTN_TriggerHandler.run('TTN_Contact_Trigger');
    if(isActive) {
        if(Trigger.isBefore && Trigger.isInsert)
        {
            TTN_ContactTriggerHandler.beforeInsert(Trigger.New);
        }
        if(Trigger.isBefore && Trigger.isUpdate)
        {
            TTN_ContactTriggerHandler.beforeUpdate(Trigger.New, Trigger.OldMap);
        }
        if(Trigger.isAfter && Trigger.isInsert)
        {
            TTN_ContactTriggerHandler.afterInsert(Trigger.New);
        }
        if(Trigger.isAfter && Trigger.isUpdate)
        {
            TTN_ContactTriggerHandler.afterUpdate(Trigger.New, Trigger.OldMap);
        }
    }
}