/*
*Test Data Class
*By:Rishi patel
*/
@isTest
public class TTN_TestData {
    public static List<Account> createAccounts(Integer count, Boolean persisted) {
        List<Account> accountList = new List<Account>();
        for(Integer i = 0;i < count;i++) {
            Account accountInstance = New Account();
            accountInstance.Name = 'Account'+'-'+String.valueOf(i);
            accountInstance.TTN_Engineering_IT__c = 24;
            accountInstance.TTN_Marketing__c = 1221;
            accountInstance.TTN_Operations__c = 12312;
            accountInstance.TTN_Others__c = 123;
            accountInstance.Type = 'ISV';
            accountInstance.Industry = 'Technology';
            accountInstance.TTN_Region_Geography__c = 'America East';
            accountInstance.TTN_Account_by_size__c = 'Small (50 - 200)';
            accountInstance.TTN_Boardline_Number__c = '(+1)-781-995-3403';
            accountInstance.BillingCity = 'Woburn';
            accountInstance.BillingState = 'Massachusetts';
            accountInstance.BillingCountry = 'United State';
            accountInstance.TTN_Timezone__c = '(GMT-05:00) Eastern Time (US and Canada)';
            accountInstance.TTN_Account_LinkedIn__c = 'https://www.linkedin.com/company/redline-trading-solutions/';
            accountInstance.NumberOfEmployees = 21;

            accountList.add(accountInstance);
        }
        if(!accountList.isEmpty()) {
            if(persisted) {
                INSERT accountList;
            }
        }
        return accountList;
    }
    public static List<Contact> createContacts(Integer count, Boolean persisted,Id accountId) {
        List<Contact> contactList = new List<Contact>();
        for(Integer i = 0;i < count;i++) {
            Contact contactInstance = new Contact();
            contactInstance.LeadSource = 'OLG';
            contactInstance.TTN_Contact_Status__c = 'Target';
            contactInstance.TTN_DRA_Name__c = 'Prashant Kashyap';
            contactInstance.AccountId = accountId;
            contactInstance.FirstName = 'Mark';
            contactInstance.LastName = 'LaForest';
            contactInstance.Title = 'VP Engineering';
            contactInstance.TTN_Department_List__c = 'IT & Engineering';
            contactInstance.Phone = '(+1)-781-995-3403';
            contactInstance.MobilePhone = '(+1)-781-995-3403';
            contactInstance.TTN_Extension_Dest_No__c = '1008';
            contactInstance.MailingCity = 'Woburn';
            contactInstance.MailingState = 'Massachusetts';
            contactInstance.MailingCountry = 'United States';
            contactInstance.TTN_Region_Geography__c = 'America East';
            contactInstance.TTN_Timezone__c = '(GMT-05:00) Eastern Time (US and Canada)';
            contactInstance.TTN_Contact_LinkedIn__c = 'https://www.linkedin.com/in/mark-laforest-b8395b3';
            contactInstance.Salutation = 'Mr.';

            contactList.add(contactInstance);
        }

        if(!contactList.isEmpty()) {
            if(persisted) {
                INSERT contactList;
            }
        }
        return contactList;
    }
    public static List<Lead> createLeads(Integer count,Boolean persisted) {
        List<Lead> leadList = new List<Lead>();
        for(Integer i=0; i < count; i++) {
            Lead objLead = new Lead();
            objLead.LastName = 'cooper';
            objLead.status = 'New';
            objLead.Company = 'TTN';

            leadList.add(objLead);
        }
        if(!leadList.isEmpty()) {
            if(persisted) {
                INSERT leadList;
            }
        }
        return leadList;
    }
    public static List<TTN_Tag__c> createTags(integer count,Boolean persisted) {
        List<TTN_Tag__c> tags = new List<TTN_Tag__c>();
        for(Integer i = 0;i<count;i++) {
            TTN_Tag__c obj = new TTN_Tag__c();
            obj.Name = 'Tag_'+String.valueOf(i);
            tags.add(obj);
        }
        if(!tags.isEmpty()) {
            if(persisted) {
                INSERT tags;
            }
        }
        return tags;
    }
    public static List<Event> createEvents(integer count,Boolean persisted) {
        List<Event> events = new List<Event>();
        for(Integer i = 0;i<count;i++) {
            Event obj = new Event();
            obj.Subject = 'Meeting';
            obj.StartDateTime = System.now();
            obj.EndDateTime = System.now().addHours(1);
            events.add(obj);
        }
        if(persisted) {
            Insert events;
        }
        return events;
    }
    public static List<Task> createTasks(integer count,Boolean persisted) {
        List<Task> tasks = new List<Task>();
        for(Integer i = 0;i<count;i++) {
            Task obj = new Task();
            obj.Subject = 'Meeting';
            obj.priority = 'Normal';
            obj.status = 'open';
            tasks.add(obj);
        }
        if(persisted) {
            Insert tasks;
        }
        return tasks;
    }
}