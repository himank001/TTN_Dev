trigger OpportunityTrigger on Opportunity (before insert, before update, after insert, after update,after delete) {
     Boolean isActive = TTN_TriggerHandler.run('TTN_Contact_Trigger');
    if(isActive) {
        if(Trigger.isBefore && Trigger.isInsert)
        {
            TTN_OpportunityTriggerHandler.beforeInsert(Trigger.New);
        }
        if(Trigger.isBefore && Trigger.isUpdate)
        {
            TTN_OpportunityTriggerHandler.beforeUpdate(Trigger.New, Trigger.OldMap);
        }
        if(Trigger.isAfter && Trigger.isInsert)
        {
            TTN_OpportunityTriggerHandler.afterInsert(Trigger.New);
        }
        if(Trigger.isAfter && Trigger.isUpdate)
        {
            TTN_OpportunityTriggerHandler.afterUpdate(Trigger.New, Trigger.OldMap);
        }
         if(Trigger.isAfter && Trigger.isDelete)
        {
            TTN_OpportunityTriggerHandler.afterDelete(Trigger.old, Trigger.OldMap);
        }
    }
}