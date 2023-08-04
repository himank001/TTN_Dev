/*
 * Description:Test Class For TTN_AccountTriggerHandler
 * By:Rishi
 * Date: 17/2/20
*/
@isTest(seeAllData = false)
public class TTN_AccountTriggerHandlerTest {
    @testSetup
    static void setupData() {
        List<Account> accountList = TTN_TestData.createAccounts(3,false);
        accountList[0].Website = 'www.redlinetrading.com';
        accountList[1].Website = 'www.leveltenenergy.com';
        accountList[2].Website = 'www.tricerat.com';
        for(Account objAccount : accountList) {
            objAccount.TTN_Append_Tags__c = True;
        }
        accountList[0].TTN_Tags__c = 'test_tag0';
        accountList[1].TTN_Tags__c = 'test_tag1';
        accountList[2].TTN_Tags__c = 'test_tag2';
        INSERT accountList;
    }
    @isTest
    static void appendTagsCheckboxUpdateTest() {
        List<Account> accounts = [SELECT Id,TTN_Append_Tags__c FROM Account];
        system.assertEquals(accounts[0].TTN_Append_Tags__c,false);
        system.assertEquals(accounts[1].TTN_Append_Tags__c,false);
    }
    @isTest
    static void appendTagTest() {
        List<Account> accounts = [SELECT Id,TTN_Tags__c,TTN_Append_Tags__c FROM Account];
        String textToAppend = 'test_tag';
        Test.startTest();
        if(accounts != NULL && !accounts.isEmpty()) {
            for(Account accountInstance : accounts) 
            {
                accountInstance.TTN_Tags__c = textToAppend;
                accountInstance.TTN_Append_Tags__c = True;
            }
            UPDATE accounts;
        }
        Test.stopTest();
        List<Account> updatedaccounts = [SELECT Id,TTN_Tags__c,TTN_Append_Tags__c FROM Account];
        system.assertEquals(updatedaccounts[0].TTN_Tags__c,'test_tag0'+', '+textToAppend);
        system.assertEquals(updatedaccounts[1].TTN_Tags__c,'test_tag1'+', '+textToAppend);
        system.assertEquals(updatedaccounts[2].TTN_Tags__c,'test_tag2'+', '+textToAppend);
    }
    @isTest
    static void tagAssignmentsTest() {
        List<Account> accounts;
        accounts = [SELECT Id,TTN_Tags__c,TTN_Append_Tags__c FROM Account];
        String textToAppend = 'test_tag';
        Test.startTest();
        if(accounts != NULL && !accounts.isEmpty()) {
            for(Account accountInstance : accounts) 
            {
                accountInstance.TTN_Tags__c += ', '+textToAppend;
            }
            UPDATE accounts;
        }
        Test.stopTest();
        List<Account> updatesAccounts = [SELECT Id,(SELECT Id FROM Tag_Assignments__r),TTN_Tags__c,TTN_Append_Tags__c FROM Account];
        System.assertEquals(updatesAccounts[0].Tag_Assignments__r.size(), 2);
        System.assertEquals(updatesAccounts[1].Tag_Assignments__r.size(), 2);
        System.assertEquals(updatesAccounts[2].Tag_Assignments__r.size(), 2);
    }
    @isTest
    static void tagAssignmentsRemovedTagsTest() {
        List<Account> accounts;
        accounts = [SELECT Id,TTN_Tags__c,TTN_Append_Tags__c FROM Account];
        Test.startTest();
        if(accounts != NULL && !accounts.isEmpty()) {
            for(Account accountInstance : accounts) 
            {
                accountInstance.TTN_Tags__c = NULL;
            }
            UPDATE accounts;
        }
        Test.stopTest();
        List<Account> updatesAccounts = [SELECT Id,(SELECT Id FROM Tag_Assignments__r),TTN_Tags__c,TTN_Append_Tags__c FROM Account];
        System.assertEquals(updatesAccounts[0].Tag_Assignments__r.size(), 0);
        System.assertEquals(updatesAccounts[1].Tag_Assignments__r.size(), 0);
        System.assertEquals(updatesAccounts[2].Tag_Assignments__r.size(), 0);
    }
}