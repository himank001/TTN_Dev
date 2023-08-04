/*
This class handles all trigger events on Contact Object
--------------------------------------------------------------------------------------
Version#     Date                           Author                    Description
--------------------------------------------------------------------------------------
1.0          21-Jan-2020                  Vivek Kumar               Initial Version
--------------------------------------------------------------------------------------
*/
public class TTN_ContactTriggerHandler 
{
    public static Boolean isContactTriggerRunning = false;
    public static Boolean isContactRecalcution = true;
    //By implementing this method trigger can handle all the Before Insert events
    public static void beforeInsert(List<Contact> triggerNew)
    {
        appendTagsCheckboxUpdate(triggerNew);
        formatTagoninsertion(triggerNew);
        if(System.Label.runnewChanges == 'true' && isContactRecalcution){
            updateContactRealtionship(triggerNew ,null);
        }
    }
    
    //By implementing this method trigger can handle all the Before Update events
    public static void beforeUpdate(List<Contact> triggerNew, Map<Id,Contact> triggerOldMap)
    {
        appendTag(triggerNew, triggerOldMap);
        if(System.Label.runnewChanges == 'true' && isContactRecalcution){ 
            updateContactRealtionship(triggerNew,triggerOldMap);
        }
    }
    
    //By implementing this method trigger can handle all the After Insert events
    public static void afterInsert(List<Contact> triggerNew)
    {
        //createTags(triggerNew, null);
        tagAssignments(triggerNew, null);
    }
    
    //By implementing this method trigger can handle all the After Update events
    public static void afterUpdate(List<Contact> triggerNew, Map<Id,Contact> triggerOldMap)
    {
        //createTags(triggerNew, triggerOldMap);
        tagAssignments(triggerNew, triggerOldMap);
        if(System.Label.runnewChanges == 'true' && isContactRecalcution){ 
            updateRelatedContact(triggerNew, triggerOldMap);
         }
    }
    
