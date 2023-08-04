/*
 * ===================================================
 * Trigger For Event Object
 * ===================================================
*/ 
trigger EventTrigger on Event (before insert,before update) {
    Boolean isActive = TTN_TriggerHandler.run('TTN_Event_Trigger');
    if(isActive) {
        if(trigger.isBefore && trigger.isInsert) {
            TTN_EventTriggerHandler.beforeInsert(Trigger.New);
        }
        if(trigger.isBefore && trigger.isUpdate) {
            TTN_EventTriggerHandler.beforeUpdate(Trigger.New,Trigger.OldMap);
        }
    }
}