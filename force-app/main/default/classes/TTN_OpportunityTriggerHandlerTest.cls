@isTest(seeAllData = false)
public class TTN_OpportunityTriggerHandlerTest {
@TestSetup
    static void setupData(){
        List<Account> accountList = TTN_TestData.createAccounts(1,false);
        accountList[0].Website = 'www.redlinetrading.com';
        accountList[0].TTN_Tags__c = 'test_tag0';
        
        INSERT accountList;

        List<Contact> contactsList = TTN_TestData.createContacts(3,false,accountList[0].Id);
        contactsList[0].Email = 'mark.laforest@redlinetrading.com';
        contactsList[1].Email = 'varun.mahendra@redlinetrading.com';
        contactsList[2].Email = 'ed.cook@redlinetrading.com';
        contactsList[0].Contact_Relationship_Type__c = 'Suspect';
        contactsList[1].Contact_Relationship_Type__c = 'Suspect';
        contactsList[2].Contact_Relationship_Type__c = 'Suspect';
        for(Contact objContact : contactsList) {
            objContact.TTN_Append_Tags__c = True;
        }
        contactsList[0].TTN_Tags__c = 'test_tag0';
        contactsList[1].TTN_Tags__c = 'test_tag1';
        contactsList[2].TTN_Tags__c = 'test_tag2';

        INSERT contactsList;
    }
    
    @isTest
    static void appendTagTest() {
        List<Contact> contacts = [SELECT Id,TTN_Tags__c,TTN_Append_Tags__c,AccountId FROM Contact];
        List<Opportunity> lstOpprt = new List<Opportunity>();
        Test.startTest();
        if(contacts != NULL && !contacts.isEmpty()) {
            for(Contact contactInstance : contacts) 
            {
              Opportunity each = new Opportunity();
              each.CloseDate = Date.today().addDays(10);
              each.TTN_Contact_Name__c = contactInstance.id;
              each.StageName ='Opportunity Identification Stage (Lead Qualified)';
              each.AccountId = contactInstance.AccountId;
              each.TTN_Business_Unit_Name__c = 'ANZ';
              each.Name = 'Test-oppty';
              each.Amount =34576;
              each.TTN_Engagement_Models__c = 'Cost Plus';
              each.TTN_Opportunity_Created_Date__c = Date.today();
              lstOpprt.add(each);
              break;
            }
            INSERT lstOpprt ;
            lstOpprt[0].StageName = '10% (BANT Qualified)';
            lstOpprt[0].TTN_Primary_Service_Offering__c ='Cloud & DevOps';
            lstOpprt[0].TTN_Sub_Service_Offering__c = 'DevOps Automation';
            update lstOpprt[0];
            delete lstOpprt[0];
        }
        Test.stopTest();
    }

}