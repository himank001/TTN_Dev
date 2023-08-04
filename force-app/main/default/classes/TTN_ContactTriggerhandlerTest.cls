/*
 * Description: Test Class For TTN_ContactTriggerHandler
 * By: Rishi
 * Date: 17/2/20
*/
@isTest(seeAllData = false)
public class TTN_ContactTriggerhandlerTest {
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
        for(Contact objContact : contactsList) {
            objContact.TTN_Append_Tags__c = True;
        }
        contactsList[0].TTN_Tags__c = 'test_tag0';
        contactsList[1].TTN_Tags__c = 'test_tag1';
        contactsList[2].TTN_Tags__c = 'test_tag2';

        INSERT contactsList;
    }
    @isTest
    static void appendTagsCheckboxUpdateTest() {
        List<Contact> contacts = [SELECT Id,TTN_Append_Tags__c FROM Contact];
        system.assertEquals(contacts[0].TTN_Append_Tags__c,false);
        system.assertEquals(contacts[1].TTN_Append_Tags__c,false);
    }
    @isTest
    static void appendTagTest() {
        List<Contact> contacts = [SELECT Id,TTN_Tags__c,TTN_Append_Tags__c FROM Contact];
        String textToAppend = 'test_tag';
        Test.startTest();
        if(contacts != NULL && !contacts.isEmpty()) {
            for(Contact contactInstance : contacts) 
            {
                contactInstance.TTN_Tags__c = textToAppend;
                contactInstance.TTN_Append_Tags__c = True;
            }
            UPDATE contacts;
        }
        Test.stopTest();
        List<Contact> updatedContacts = [SELECT Id,TTN_Tags__c,TTN_Append_Tags__c FROM Contact];
        system.assertEquals(updatedContacts[0].TTN_Tags__c,'test_tag0'+', '+textToAppend);
        system.assertEquals(updatedContacts[1].TTN_Tags__c,'test_tag1'+', '+textToAppend);
        system.assertEquals(updatedContacts[2].TTN_Tags__c,'test_tag2'+', '+textToAppend);
    }
    @isTest
    static void tagAssignmentsTest() {
        List<Contact> contacts;
        contacts = [SELECT Id,TTN_Tags__c,TTN_Append_Tags__c FROM Contact];
        String textToAppend = 'test_tag';
        Test.startTest();
        if(contacts != NULL && !contacts.isEmpty()) {
            for(Contact contactInstance : contacts) 
            {
                contactInstance.TTN_Tags__c += ', '+textToAppend;
            }
            UPDATE contacts;
        }
        Test.stopTest();
        List<Contact> updatedContacts = [SELECT Id,(SELECT Id FROM Tag_Assignments__r),TTN_Tags__c,TTN_Append_Tags__c FROM Contact];
        System.assertEquals(updatedContacts[0].Tag_Assignments__r.size(), 2);
        System.assertEquals(updatedContacts[1].Tag_Assignments__r.size(), 2);
        System.assertEquals(updatedContacts[2].Tag_Assignments__r.size(), 2);
    }
    @isTest
    static void tagAssignmentsRemovedTagsTest() {
        List<Contact> contacts;
        contacts = [SELECT Id,TTN_Tags__c,TTN_Append_Tags__c FROM Contact];
        Test.startTest();
        if(contacts != NULL && !contacts.isEmpty()) {
            for(Contact contactInstance : contacts) 
            {
                contactInstance.TTN_Tags__c = NULL;
            }
            UPDATE contacts;
        }
        Test.stopTest();
        List<Contact> updatedContacts = [SELECT Id,(SELECT Id FROM Tag_Assignments__r),TTN_Tags__c,TTN_Append_Tags__c FROM Contact];
        System.assertEquals(updatedContacts[0].Tag_Assignments__r.size(), 0);
        System.assertEquals(updatedContacts[1].Tag_Assignments__r.size(), 0);
        System.assertEquals(updatedContacts[2].Tag_Assignments__r.size(), 0);
    }
}