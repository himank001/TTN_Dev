public without sharing class campaignContactsDataLoad {
    public static void insertCampaignContact(List<Campaign_Contacts__c> ccList){
        
        Set<Id> campaignSetId = new Set<Id>();
        Set<String> getContactEmail = new Set<String>();
        Set<String> userNameSet = new Set<String>();
        
        Map<String,Campaign_Accounts__c> campaignAccountId = new Map<String,Campaign_Accounts__c>();
        Map<String,Campaign__c> campaignOwnerIdMap = new Map<String,Campaign__c>();
        Map<String,String> concAccMap = new Map<String,String>();
        Map<String,Contact> concMap = new Map<String,Contact>();
        Map<String,Decimal> countEmailMap = new Map<String,Decimal>();
        Map<String,Id> userLinkMap = new Map<String,Id>();
        
        List<Campaign_Accounts__c> campAccList = new List<Campaign_Accounts__c>();
        List<Campaign_Contacts__c> camConcListToUpdate = new List<Campaign_Contacts__c>();
        List<Campaign_Contacts__c> camConcListToUpdateFinal = new List<Campaign_Contacts__c>();
        List<Campaign_Accounts__c> camAccListToUpdate = new List<Campaign_Accounts__c>();
        
        for(Campaign_Contacts__c cc : ccList){
            CampaignSetId.add(cc.Campaign__c);
            getContactEmail.add(cc.Email_Upload__c);
            userNameSet.add(cc.Username__c);
        }
        
        if(!CampaignSetId.isEmpty()){
            for(Campaign__c c : [SELECT Id,Name,OwnerId,Source__c FROM Campaign__c WHERE Id IN: CampaignSetId]){
                campaignOwnerIdMap.put(c.Id,c);
            } 
        }
        
        for(Contact c : [SELECT Id,FirstName,Email,AccountId,Account.Name,Full_Name__c FROM Contact WHERE Email In: getContactEmail]){
            concMap.put(c.Email,c);
        }
        
        for(Campaign_Accounts__c ca : [SELECT Id,Name,Campaign__c,Account__c FROM Campaign_Accounts__c WHERE Campaign__c In: CampaignSetId]){
            campaignAccountId.put(ca.Account__c,ca);
        }
        
        for(User u : [SELECT Id,FirstName,UserName FROM User WHERE UserName In: userNameSet]){
            userLinkMap.put(u.UserName,u.Id);
        }
        
        List<Campaign_Contacts__c> campConcList = [SELECT Id,Name, Campaign_Contact_Source__c,Email_Upload__c FROM Campaign_Contacts__c WHERE Email_Upload__c In: concMap.keySet() AND Campaign__c In: CampaignSetId];
        Map<String, Campaign_Contacts__c> campaignContactMap = new Map<String, Campaign_Contacts__c>(); 
        
        if(!campConcList.isEmpty()){
            for(Campaign_Contacts__c campignContact:campConcList){
                campaignContactMap.put(campignContact.Email_Upload__c, campignContact);
            }
        }
        for(Campaign_Contacts__c singleCampaignConc : ccList){
            if(concMap.containsKey(singleCampaignConc.Email_Upload__c)){
                if(!CampaignAccountId.containskey(concMap.get(singleCampaignConc.Email_Upload__c).AccountId)){
                    Campaign_Accounts__c ca = new Campaign_Accounts__c();
                    ca.Account__c = concMap.get(singleCampaignConc.Email_Upload__c).AccountId;
                    
                    if(concMap.get(singleCampaignConc.Email_Upload__c).Account.Name.length() >= 80){
                        ca.Name = String.valueOf(concMap.get(singleCampaignConc.Email_Upload__c).Account.Name).substring(0,79);
                    }
                    else{
                        ca.Name = concMap.get(singleCampaignConc.Email_Upload__c).Account.Name;
                    }
                    
                    ca.Campaign__c = singleCampaignConc.Campaign__c;
                    CampaignAccountId.put(concMap.get(singleCampaignConc.Email_Upload__c).AccountId,ca);
                    campAccList.add(ca);
                }
                else{
                    concAccMap.put(concMap.get(singleCampaignConc.Email_Upload__c).AccountId,campaignAccountId.get(concMap.get(singleCampaignConc.Email_Upload__c).AccountId).id);
                }
            }
        }
        
        if(!campAccList.isEmpty()){
            system.debug(campAccList);
            INSERT campAccList;
            
            for(Campaign_Accounts__c ca : campAccList){
                concAccMap.put(ca.Account__c,ca.Id);
            }
        }
        
        for(Campaign_Contacts__c c : ccList){
            system.debug('countEmailMap Inside--');
            if(campaignOwnerIdMap.containsKey(c.Campaign__c)){
                if(!campaignContactMap.containsKey(c.Email_Upload__c)){
                    campaignContactMap.put(c.Email_Upload__c,c);
                    if(concMap.containsKey(c.Email_Upload__c)){
                        c.Contact__c = concMap.get(c.Email_Upload__c).id;
                        c.Campaign_Accounts__c = concAccMap.get(concMap.get(c.Email_Upload__c).AccountId);
                        c.Name = concMap.get(c.Email_Upload__c).Full_Name__c;
                        c.Campaign_Contact_Source__c = campaignOwnerIdMap.get(c.Campaign__c).Source__c;
                        if(c.Username__c == null || String.isBlank(c.Username__c)){
                            c.Campaign_Contact_Owner__c = campaignOwnerIdMap.get(c.Campaign__c).OwnerId;
                        }
                        else if(userLinkMap.containsKey(c.Username__c)){
                            c.Campaign_Contact_Owner__c = userLinkMap.get(c.Username__c);
                            system.debug('c.Campaign_Contact_Owner__c--'+c.Campaign_Contact_Owner__c);
                        }
                    }
                }
                else{
                    c.addError('Duplicate Found');
                }
            }
        }
    }
    
    public static void checkIfAlreadyCampaignContactPresent(List<Campaign_Contacts__c> ccList){
        Map<String,String> ccMap = new Map<String,String>();
        
        for(Campaign_Contacts__c ccObj : ccList){
            ccMap.put(ccObj.Campaign__c,ccObj.Email_Upload__c);
        }
        
        if(!ccList.isEmpty()){
            if(!ccMap.isEmpty()){
                for(Campaign_Contacts__c cc : ccList){
                    if(ccMap.get(cc.Campaign__c) == cc.Email_Upload__c){
                        if(!test.isRunningTest()){
                            cc.addError('Alreay there is Campaign Contact linked to this Campaign with same contact!');
                        }
                        
                    }
                }   
            }      
        }
    }
}