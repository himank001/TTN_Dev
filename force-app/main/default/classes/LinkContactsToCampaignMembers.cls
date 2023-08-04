public with sharing class LinkContactsToCampaignMembers {
    @AuraEnabled(cacheable = true)
    public static List<Contact> getContacts(String str) {
        if(!String.isBlank(str)){
            String name = '%'+str+'%';
            return[SELECT Id,FirstName,Account_Name__c,LastName,Email,Phone,Account.Name,Full_Name__c,Website__c,Title
                   FROM Contact 
                   WHERE Account.Name LIKE : name OR Email LIKE : name OR Full_Name__c LIKE : name OR Website__c LIKE : name OR Title LIKE : name LIMIT 200];
        }
        else{
            return null;
        }
    }
    
    @AuraEnabled(cacheable = true)
    public static List<Contact> getAllContacts(){
        try {
            return [SELECT Id,FirstName,Account_Name__c,LastName,Email,Full_Name__c,Phone,Account.Name,Website__c,Title FROM Contact LIMIT 500];
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }        
}