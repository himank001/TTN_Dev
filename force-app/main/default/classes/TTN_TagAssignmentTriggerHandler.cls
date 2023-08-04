/*
This class handles all trigger events on Tag Assignment Object
--------------------------------------------------------------------------------------
Version#     Date                           Author                    Description
--------------------------------------------------------------------------------------
1.0          30-Jan-2020                  Vivek Kumar               Initial Version
--------------------------------------------------------------------------------------
*/
public class TTN_TagAssignmentTriggerHandler {
    
    public static Boolean isTagTriggerRunning = false;
    
    //By implementing this method trigger can handle all the Before Insert events
    public static void beforeInsert(List<TTN_Tag_Assignment__c> triggerNew)
    {
        updateUniqueCheckField(triggerNew);
    }
    
    //By implementing this method trigger can handle all the After Insert events
    public static void afterInsert(List<TTN_Tag_Assignment__c> triggerNew)
    {
        updateTagsOnRelatedRecords(triggerNew, false);
    }
    
    //By implementing this method trigger can handle all the Before Delete events
    public static void beforeDelete(List<TTN_Tag_Assignment__c> triggerOld)
    {
        updateTagsOnRelatedRecords(triggerOld, true);
    }
    
    public static void updateTagsOnRelatedRecords(
        List<TTN_Tag_Assignment__c> triggerTagList, 
        Boolean isDelete
    )
    {
        if(!TTN_AccountTriggerHandler.isAccountTriggerRunning && !TTN_ContactTriggerHandler.isContactTriggerRunning) {
            
            
            isTagTriggerRunning = true;
            Map<Id,Account> accountIdToAccountMap = new Map<Id,Account>();
            Map<Id,Contact> contactIdToContactMap = new Map<Id,Contact>();
            
            for(TTN_Tag_Assignment__c objTagAssgn: [SELECT TTN_Contact__r.TTN_Tags__c, TTN_Contact__r.Id, 
                                                    TTN_Account__r.TTN_Tags__c, TTN_Account__r.Id, TTN_Tag__r.Name 
                                                    FROM TTN_Tag_Assignment__c WHERE Id IN:triggerTagList])
            {
                if(objTagAssgn.TTN_Contact__c != null)
                {
                    if(String.isNotBlank(objTagAssgn.TTN_Contact__r.TTN_Tags__c))
                    {
                        //Preventing update in case the tag is already in the Tags field
                        List<String> existingTagsOnRelatedContactList = new List<String>();
                        existingTagsOnRelatedContactList = objTagAssgn.TTN_Contact__r.TTN_Tags__c.split(',');
                        Set<String> existingTagsOnRelatedContactSet = new Set<String>();
                        for(String existingTag : existingTagsOnRelatedContactList)
                        {
                            existingTagsOnRelatedContactSet.add(existingTag.trim());
                        }
                        
                        //Appending new tag to the Tags field on related contact
                        if(!existingTagsOnRelatedContactSet.contains(objTagAssgn.TTN_Tag__r.Name) && !isDelete)
                        {
                            Contact objContact = new Contact(Id=objTagAssgn.TTN_Contact__r.Id);
                            objContact.TTN_Append_Tags__c = true; //Using this to append the new value
                            objContact.TTN_Tags__c = objTagAssgn.TTN_Tag__r.Name;
                            contactIdToContactMap.put(objContact.Id, objContact);
                        }
                        else if(isDelete && existingTagsOnRelatedContactSet.contains(objTagAssgn.TTN_Tag__r.Name))
                        {
                            Contact objContact = new Contact(Id=objTagAssgn.TTN_Contact__r.Id);
                            existingTagsOnRelatedContactSet.remove(objTagAssgn.TTN_Tag__r.Name);
                            objContact.TTN_Tags__c = '';
                            
                            for(String tag : existingTagsOnRelatedContactSet)
                            {
                                if(String.isBlank(objContact.TTN_Tags__c))
                                {
                                    objContact.TTN_Tags__c = tag;
                                }
                                else
                                {
                                    objContact.TTN_Tags__c += ', ' + tag;
                                }
                            }
                            contactIdToContactMap.put(objContact.Id, objContact);
                        }
                    }
                    else if(!isDelete)
                    {
                        Contact objContact = new Contact(Id=objTagAssgn.TTN_Contact__r.Id);
                        objContact.TTN_Tags__c = objTagAssgn.TTN_Tag__r.Name;
                        contactIdToContactMap.put(objContact.Id, objContact);
                    }
                }
                if(objTagAssgn.TTN_Account__c != null)
                {
                    if(String.isNotBlank(objTagAssgn.TTN_Account__r.TTN_Tags__c))
                    {
                        //Preventing update in case the tag is already in the Tags field
                        List<String> existingTagsOnRelatedAccountList = new List<String>();
                        existingTagsOnRelatedAccountList = objTagAssgn.TTN_Account__r.TTN_Tags__c.split(',');
                        Set<String> existingTagsOnRelatedAccountSet = new Set<String>();
                        for(String existingTag : existingTagsOnRelatedAccountList)
                        {
                            existingTagsOnRelatedAccountSet.add(existingTag.trim());
                        }
                        
                        //Appending new tag to the Tags field on related contact
                        if(!existingTagsOnRelatedAccountSet.contains(objTagAssgn.TTN_Tag__r.Name) && !isDelete)
                        {
                            Account objAccount = new Account(Id=objTagAssgn.TTN_Account__r.Id);
                            objAccount.TTN_Append_Tags__c = true; //Using this to append the new value
                            objAccount.TTN_Tags__c = objTagAssgn.TTN_Tag__r.Name;
                            accountIdToAccountMap.put(objAccount.Id, objAccount);
                        }
                        else if(isDelete && existingTagsOnRelatedAccountSet.contains(objTagAssgn.TTN_Tag__r.Name))
                        {
                            Account objAccount = new Account(Id=objTagAssgn.TTN_Account__r.Id);
                            existingTagsOnRelatedAccountSet.remove(objTagAssgn.TTN_Tag__r.Name);
                            objAccount.TTN_Tags__c = '';
                            
                            for(String tag : existingTagsOnRelatedAccountSet)
                            {
                                if(String.isBlank(objAccount.TTN_Tags__c))
                                {
                                    objAccount.TTN_Tags__c = tag;
                                }
                                else
                                {
                                    objAccount.TTN_Tags__c += ', ' + tag;
                                }
                            }
                            accountIdToAccountMap.put(objAccount.Id, objAccount);
                        }
                    }
                    else if(!isDelete)
                    {
                        Account objAccount = new Account(Id=objTagAssgn.TTN_Account__r.Id);
                        objAccount.TTN_Tags__c = objTagAssgn.TTN_Tag__r.Name;
                        accountIdToAccountMap.put(objAccount.Id, objAccount);
                    }
                }
            }
            
            if(!contactIdToContactMap.isEmpty())
            {
                update contactIdToContactMap.values();
            }
            if(!accountIdToAccountMap.isEmpty())
            {
                update accountIdToAccountMap.values();
            }
        }
    }
    
    private static void updateUniqueCheckField(List<TTN_Tag_Assignment__c> triggerNew)
    {
        for(TTN_Tag_Assignment__c objTagAssignment : triggerNew)
        {
            objTagAssignment.TTN_Unique_Check__c = objTagAssignment.TTN_Account__c 
                +''+ objTagAssignment.TTN_Contact__c 
                +''+ objTagAssignment.TTN_Tag__c;
        }
    }
}