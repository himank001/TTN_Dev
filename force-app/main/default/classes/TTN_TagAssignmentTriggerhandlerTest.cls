/*
 * Description: Test Class For TTN_TagAssignmentTriggerHandler
 * By: Rishi
 * Date: 17/2/20
*/
@isTest(seeAllData = false)
public class TTN_TagAssignmentTriggerhandlerTest {
    @TestSetup
    static void makeData(){
        List<Account> accountList = TTN_TestData.createAccounts(2,false);
        accountList[0].website = 'www.ttn.com';
        accountList[1].website = 'www.ttn1.com';

        INSERT accountList;

        List<Contact> contactList = TTN_TestData.createContacts(2,false,accountList[0].Id);
        contactList[0].Email = 'mark.laforest@redlinetrading.com';
        contactList[1].Email = 'varun.mahendra@redlinetrading.com';
        INSERT contactList;

        List<TTN_Tag__c> tags = TTN_TestData.createTags(2,true);
    }
    @isTest
    static void updateTagsOnRelatedRecordsAccountTest() {
        List<Account> accountList = [SELECT Id,TTN_Tags__c FROM Account];
        String tagText = 'tag1';
        String tagText2 = 'tag2';
        
        accountList[0].TTN_Tags__c = tagText+', '+tagText2;
        accountList[1].TTN_Tags__c = tagText+', '+tagText2;
        
        UPDATE accountList;

        List<TTN_Tag_Assignment__c> tagAssignments = [
            SELECT Id,TTN_Tag__c,TTN_Tag__r.Name,TTN_Account__c FROM TTN_Tag_Assignment__c
        ];
        List<TTN_Tag_Assignment__c> tagAssignmentsToDelete = new List<TTN_Tag_Assignment__c>();
        if(!tagAssignments.isEmpty()) {
            for(TTN_Tag_Assignment__c assignment : tagAssignments) {
                if(
                    assignment.TTN_Account__c == accountList[0].Id 
                    && 
                    assignment.TTN_Tag__r.Name == tagText
                ) {
                    tagAssignmentsToDelete.add(assignment);
                }
                if(
                    assignment.TTN_Account__c == accountList[1].Id 
                    && 
                    assignment.TTN_Tag__r.Name == tagText2
                ) {
                    tagAssignmentsToDelete.add(assignment);
                }
            }
            if(!tagAssignmentsToDelete.isEmpty()) {
                DELETE tagAssignmentsToDelete;
            }
        }
        List<Account> updatedAccountList = [SELECT Id,TTN_Tags__c FROM Account];
        System.assertEquals(updatedAccountList[0].TTN_Tags__c != NULL,true);
        System.assertEquals(updatedAccountList[1].TTN_Tags__c != NULL,true);
    }
    @isTest
    static void updateTagsOnRelatedRecordsContactTest() {
        List<Contact> contactList = [SELECT Id,TTN_Tags__c FROM Contact];
        String tagText = 'tag1';
        String tagText2 = 'tag2';
        
        contactList[0].TTN_Tags__c = tagText+', '+tagText2;
        contactList[1].TTN_Tags__c = tagText+', '+tagText2;
        
        UPDATE contactList;

        List<TTN_Tag_Assignment__c> tagAssignments = [
            SELECT Id,TTN_Tag__c,TTN_Tag__r.Name,TTN_Account__c,TTN_Contact__c 
            FROM TTN_Tag_Assignment__c
        ];
        List<TTN_Tag_Assignment__c> tagAssignmentsToDelete = new List<TTN_Tag_Assignment__c>();
        if(!tagAssignments.isEmpty()) {
            for(TTN_Tag_Assignment__c assignment : tagAssignments) {
                if(
                    assignment.TTN_Contact__c == contactList[0].Id 
                    && 
                    assignment.TTN_Tag__r.Name == tagText
                ) {
                    tagAssignmentsToDelete.add(assignment);
                }
                if(
                    assignment.TTN_Contact__c == contactList[1].Id 
                    && 
                    assignment.TTN_Tag__r.Name == tagText2
                ) {
                    tagAssignmentsToDelete.add(assignment);
                }
            }
            if(!tagAssignmentsToDelete.isEmpty()) {
                DELETE tagAssignmentsToDelete;
            }
        }
        List<Contact> updatedContactList = [SELECT Id,TTN_Tags__c FROM Contact];
        System.assertEquals(updatedContactList[0].TTN_Tags__c != NULL,true);
        System.assertEquals(updatedContactList[1].TTN_Tags__c != NULL,true);
    }
    @isTest
    static void updateTagsOnRelatedRecordsInsertTest() {
        List<Account> accountList = [SELECT Id,TTN_Tags__c FROM Account];
        List<Contact> contactList = [SELECT Id,TTN_Tags__c FROM Contact];
        List<TTN_Tag__c> tags = [SELECT Id,Name FROM TTN_Tag__c];
        List<TTN_Tag_Assignment__c> assignments = new List<TTN_Tag_Assignment__c>();
        for(Account objAccount : accountList) {
            for(TTN_Tag__c objTag : tags) {
                TTN_Tag_Assignment__c assignment = new TTN_Tag_Assignment__c();
                assignment.TTN_Account__c = objAccount.Id;
                assignment.TTN_Tag__c = objTag.Id;
                assignments.add(assignment);
            }
        }
        for(Contact objContact : contactList) {
            for(TTN_Tag__c objTag : tags) {
                TTN_Tag_Assignment__c assignment = new TTN_Tag_Assignment__c();
                assignment.TTN_Contact__c = objContact.Id;
                assignment.TTN_Tag__c = objTag.Id;
                assignments.add(assignment);
            }
        }
        INSERT assignments;
        TTN_TagAssignmentTriggerHandler.updateTagsOnRelatedRecords(assignments,true);
        //TTN_TagAssignmentTriggerHandler.updateTagsOnRelatedRecords(assignments,false);
        List<Account> updatedAccountList = [SELECT Id,TTN_Tags__c FROM Account];
        system.assertEquals(updatedAccountList[0].TTN_Tags__c != NULL, false);
    }
}