    //Making the Append Tags checkbox false for every case on insert to prevent human error
    public static void appendTagsCheckboxUpdate(List<Contact> triggerNew)
    {
        for(Contact objContact : triggerNew)
        {
            if(objContact.TTN_Append_Tags__c)
            {
                objContact.TTN_Append_Tags__c = false;
            }
        }
    }
    private static void formatTagoninsertion(List<Contact> triggerNew) {
        for(Contact objContact : triggerNew) {
            if(objContact.TTN_Tags__c != NULL) {
                List<String> tags = objContact.TTN_Tags__c.split(',');
                Set<String> tagSet = new Set<String>();
                tagSet.addAll(tags);
                objContact.TTN_Tags__c = NULL;
                for(String objString : tagSet) {
                    if(objContact.TTN_Tags__c == NULL) {
                        objContact.TTN_Tags__c = objString.trim().toLowerCase();
                    }
                    else {
                        objContact.TTN_Tags__c += ', '+objString.trim().toLowerCase();
                    }
                }
            }
        }
    }
    //Appending the new tags to the existing tag values
    public static void appendTag(List<Contact> triggerNew, Map<Id,Contact> triggerOldMap)
    {
        for(Contact objNewContact : triggerNew)
        {
            Contact objOldContact = triggerOldMap != null? triggerOldMap.get(objNewContact.Id) : null;
            
            //Appending only when tags updated and Append Tags checkbox is true
            if(objNewContact.TTN_Tags__c != objOldContact.TTN_Tags__c && objNewContact.TTN_Append_Tags__c)
            {
                //Set used to prevent duplicate tags
                Set<String> tagSet = new Set<String>();
                
                if(String.isNotBlank(objOldContact.TTN_Tags__c))
                {
                    //Adding existing tags in the field to a set
                    List<String> existingTagsList = new List<String>();
                    existingTagsList = objOldContact.TTN_Tags__c.split(',');
                    for(String existingTag : existingTagsList)
                    {
                        tagSet.add(existingTag.trim().toLowerCase());
                    }
                }
                
                if(String.isNotBlank(objNewContact.TTN_Tags__c))
                {
                    //Adding new tags to the set
                    List<String> newTagsList = new List<String>();
                    newTagsList = objNewContact.TTN_Tags__c.split(',');
                    for(String newTag : newTagsList)
                    {
                        tagSet.add(newTag.trim().toLowerCase());
                    }
                }
                
                //Adding all tags to the field
                objNewContact.TTN_Tags__c = '';
                for(String tag : tagSet)
                {
                    if(String.isBlank(objNewContact.TTN_Tags__c))
                    {
                        objNewContact.TTN_Tags__c = tag;
                    }
                    else
                    {
                        objNewContact.TTN_Tags__c += ', '+ tag;
                    }
                }
            }
            objNewContact.TTN_Append_Tags__c = false;
        }
    }
    /*
    *====================================================================================
    *Description: This method is used to create Tag and Tag Assignments under Contact
    *====================================================================================
    *Name: Rishi Patel                 Date:12/2/2020
    *====================================================================================
    */
    private static void tagAssignments(List<Contact> triggerNew,Map<id,Contact> triggerOldMap) {
        if(!triggerNew.isEmpty() && !TTN_TagAssignmentTriggerHandler.isTagTriggerRunning) {
            isContactTriggerRunning = true;
            Set<String> tagsSet = new Set<String>(); // Set To Contain TTN_Tags__c new Value
            Set<Id> contactIds = new Set<Id>(); // Set To Contain Contact Ids
            for(Contact contactInstance : triggerNew) {
                if(
                    triggerOldMap == NULL 
                    || 
                    (
                        triggerOldMap != NULL 
                        && 
                        triggerOldMap.get(contactInstance.Id).TTN_Tags__c 
                        != 
                        contactInstance.TTN_Tags__c
                    )
                ) {
                    if(contactInstance.TTN_Tags__c != NULL) {
                        List<String> tags = contactInstance.TTN_Tags__c.split(',');
                        for(String tag : tags) {
                            tagsSet.add(tag.trim().toLowerCase());
                        }
                        //tagsSet.addAll(tags);
                    }
                    contactIds.add(contactInstance.Id);
                }
            }
            system.debug('@@@@'+tagsSet);
            system.debug('@@@@'+contactIds);
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
                    SYstem.debug('@@@'+newTags[0]);
                }
            }
            /////////////////////////////////////////////////////
            
            /////////////////////////////////////////////////////
            /////Maps related to Tag Assignment//////////////////
            Map<String,TTN_Tag_Assignment__c> tagAssignment = 
                new Map<String,TTN_Tag_Assignment__c>();

