/*
 *============================================== 
 * Handler Class For Event Object
 * =============================================
*/ 
public class TTN_EventTriggerHandler {
    public static void beforeInsert(List<Event> triggerNew) {
        tagAccount(triggerNew,NULL);
    }
    public static void beforeUpdate(List<Event> triggerNew,Map<Id,Event> triggerOldMap) {
    	tagAccount(triggerNew,triggerOldMap);
    }
    /*
     *=========================================================================================
     * This Method is used to Tag Account in WhatId whenever an Event is inserted with Contact 
     *   tagged in whoId
     * ========================================================================================
    */ 
    private static void tagAccount(List<Event> triggerNew,Map<Id,Event> triggerOldMap) {
        if(!triggerNew.isEmpty()) {
            Set<Id> contactIds = new Set<Id>();
            for(Event activityInstance : triggerNew) {
                if(
                    activityInstance.whoId != NULL 
                    && 
                    activityInstance.whoId.getSobjectType().getDescribe().getName().equalsIgnoreCase(
                        'Contact'
                    ) 
                    && 
                    (
                        triggerOldMap == NULL 
                        || 
                        (
                            triggerOldMap != NULL 
                            && 
                            activityInstance.whoId != triggerOldMap.get(activityInstance.Id).whoId)
                    )
                ) {
                    contactIds.add(activityInstance.whoId);
                }
            }
            if(!contactIds.isEmpty()) {
                Map<Id,Id> contactidToAccountId = new Map<Id,Id>();
                for(Contact contactInstance : [SELECT Id,AccountId FROM Contact 
                                                WHERE Id IN:contactIds and AccountId != NULL]) {
                    contactidToAccountId.put(contactInstance.Id,contactInstance.AccountId);
                }
                if(!contactidToAccountId.isEmpty()) {
                    for(Event activityInstance : triggerNew) {
                        if(
                            activityInstance.whoId != NULL 
                            && 
                            activityInstance.whoId.getSobjectType().getDescribe().getName().equalsIgnoreCase(
                                'Contact'
                            ) 
                            && 
                            contactidToAccountId.containsKey(activityInstance.whoId)
                        ) {
                            activityInstance.WhatId = contactidToAccountId.get(
                                activityInstance.whoId
                            );
                        }
                    }
                }
            }
        }
    }
}