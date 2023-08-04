/*
This class handles all trigger events on Account Object
--------------------------------------------------------------------------------------
Version#     Date                           Author                    Description
--------------------------------------------------------------------------------------
1.0          20-Jan-2020                  Vivek Kumar               Initial Version
--------------------------------------------------------------------------------------
*/
public class TTN_AccountTriggerHandler {
    public static Boolean isAccountTriggerRunning = false;
    //By implementing this method trigger can handle all the Before Insert events
    public static void beforeInsert(List<Account> triggerNew)
    {
        appendTagsCheckboxUpdate(triggerNew);
        formatTagoninsertion(triggerNew);
    }
    
    //By implementing this method trigger can handle all the Before Update events
    public static void beforeUpdate(List<Account> triggerNew, Map<Id,Account> triggerOldMap)
    {
        appendTag(triggerNew, triggerOldMap);
    }
    
    //By implementing this method trigger can handle all the After Insert events
    public static void afterInsert(List<Account> triggerNew)
    {
        //createTags(triggerNew, null);
        tagAssignments(triggerNew, null);
    }
    
    //By implementing this method trigger can handle all the After Update events
    public static void afterUpdate(List<Account> triggerNew, Map<Id,Account> triggerOldMap)
    {
        //createTags(triggerNew, triggerOldMap);
        tagAssignments(triggerNew, triggerOldMap);
    }
    private static void formatTagoninsertion(List<Account> triggerNew) {
        for(Account objAccount : triggerNew) {
            if(objAccount.TTN_Tags__c != NULL) {
                List<String> tags = objAccount.TTN_Tags__c.split(',');
                Set<String> tagSet = new Set<String>();
                tagSet.addAll(tags);
                objAccount.TTN_Tags__c = NULL;
                for(String objString : tagSet) {
                    if(objAccount.TTN_Tags__c == NULL) {
                        objAccount.TTN_Tags__c = objString.trim().toLowerCase();
                    }
                    else {
                        objAccount.TTN_Tags__c += ', '+objString.trim().toLowerCase();
                    }
                }
            }
        }
    }
    //Making the Append Tags checkbox false for every case on insert to prevent human error
    public static void appendTagsCheckboxUpdate(List<Account> triggerNew)
    {
        for(Account objAccount : triggerNew)
        {
            if(objAccount.TTN_Append_Tags__c)
            {
                objAccount.TTN_Append_Tags__c = false;
            }
        }
    }
    