            Map<Id,List<TTN_Tag_Assignment__c>> tagAssignmentsWRTContactId = 
                new Map<Id,List<TTN_Tag_Assignment__c>>();
            for(TTN_Tag_Assignment__c assignment : [SELECT Id,TTN_Tag__r.Name,TTN_Contact__c 
                                                        FROM TTN_Tag_Assignment__c 
                                                        WHERE TTN_Contact__c IN:contactIds]) {
                String key = assignment.TTN_Tag__r.Name.trim().toLowerCase() + assignment.TTN_Contact__c;
                if(!tagAssignment.ContainsKey(key)
                ) {
                    tagAssignment.put(key,assignment);
                }
                
                if(!tagAssignmentsWRTContactId.containsKey(assignment.TTN_Contact__c))
                    tagAssignmentsWRTContactId.put(
                        assignment.TTN_Contact__c,new List<TTN_Tag_Assignment__c>()
                    );
                tagAssignmentsWRTContactId.get(assignment.TTN_Contact__c).add(assignment);
            }
            ////////////////////////////////////////////////////
            ////////////////////////////////////////////////////
            ////Logic to Insert and Delete Tag Assignments//////
            List<TTN_Tag_Assignment__c> assignmentsToRemove = New List<TTN_Tag_Assignment__c>();
            List<TTN_Tag_Assignment__c> assignmentsToInsert = New List<TTN_Tag_Assignment__c>();
            for(Contact contactInstance : triggerNew) {
                if(
                    triggerOldMap == NULL 
                    || 
                    (
                        triggerOldMap.get(contactInstance.Id).TTN_Tags__c 
                        != 
                        contactInstance.TTN_Tags__c
                    )
                ) {
                    if(contactInstance.TTN_Tags__c != NULL) {
                        List<String> tags = 
                            contactInstance.TTN_Tags__c.split(',');
                        Set<String> tagSet = new Set<String>();
                        for(String tag : tags) {
                        tagSet.add(tag.trim().toLowerCase());
                        }
                        //tagSet.addAll(tags);
                        for(String tag : tagSet) {
                            if(
                                !tagAssignment.containsKey(tag+contactInstance.Id) 
                                && 
                                tagMap.containsKey(tag)
                            ) {
                                TTN_Tag_Assignment__c objAssignment = new TTN_Tag_Assignment__c();
                                objAssignment.TTN_Tag__c = tagMap.get(tag).Id;
                                objAssignment.TTN_Contact__c = contactInstance.Id;
                                objAssignment.TTN_Tag_Name__c = tagMap.get(tag).Name;
                                assignmentsToInsert.add(objAssignment);    
                            }
                        }
                        if(
                            triggerOldMap != NULL 
                            && 
                            triggerOldMap.get(contactInstance.Id).TTN_Tags__c != NULL 
                        ) {
                            List<String> oldValues = triggerOldMap.get(
                                contactInstance.Id
                            ).TTN_Tags__c.split(',');
                            Set<String> oldValuesSet = new Set<String>();
                            for(String tag : oldValues) {
                            oldValuesSet.add(tag.trim().toLowerCase());
                            }
                            //oldValuesSet.addAll(oldValues);
                            
                            for(String oldValue : oldValuesSet) {
                            if(
                                !tagSet.contains(oldValue) 
                                && 
                                tagAssignment.containsKey(oldValue+contactInstance.Id)
                            ) {
                                assignmentsToRemove.add(
                                    tagAssignment.get(oldValue+contactInstance.Id)
                                );
                            }
                        }
                        }
                    }
                    else {
                        if(tagAssignmentsWRTContactId.containsKey(contactInstance.Id)) {
                            assignmentsToRemove.addAll(
                                tagAssignmentsWRTContactId.get(contactInstance.Id)
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
    
    
    public static void updateContactRealtionship(List<Contact> triggerNew, Map<Id,Contact> triggerOldMap){
        Set<Id> setofAccountId = new Set<Id>();
        Set<Id> seofContactnotBeConsiderd = new Set<Id>();
        Map<String,List<Contact>> mapofAcntidlstCon = new Map<String,List<Contact>>();
        List<Contact> lstContact = new List<Contact>();
        Map<String,Integer> mapofStageNamewithPrority = new Map<String,Integer>();
        Map<String,String> mapofAccntDatewithStage = new Map<String,String>();
        Set<String> setofNoActionRequired = new Set<String>();
        String lowestStageName = 'Suspect';
        Integer lowestStage;
        Set<String> setofEmailLab = new Set<String>();
        List<String> listofEmailLab = new List<String>();
        listofEmailLab = Label.EmailLabels.split(';');
        setofEmailLab.addAll(listofEmailLab); 
        
        Map<String, TTN_Opportunity_Priority__mdt> mapOppPrority = TTN_Opportunity_Priority__mdt.getAll();        
        for(String nameOppPrority : mapOppPrority.keySet()){
            mapofStageNamewithPrority.put(mapOppPrority.get(nameOppPrority).TTN_Relationship_Type__c, 
            Integer.Valueof(mapOppPrority.get(nameOppPrority).TTN_Priority__c));
            if(mapOppPrority.get(nameOppPrority).Relationship_Skip__c){
                setofNoActionRequired.add(mapOppPrority.get(nameOppPrority).TTN_Relationship_Type__c);
            }
            if(lowestStage == null || (lowestStage != null &&
               lowestStage < Integer.Valueof(mapOppPrority.get(nameOppPrority).TTN_Priority__c))){
                lowestStage = Integer.Valueof(mapOppPrority.get(nameOppPrority).TTN_Priority__c);
                lowestStageName = mapOppPrority.get(nameOppPrority).TTN_Relationship_Type__c;
            }
        }
        
        for(Contact each:triggerNew){
            if(triggerOldMap == null && String.isBlank(each.Id)){
                setofAccountId.add(each.AccountId);
            }
            else if(triggerOldMap != null && String.isNotBlank(each.Id) && 
                    triggerOldMap.get(each.Id).AccountId != each.AccountId){
                    setofAccountId.add(each.AccountId);
                    seofContactnotBeConsiderd.add(each.Id);
            }
        }
        
        for(Contact each: [SELECT id,Contact_Relationship_Type__c, TTN_Department_List__c,AccountId 
                           FROM Contact 
                           WHERE AccountId IN : setofAccountId AND Id NOT IN :seofContactnotBeConsiderd 
                           AND TTN_Department_List__c != null]){
            if(mapofAcntidlstCon.containskey(each.AccountId+'-'+each.TTN_Department_List__c)){
                List<Contact> conLst = mapofAcntidlstCon.get(each.AccountId+'-'+each.TTN_Department_List__c);
                conLst.add(each);
                mapofAcntidlstCon.put(each.AccountId+'-'+each.TTN_Department_List__c,conLst);
            }
            else if(!mapofAcntidlstCon.containskey(each.AccountId+'-'+each.TTN_Department_List__c)){
                List<Contact> conLst = new List<Contact>();
                conLst.add(each);
                mapofAcntidlstCon.put(each.AccountId+'-'+each.TTN_Department_List__c,conLst);
            }
        }
        
        for(Contact each:triggerNew){
            Boolean isInsideBulk = false;
            system.debug(each.Email+'===each.Emaileach.Contact_Relationship_Type__c===='+each.Contact_Relationship_Type__c);
            system.debug(!setofNoActionRequired.contains(each.Contact_Relationship_Type__c));
            if(triggerOldMap == null && String.isBlank(each.Id) && String.isNotBlank(each.AccountId) 
               && String.isNotBlank(each.TTN_Department_List__c) && !setofNoActionRequired.contains(each.Contact_Relationship_Type__c)){             
                 if(mapofAcntidlstCon.containsKey(each.AccountId+'-'+each.TTN_Department_List__c)){
                     for(Contact objCon : mapofAcntidlstCon.get(each.AccountId+'-'+each.TTN_Department_List__c)){
                          each.Contact_Relationship_Type__c = objCon.Contact_Relationship_Type__c;
                          isInsideBulk = true;
                     }
                 }
                if(!mapofAcntidlstCon.containsKey(each.AccountId+'-'+each.TTN_Department_List__c) &&
                   !isInsideBulk && (String.isBlank(each.Contact_Relationship_Type__c) || (String.isNotBlank(each.Contact_Relationship_Type__c) &&
                        mapOppPrority.containsKey(each.Contact_Relationship_Type__c) && mapOppPrority.containsKey(lowestStageName) 
                        && !setofNoActionRequired.contains(each.Contact_Relationship_Type__c) &&
                      Integer.Valueof(mapOppPrority.get(each.Contact_Relationship_Type__c).TTN_Priority__c) >=  
                      Integer.Valueof(mapOppPrority.get(lowestStageName).TTN_Priority__c)))){
                      if(triggerOldMap == null && 
                         String.isNotBlank(each.Email) && setofEmailLab.contains(each.Email.split('@')[1])){
                             each.Contact_Relationship_Type__c = Label.ToTheNewStatus;
                      }
                      else{ 
                          each.Contact_Relationship_Type__c = lowestStageName ;  
                      }                      
                        
                }

            }
            else if(triggerOldMap != null && String.isNotBlank(each.Id) &&
                    triggerOldMap.get(each.Id).AccountId != each.AccountId && !setofNoActionRequired.contains(each.Contact_Relationship_Type__c) && 
                    String.isNotBlank(each.AccountId) && String.isNotBlank(each.TTN_Department_List__c) &&
                    mapofAcntidlstCon.containsKey(each.AccountId+'-'+each.TTN_Department_List__c)){
                        for(Contact objCon : mapofAcntidlstCon.get(each.AccountId+'-'+each.TTN_Department_List__c)){
                             each.Contact_Relationship_Type__c = objCon.Contact_Relationship_Type__c;
                             isInsideBulk = true;
                        }                        
                    if(!isInsideBulk && (String.isBlank(each.Contact_Relationship_Type__c) || (String.isNotBlank(each.Contact_Relationship_Type__c) &&
                        mapOppPrority.containsKey(each.Contact_Relationship_Type__c) && mapOppPrority.containsKey(lowestStageName) &&
                      Integer.Valueof(mapOppPrority.get(each.Contact_Relationship_Type__c).TTN_Priority__c) >  
                      Integer.Valueof(mapOppPrority.get(lowestStageName).TTN_Priority__c)))){
                        each.Contact_Relationship_Type__c = lowestStageName;                        
                    }
                }        
            } 
    }
    
    public static void updateRelatedContact(List<Contact> triggerNew, Map<Id,Contact> triggerOldMap){
        Set<Id> setofAccountId = new Set<Id>();
        Set<Id> seofContactnotBeConsiderd = new Set<Id>();
        Map<String,List<Contact>> mapofAcntidlstCon = new Map<String,List<Contact>>();
        List<Contact> lstContact = new List<Contact>();
        Map<String,Contact> mapOfStringContact = new Map<String,Contact>();
        
        for(Contact each:triggerNew){
            if(triggerOldMap != null && String.isNotBlank(each.Id) &&  
               triggerOldMap.get(each.Id).Contact_Relationship_Type__c != each.Contact_Relationship_Type__c){
                setofAccountId.add(each.AccountId);
                seofContactnotBeConsiderd.add(each.Id);
            }
        }
        
        for(Contact each: [SELECT id,Contact_Relationship_Type__c, TTN_Department_List__c,AccountId 
                           FROM Contact 
                           WHERE AccountId IN : setofAccountId AND ID NOT IN :seofContactnotBeConsiderd 
                           AND TTN_Department_List__c != null]){
            system.debug('===each=='+each);
            if(mapofAcntidlstCon.containskey(each.AccountId+'-'+each.TTN_Department_List__c)){
                List<Contact> conLst = mapofAcntidlstCon.get(each.AccountId+'-'+each.TTN_Department_List__c);
                conLst.add(each);
                mapofAcntidlstCon.put(each.AccountId+'-'+each.TTN_Department_List__c,conLst);
            }
            else if(!mapofAcntidlstCon.containskey(each.AccountId+'-'+each.TTN_Department_List__c)){
                List<Contact> conLst = new List<Contact>();
                conLst.add(each);
                mapofAcntidlstCon.put(each.AccountId+'-'+each.TTN_Department_List__c,conLst);
            }
        }
        
        for(Contact each:triggerNew){
            if(triggerOldMap != null && String.isNotBlank(each.Id) &&                    
                   triggerOldMap.get(each.Id).Contact_Relationship_Type__c != each.Contact_Relationship_Type__c && 
                   String.isNotBlank(each.AccountId) && String.isNotBlank(each.TTN_Department_List__c) &&
                    mapofAcntidlstCon.containsKey(each.AccountId+'-'+each.TTN_Department_List__c)){
                        for(Contact objCon : mapofAcntidlstCon.get(each.AccountId+'-'+each.TTN_Department_List__c)){
                             if(!seofContactnotBeConsiderd.contains(objCon.Id)){ 
                                 objCon.Contact_Relationship_Type__c = each.Contact_Relationship_Type__c;
                                 mapOfStringContact.put(objCon.Id,objCon);
                             }
                        }
                }        
            } 
            system.debug(mapOfStringContact.size()+'===lstContact==='+mapOfStringContact);
            if(mapOfStringContact.size() > 0){
                isContactRecalcution = false;
                update mapOfStringContact.values();
            }
      }
}