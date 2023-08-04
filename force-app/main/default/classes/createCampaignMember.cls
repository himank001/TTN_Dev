public class createCampaignMember {
    public class FlowApexActionException extends Exception{}
    
    @InvocableMethod(label = 'Campaign Member')
    public static void createCampMember(List<Request> reqList){
        
        Map<Id,Campaign_Contacts__c> oldCampaignMap = new Map<Id,Campaign_Contacts__c>();
        Map<String,Campaign_Accounts__c> camAccIds = new Map<String,Campaign_Accounts__c>();
        
        Set<String> campaignSrc = new Set<String>();
        Set<Id> campAccSet = new Set<Id>();
        
        List<ContactWrapper> wrapper = (List<ContactWrapper>)JSON.deserialize(reqList[0].campaignJson, List<ContactWrapper>.class);
        
        List<Campaign__c> campList = [SELECT Id,Name,Source__c FROM Campaign__c WHERE Id =: reqList[0].campaignId];
        for(Campaign_Contacts__c cm : [SELECT Id,Name,Contact__c,Campaign_Accounts__c FROM Campaign_Contacts__c WHERE Campaign__c =: reqList[0].campaignId]){
            oldCampaignMap.put(cm.Contact__c,cm);
        }
        
        List<Campaign_Accounts__c> campaignAccountList = [Select Id,Name,Account__c FROM Campaign_Accounts__c WHERE Campaign__c =: reqList[0].campaignId];
        for(Campaign_Accounts__c ca : campaignAccountList){
            camAccIds.put(ca.Account__c,ca);
            campAccSet.add(ca.Account__c);
        }
        
        List<Campaign_Accounts__c > campaignAccountListInsert = new List<Campaign_Accounts__c >();
        List<Campaign_Contacts__c> cmpgnMemList = new List<Campaign_Contacts__c>();
        
        Map<String,String> campAccMap = new Map<String,String>();
        
        for(ContactWrapper obj : wrapper){
            Campaign_Accounts__c cmpgnMemAcc = new Campaign_Accounts__c();
            if(obj.Account.Id != '' && obj.Account.Id != null){
                if(!campAccSet.contains(obj.Account.Id)){
                    cmpgnMemAcc.Name = obj.Account.Name;
                    cmpgnMemAcc.Account__c = obj.Account.Id;
                    cmpgnMemAcc.Campaign__c = reqList[0].campaignId;
                    cmpgnMemAcc.Status__c = 'Target';
                    campAccSet.add(obj.Account.Id);
                    campaignAccountListInsert.add(cmpgnMemAcc);
                }else{
                    if(camAccIds.containsKey(obj.Account.Id)  && obj.Account.Id != null){
                        campAccMap.put(obj.Account.Id,camAccIds.get(obj.Account.Id).Id);
                    }
                }
            }
        }
        if(!campaignAccountListInsert.isEmpty()){
            Insert campaignAccountListInsert;
        }
        
        if(!campaignAccountListInsert.isEmpty()){
            for(Campaign_Accounts__c caRec : campaignAccountListInsert){
                campAccMap.put(caRec.Account__c,caRec.Id);
            }
        }
        
        for(ContactWrapper obj : wrapper){
            system.debug('wrapper--->'+wrapper);
            if(!oldCampaignMap.isEmpty() && oldCampaignMap.containsKey(obj.Id)){
                throw new FlowApexActionException('Already there is a Campaign Member Associated with the Campaign with same contact!!');
            }
            else{
                Campaign_Contacts__c cmpgnMem = new Campaign_Contacts__c();
                cmpgnMem.Name = obj.FirstName + ' ' + obj.LastName;
                cmpgnMem.Contact__c = obj.Id;
                cmpgnMem.Campaign_Contact_Source__c = reqList[0].campaignSrc;
                    cmpgnMem.Campaign_Contact_Owner__c = reqList[0].ownerId;
                cmpgnMem.Campaign__c = reqList[0].campaignId;
                cmpgnMem.Status__c = 'Target';
                cmpgnMem.Email_Upload__c = obj.Email;
                cmpgnMem.Campaign_Accounts__c = campAccMap.get(obj.AccountId);
                cmpgnMemList.add(cmpgnMem);
            }
        }
        
        if(!cmpgnMemList.isEmpty()){
            Insert cmpgnMemList;
        }
    }
    
    public class ContactWrapper {	
        public String Id;
        public String FirstName;
        public String LastName;
        public String Email;
        public String Phone;
        public String AccountId;
        public AccountData Account;
    }
    
    public class AccountData {
        public String Name;
        public String Id;
    }
    
    public class Request{
        @InvocableVariable(label = 'Selected JSON' required = true)
        public String campaignJson;
        
        @InvocableVariable(label = 'Campaign Id' required = true)
        public String campaignId;
        
        @InvocableVariable(label = 'ownerId' required = true)
        public string ownerId;
        
        @InvocableVariable(label = 'campaignSrc' required = true)
        public string campaignSrc;
    }
}