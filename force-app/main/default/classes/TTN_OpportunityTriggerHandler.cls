public class TTN_OpportunityTriggerHandler{

    public static Boolean isOpportunityTriggerRunning = false;
    //By implementing this method trigger can handle all the Before Insert events
    public static void beforeInsert(List<Opportunity> triggerNew)
    {
        
    }
    
    //By implementing this method trigger can handle all the Before Update events
    public static void beforeUpdate(List<Opportunity> triggerNew, Map<Id,Opportunity> triggerOldMap)
    {
        
    }
    
    //By implementing this method trigger can handle all the After Insert events
    public static void afterInsert(List<Opportunity> triggerNew)
    {
        updateContactRealtionship(triggerNew,null);
    }
    
    //By implementing this method trigger can handle all the After Update events
    public static void afterUpdate(List<Opportunity> triggerNew, Map<Id,Opportunity> triggerOldMap)
    {
        updateContactRealtionship(triggerNew,triggerOldMap);
    }
    
    //By implementing this method trigger can handle all the After Update events
    public static void afterDelete(List<Opportunity> triggerNew, Map<Id,Opportunity> triggerOldMap)
    {
        updateContactRealtionshipForDelete(triggerNew,triggerOldMap);
    }
    
    public static void updateContactRealtionship(List<Opportunity> triggerNew, Map<Id,Opportunity> triggerOldMap){
        Set<String> stageNames = new Set<String>();
        Set<Id> setofContactId = new Set<Id>();
        Set<Id> setofAccountId = new Set<Id>();
        List<Contact> conList = new List<Contact>();
        Map<String,List<Contact>> mapofConWithRltCon = new Map<String,List<Contact>>(); 
        Map<String,Contact> mapofConidWithCon = new Map<String,Contact>();
        Map<String,List<Contact>> mapofAcntidlstCon = new Map<String,List<Contact>>(); 
        Map<String,Integer> mapofStageNamewithPrority = new Map<String,Integer>();
        Map<String,String> mapofStageNamewithCR = new Map<String,String>();        
        Map<String, Opportunity_Stage_with_Contact_Relations__mdt> mapOppStageandAccRel = Opportunity_Stage_with_Contact_Relations__mdt.getAll();
        
        for(String nameOppPrority : mapOppStageandAccRel .keySet()){
            mapofStageNamewithCR.put(mapOppStageandAccRel.get(nameOppPrority).Stage_Name__c, mapOppStageandAccRel.get(nameOppPrority).Contact_Relation_Ship__c);
        }
        Map<String, TTN_Opportunity_Priority__mdt> mapOppPrority = TTN_Opportunity_Priority__mdt.getAll();
        for(String nameOppPrority : mapOppPrority.keySet()){
            mapofStageNamewithPrority.put(mapOppPrority.get(nameOppPrority).TTN_Relationship_Type__c, 
            Integer.Valueof(mapOppPrority.get(nameOppPrority).TTN_Priority__c));
        }
        Set<String> setOfStagesOpertaion = mapofStageNamewithCR.keySet();
        
        for(Opportunity each: triggerNew){
            if(triggerOldMap == null && String.isNotBlank(each.TTN_Contact_Name__c) && setOfStagesOpertaion.contains(each.StageName) ){
                setofContactId.add(each.TTN_Contact_Name__c);
            }
            else if(triggerOldMap != null && String.isNotBlank(each.TTN_Contact_Name__c) 
                    && triggerOldMap.get(each.Id).StageName != each.StageName && setOfStagesOpertaion.contains(each.StageName)){
                        setofContactId.add(each.TTN_Contact_Name__c);
            }
        } 
        system.debug('===setofContactId===='+setofContactId);
        if(setofContactId.size() > 0){         
            for(Contact each: [SELECT id,Contact_Relationship_Type__c, TTN_Department_List__c,AccountId 
                               FROM Contact 
                               WHERE Id IN : setofContactId AND TTN_Department_List__c != null]){
                  mapofConidWithCon.put(each.Id,each); 
                  setofAccountId.add(each.AccountId);                           
            }
            system.debug('===mapofConidWithCon===='+mapofConidWithCon);
            system.debug('===setofAccountId===='+setofAccountId);
            for(Contact each: [SELECT id,Contact_Relationship_Type__c, TTN_Department_List__c,AccountId 
                               FROM Contact 
                               WHERE AccountId IN : setofAccountId AND Id NOT IN : setofContactId AND TTN_Department_List__c != null]){
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
            system.debug('===mapofAcntidlstCon===='+mapofAcntidlstCon);
        
            for(Opportunity each: triggerNew){
                if(triggerOldMap == null && String.isNotBlank(each.TTN_Contact_Name__c) 
                  && mapofConidWithCon.containskey(each.TTN_Contact_Name__c) && setOfStagesOpertaion.contains(each.StageName) &&
                    mapofStageNamewithCR.containskey(each.StageName) && mapofStageNamewithPrority.containskey(mapofStageNamewithCR.get(each.StageName))){
                    Contact objCon = mapofConidWithCon.get(each.TTN_Contact_Name__c);                
                    if(objCon.Contact_Relationship_Type__c == null || mapofStageNamewithPrority.get(objCon.Contact_Relationship_Type__c) > mapofStageNamewithPrority.get(mapofStageNamewithCR.get(each.StageName))){
                        objCon.Contact_Relationship_Type__c = mapofStageNamewithCR.get(each.StageName);
                        conList.add(objCon);
                    } 
                    if(String.isNotBlank(objCon.AccountId) && String.isNotBlank(objCon.TTN_Department_List__c) 
                       && mapofAcntidlstCon.containsKey(objCon.AccountId+'-'+objCon.TTN_Department_List__c)){
                        for(Contact conEach:mapofAcntidlstCon.get(objCon.AccountId+'-'+objCon.TTN_Department_List__c)){
                            if(conEach.Contact_Relationship_Type__c == null || mapofStageNamewithPrority.get(conEach.Contact_Relationship_Type__c) > mapofStageNamewithPrority.get(mapofStageNamewithCR.get(each.StageName))){
                                conEach.Contact_Relationship_Type__c = mapofStageNamewithCR.get(each.StageName);
                                conList.add(conEach);
                            }
                        }
                    }
                }
                else if(triggerOldMap != null && String.isNotBlank(each.TTN_Contact_Name__c) && setOfStagesOpertaion.contains(each.StageName) 
                        && triggerOldMap.get(each.Id).StageName != each.StageName && mapofStageNamewithCR.containskey(each.StageName) 
                        && mapofConidWithCon.containskey(each.TTN_Contact_Name__c) &&
                        mapofStageNamewithCR.containskey(each.StageName) && mapofStageNamewithPrority.containskey(mapofStageNamewithCR.get(each.StageName))){
                        System.debug('====Inside debug inside update==');
                        Contact objCon = mapofConidWithCon.get(each.TTN_Contact_Name__c); 
                        System.debug('====Inside debug inside update==objCon '+objCon );               
                        if(objCon.Contact_Relationship_Type__c == null || mapofStageNamewithPrority.get(objCon.Contact_Relationship_Type__c) > mapofStageNamewithPrority.get(mapofStageNamewithCR.get(each.StageName))){
                            objCon.Contact_Relationship_Type__c = mapofStageNamewithCR.get(each.StageName);
                            conList.add(objCon);
                        } 
                        if(String.isNotBlank(objCon.AccountId) && String.isNotBlank(objCon.TTN_Department_List__c) 
                           && mapofAcntidlstCon.containsKey(objCon.AccountId+'-'+objCon.TTN_Department_List__c)){
                            for(Contact conEach:mapofAcntidlstCon.get(objCon.AccountId+'-'+objCon.TTN_Department_List__c)){
                                if(conEach.Contact_Relationship_Type__c == null || mapofStageNamewithPrority.get(conEach.Contact_Relationship_Type__c) > mapofStageNamewithPrority.get(mapofStageNamewithCR.get(each.StageName))){
                                    conEach.Contact_Relationship_Type__c = mapofStageNamewithCR.get(each.StageName);
                                    conList.add(conEach);
                                }
                            }
                        }
                }
            }
            
            if(conList.size() > 0){
                update conList;
            }
      }  
    }
    
    public static void updateContactRealtionshipForDelete(List<Opportunity> triggerNew, Map<Id,Opportunity> triggerOldMap){
        Set<String> stageNames = new Set<String>();
        Set<Id> setofContactId = new Set<Id>();
        Set<Id> setofAccountId = new Set<Id>();
        List<Contact> conList = new List<Contact>();
        Map<String,List<Contact>> mapofConWithRltCon = new Map<String,List<Contact>>(); 
        Map<String,Contact> mapofConidWithCon = new Map<String,Contact>();
        Map<String,List<Contact>> mapofAcntidlstCon = new Map<String,List<Contact>>(); 
        Map<String,Integer> mapofStageNamewithPrority = new Map<String,Integer>();
        Map<String,String> mapofStageNamewithCR = new Map<String,String>();        
        Map<String, Opportunity_Stage_with_Contact_Relations__mdt> mapOppStageandAccRel = Opportunity_Stage_with_Contact_Relations__mdt.getAll();
        
        for(String nameOppPrority : mapOppStageandAccRel .keySet()){
            mapofStageNamewithCR.put(mapOppStageandAccRel.get(nameOppPrority).Stage_Name__c, mapOppStageandAccRel.get(nameOppPrority).Contact_Relation_Ship__c);
        }
        Map<String, TTN_Opportunity_Priority__mdt> mapOppPrority = TTN_Opportunity_Priority__mdt.getAll();
        for(String nameOppPrority : mapOppPrority.keySet()){
            mapofStageNamewithPrority.put(mapOppPrority.get(nameOppPrority).TTN_Relationship_Type__c, 
            Integer.Valueof(mapOppPrority.get(nameOppPrority).TTN_Priority__c));
        }
        Set<String> setOfStagesOpertaion = mapofStageNamewithCR.keySet(); 
        
        for(Opportunity each: triggerNew){
            if(String.isNotBlank(each.TTN_Contact_Name__c)){
                setofContactId.add(each.TTN_Contact_Name__c);
            }
        } 
        
        if(setofContactId.size() > 0){         
            for(Contact each: [SELECT id,Contact_Relationship_Type__c, TTN_Department_List__c,AccountId 
                               FROM Contact 
                               WHERE Id IN : setofContactId AND TTN_Department_List__c != null]){
                  mapofConidWithCon.put(each.Id,each); 
                  setofAccountId.add(each.AccountId);                           
            }
            system.debug('===mapofConidWithCon===='+mapofConidWithCon);
            system.debug('===setofAccountId===='+setofAccountId);
            for(Contact each: [SELECT id,Contact_Relationship_Type__c, TTN_Department_List__c,AccountId 
                               FROM Contact 
                               WHERE AccountId IN : setofAccountId AND Id NOT IN : setofContactId AND TTN_Department_List__c != null]){
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
            system.debug('===mapofAcntidlstCon===='+mapofAcntidlstCon);
            
            for(Opportunity each: triggerNew){
                if(String.isNotBlank(each.TTN_Contact_Name__c)  
                        && mapofConidWithCon.containskey(each.TTN_Contact_Name__c) &&
                        mapofStageNamewithCR.containskey(each.StageName) && mapofStageNamewithPrority.containskey(mapofStageNamewithCR.get(each.StageName))){
                        System.debug('====Inside debug inside update==');
                        Contact objCon = mapofConidWithCon.get(each.TTN_Contact_Name__c); 
                        System.debug('====Inside debug inside update==objCon '+objCon );               
                        if(objCon.Contact_Relationship_Type__c == null || mapofStageNamewithPrority.get(objCon.Contact_Relationship_Type__c) >= mapofStageNamewithPrority.get(mapofStageNamewithCR.get(each.StageName))){
                            objCon.Contact_Relationship_Type__c = 'Suspect';
                            conList.add(objCon);
                        } 
                        if(String.isNotBlank(objCon.AccountId) && String.isNotBlank(objCon.TTN_Department_List__c) 
                           && mapofAcntidlstCon.containsKey(objCon.AccountId+'-'+objCon.TTN_Department_List__c)){
                            for(Contact conEach:mapofAcntidlstCon.get(objCon.AccountId+'-'+objCon.TTN_Department_List__c)){
                                if(conEach.Contact_Relationship_Type__c == null || mapofStageNamewithPrority.get(conEach.Contact_Relationship_Type__c) >= mapofStageNamewithPrority.get(mapofStageNamewithCR.get(each.StageName))){
                                    conEach.Contact_Relationship_Type__c = 'Suspect';
                                    conList.add(conEach);
                                }
                            }
                        }
                }
            }
            
            if(conList.size() > 0){
                update conList;
            }
        }
    }
}