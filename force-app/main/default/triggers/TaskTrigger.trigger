/*
 * ===================================================
 * Trigger For Task Object
 * ===================================================
*/
trigger TaskTrigger on Task (before insert,before update) {
    Boolean isActive = TTN_TriggerHandler.run('TTN_Task_Trigger');
    if(isActive) {
        if(trigger.isBefore && trigger.isInsert) {
            TTN_TaskTriggerHandler.beforeInsert(Trigger.New);
        }
        if(trigger.isBefore && trigger.isUpdate) {
            TTN_TaskTriggerHandler.beforeUpdate(Trigger.New,Trigger.OldMap);
        }
    }
}