/*
This class handles all trigger events on Lead Object
--------------------------------------------------------------------------------------
Version#     Date                           Author                    Description
--------------------------------------------------------------------------------------
1.0          17-Jan-2020                  Vivek Kumar               Initial Version
--------------------------------------------------------------------------------------
*/
public class TTN_LeadTriggerHandler {
    
    //By implementing this method trigger can handle all the After Insert events
    public static void afterInsert(List<Lead> triggerNew)
    {
        convertOnCreate(triggerNew);
    }
    private static void convertOnCreate(List<Lead> triggerNew) {
    if(!triggerNew.isEmpty()) {
        //Fetching status to use for a converted lead
        LeadStatus convertStatus = [SELECT MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        String leadConvertStatus = convertStatus.MasterLabel;
        
        //Creating data for converting lead
        List<Database.LeadConvert> leadConvertList = new List<Database.LeadConvert>();
        Set<String> accounts = new Set<String>(); 
        for(Lead objLead : triggerNew) {
            if(objLead.Company != NULL) {
                accounts.add(objLead.Company);
            }
        }
        if(!accounts.isEmpty()) {
            List<Account> accountList = [SELECT Id,Name From Account WHERE Name IN:accounts];
            map<String,Id> accountMap = new Map<String,Id>();
            if(!accountList.isEmpty()) {
                for(Account objAccount : accountList) {
                    accountMap.put(objAccount.Name,objAccount.Id);
                }
            }
            for(Lead objLead : triggerNew) {
                if(objLead.Company != NULL) {
                    Database.LeadConvert objLeadConvert = new database.LeadConvert();
                    objLeadConvert.setLeadId(objLead.Id);
                    objLeadConvert.setConvertedStatus(leadConvertStatus);
                    objLeadConvert.setDoNotCreateOpportunity(true);
                    
                    if(accountMap.containsKey(objLead.Company)) {
                        objLeadConvert.setAccountId(accountMap.get(objLead.Company));
                    }
                    leadConvertList.add(objLeadConvert);
                }
            }
        }
        if(!leadConvertList.isEmpty()) {
            List<Database.LeadConvertResult> leadConvertResultList = Database.convertLead(leadConvertList);
        }
    }
}
}