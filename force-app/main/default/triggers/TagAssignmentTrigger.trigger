/*****************************************************************************************
 --------------------------------------------------------------------------------------
    Version#       Date                           Author                    Description
    --------------------------------------------------------------------------------------
    1.0         30-Jan-2020                     Vivek Kumar               Initial Version
    --------------------------------------------------------------------------------------
*******************************************************************************************/
trigger TagAssignmentTrigger on TTN_Tag_Assignment__c (before insert, after insert, before delete) {
    Boolean isActive = TTN_TriggerHandler.run('TTN_Tag_Assignment_Trigger');
    if(isActive) {
        if(Trigger.isBefore && Trigger.isInsert)
        {
            TTN_TagAssignmentTriggerHandler.beforeInsert(Trigger.New);
        }
        if(Trigger.isAfter && Trigger.isInsert)
        {
            TTN_TagAssignmentTriggerHandler.afterInsert(Trigger.New);
        }
        if(Trigger.isBefore && Trigger.isDelete)
        {
            TTN_TagAssignmentTriggerHandler.beforeDelete(Trigger.Old);
        }
    }
}