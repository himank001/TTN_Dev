/*
 *============================================== 
 * Handler Class For Task Object
 * =============================================
*/ 
public class TTN_TaskTriggerHandler {
    public static void beforeInsert(List<Task> triggerNew) {
        tagAccount(triggerNew,NULL);
    }
    public static void beforeUpdate(List<Task> triggerNew,Map<Id,Task> triggerOldMap) {
        tagAccount(triggerNew,triggerOldMap);
    }
    /*
     *=========================================================================================
     * This Method is used to Tag Account in WhatId whenever an Task is inserted with Contact 
     *   tagged in whoId
     * ========================================================================================
    */ 
    private static void tagAccount(List<Task> triggerNew,Map<Id,Task> triggerOldMap) {
        if(!triggerNew.isEmpty()) {
            Set<Id> contactIds = new Set<Id>();
            for(Task activityInstance : triggerNew) {
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
                            activityInstance.whoId != triggerOldMap.get(activityInstance.Id).whoId
                        )
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
                    for(Task activityInstance : triggerNew) {
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