    //Appending the new tags to the existing tag values
    public static void appendTag(List<Account> triggerNew, Map<Id,Account> triggerOldMap)
    {
        for(Account objNewAccount : triggerNew)
        {
            Account objOldAccount = triggerOldMap != null? triggerOldMap.get(objNewAccount.Id) : null;
            
            //Appending only when tags updated and Append Tags checkbox is true
            if(objNewAccount.TTN_Tags__c != objOldAccount.TTN_Tags__c && objNewAccount.TTN_Append_Tags__c)
            {
                //Set used to prevent duplicate tags
                Set<String> tagSet = new Set<String>();
                
                if(String.isNotBlank(objOldAccount.TTN_Tags__c))
                {
                    //Adding existing tags in the field to a set
                    List<String> existingTagsList = new List<String>();
                    existingTagsList = objOldAccount.TTN_Tags__c.split(',');
                    for(String existingTag : existingTagsList)
                    {
                        tagSet.add(existingTag.trim().toLowerCase());
                    }
                }
                
                if(String.isNotBlank(objNewAccount.TTN_Tags__c))
                {
                    //Adding new tags to the set
                    List<String> newTagsList = new List<String>();
                    newTagsList = objNewAccount.TTN_Tags__c.split(',');
                    for(String newTag : newTagsList)
                    {
                        tagSet.add(newTag.trim().toLowerCase());
                    }
                }
                
                //Adding all tags to the field
                objNewAccount.TTN_Tags__c = '';
                for(String tag : tagSet)
                {
                    if(String.isBlank(objNewAccount.TTN_Tags__c))
                    {
                        objNewAccount.TTN_Tags__c = tag;
                    }
                    else
                    {
                        objNewAccount.TTN_Tags__c += ', '+ tag;
                    }
                }
            }
            
            objNewAccount.TTN_Append_Tags__c = false;
        }
    }
    /*
    *=======================================================================================
    *Description: This method is used to create Tag and Tag Assignents under Account Record
    *=======================================================================================
    *Name: Rishi                  Date:13/2/2020
    *=======================================================================================
    */
    private static void tagAssignments(List<Account> triggerNew,Map<id,Account> triggerOldMap) {
        if(!triggerNew.isEmpty() && !TTN_TagAssignmentTriggerHandler.isTagTriggerRunning) {
            isAccountTriggerRunning = true; 
            Set<String> tagsSet = new Set<String>(); // Set To Contain TTN_Tags__c new Value
            Set<Id> accountIds = new Set<Id>(); // Set To Contain Account Ids
            for(Account accountInstance : triggerNew) {
                if(
                    triggerOldMap == NULL 
                    || 
                    (
                        triggerOldMap != NULL 
                        && 
                        triggerOldMap.get(accountInstance.Id).TTN_Tags__c 
                        != 
                        accountInstance.TTN_Tags__c
                    )
                ) {
                    if(accountInstance.TTN_Tags__c != NULL) {
                        List<String> tags = accountInstance.TTN_Tags__c.split(',');
                        for(String tag : tags) {
                            tagsSet.add(tag.trim().toLowerCase());
                        }
                        //tagsSet.addAll(tags);
                    }
                    accountIds.add(accountInstance.Id);
                }
            }
            //////////////////////////////////////////
            /////Tag Operations and map related to Tag Object/////
            Map<String,TTN_Tag__c> tagMap = new Map<String,TTN_Tag__c>();
            if(!tagsSet.isEmpty()) {
                //Map To Store Existing tag record WRT Name
                for(TTN_Tag__c tagInstance : [SELECT Id,Name FROM TTN_Tag__c WHERE Name IN:tagsSet]) {
                    if(!tagMap.ContainsKey(tagInstance.Name)) {
                        tagMap.put(tagInstance.Name.trim().toLowerCase(),tagInstance);
                    }
                }
                List<TTN_Tag__c> newTags = new List<TTN_Tag__c>();
                for(String tag : tagsSet) {
                    if(!tagMap.containsKey(tag)) {
                        TTN_Tag__c objNewTag = new TTN_Tag__c();
                        objNewTag.Name = tag;
                        tagMap.put(objNewTag.Name,objNewTag);
                        
                        newTags.add(objNewTag);
                    }
                }
                if(!newTags.isEmpty()) {
                    INSERT newTags;
                }
            }
            /////////////////////////////////////////////////////
            
            /////////////////////////////////////////////////////
            /////Maps related to Tag Assignment//////////////////
            Map<String,TTN_Tag_Assignment__c> tagAssignment = 
                new Map<String,TTN_Tag_Assignment__c>();

            Map<Id,List<TTN_Tag_Assignment__c>> tagAssignmentsWRTContactId = 
                new Map<Id,List<TTN_Tag_Assignment__c>>();
            for(TTN_Tag_Assignment__c assignment : [SELECT Id,TTN_Tag__r.Name,TTN_Account__c 
                                                        FROM TTN_Tag_Assignment__c 
                                                        WHERE TTN_Account__c IN:accountIds]) {
                String key = assignment.TTN_Tag__r.Name.trim().toLowerCase() + assignment.TTN_Account__c;
                if(!tagAssignment.ContainsKey(key)
                ) {
                    tagAssignment.put(key,assignment);
                }
                
                if(!tagAssignmentsWRTContactId.containsKey(assignment.TTN_Account__c))
                    tagAssignmentsWRTContactId.put(
                        assignment.TTN_Account__c,new List<TTN_Tag_Assignment__c>()
                    );
                tagAssignmentsWRTContactId.get(assignment.TTN_Account__c).add(assignment);
            }
            ////////////////////////////////////////////////////
            ////////////////////////////////////////////////////
            ////Logic to Insert and Delete Tag Assignments//////
            List<TTN_Tag_Assignment__c> assignmentsToRemove = New List<TTN_Tag_Assignment__c>();
            List<TTN_Tag_Assignment__c> assignmentsToInsert = New List<TTN_Tag_Assignment__c>();
            for(Account accountInstance : triggerNew) {
                if(triggerOldMap == NULL 
                    || 
                    (
                        triggerOldMap.get(accountInstance.Id).TTN_Tags__c 
                        != 
                        accountInstance.TTN_Tags__c  
                    )
                ) {
                    if(accountInstance.TTN_Tags__c != NULL) {
                        List<String> tags = 
                        accountInstance.TTN_Tags__c.split(',');
                        Set<String> tagSet = new Set<String>();
                                for(String tag : tags) {
                                    tagSet.add(tag.trim().toLowerCase());
                                }
                        //tagSet.addAll(tags);
                        for(String tag : tagSet) {
                            if(
                                !tagAssignment.containsKey(tag+accountInstance.Id) 
                                && 
                                tagMap.containsKey(tag)
                            ) {
                                TTN_Tag_Assignment__c objAssignment = new TTN_Tag_Assignment__c();
                                objAssignment.TTN_Tag__c = tagMap.get(tag).Id;
                                objAssignment.TTN_Account__c = accountInstance.Id;
                                objAssignment.TTN_Tag_Name__c = tagMap.get(tag).Name;
                                assignmentsToInsert.add(objAssignment);    
                            }
                        }
                        if(
                            triggerOldMap != NULL 
                            && 
                            triggerOldMap.get(accountInstance.Id).TTN_Tags__c != NULL 
                        ) {
                            List<String> oldValues = triggerOldMap.get(
                                accountInstance.Id
                            ).TTN_Tags__c.split(',');
                            Set<String> oldValuesSet = new Set<String>();
                            for(String oldtag : oldValues) {
                                oldValuesSet.add(oldtag.trim().toLowerCase());
                            }
                            //oldValuesSet.addAll(oldValues);
                        
                            for(String oldValue : oldValuesSet) {
                                if(
                                    !tagSet.contains(oldValue) 
                                    && 
                                    tagAssignment.containsKey(oldValue+accountInstance.Id)
                                ) {
                                    assignmentsToRemove.add(
                                        tagAssignment.get(oldValue+accountInstance.Id)
                                    );
                                }
                            }
                        }
                    }
                    else {
                        if(tagAssignmentsWRTContactId.containsKey(accountInstance.Id)) {
                            assignmentsToRemove.addAll(
                                tagAssignmentsWRTContactId.get(accountInstance.Id)
                            );
                        }
                    }
                  }
            }
            if(!assignmentsToInsert.isEmpty()) {
                INSERT assignmentsToInsert;
            }
            if(!assignmentsToRemove.isEmpty()) {
                DELETE assignmentsToRemove;
            }
        }
    }
}