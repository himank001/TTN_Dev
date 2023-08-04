public class deleteCampaignContactAndAccount {
    public static void deleteCampaignAccount(List<Campaign_Contacts__c> camConc){
        Set<Id> campAccountId = new Set<id>();
        
        for(Campaign_Contacts__c cc : camConc){
            campAccountId.add(cc.Campaign_Accounts__c);
        }
        List<Campaign_Accounts__c> camAccListToDelete = new List<Campaign_Accounts__c>();
        
        List<Campaign_Accounts__c> camAccList = [SELECT Id,Name,(SELECT Id,Name FROM Campaign_Contacts__r) 
                                                 FROM Campaign_Accounts__c 
                                                 WHERE Id IN: campAccountId];
        
        for(Campaign_Accounts__c camAcc : camAccList){
            if(camAcc.Campaign_Contacts__r.size() == 0){
                camAccListToDelete.add(camAcc);
            }
        }
        if(!camAccListToDelete.isEmpty()){
            DELETE camAccListToDelete;
        }
    }
}