/*
* Description: Test Class For TTN_LeadTriggerHandler
* By: Rishi
* Date: 17/2/20
*/
@isTest(seeAllData = False)
public class TTN_LeadTriggerHandlerTest {
    @testSetup
    static void setupData() {
        List<Account> accountList = TTN_TestData.createAccounts(1,false);
        accountList[0].Website = 'www.redlinetrading.com';
        accountList[0].Name = 'TTN';
        INSERT accountList;
    }
    @isTest
    static void convertOnCreateTest() {
        Test.startTest();
        List<Lead> leads = TTN_TestData.createLeads(2,false);
        Insert leads;
        Test.stopTest();
        List<Lead> convertedLeads = [SELECT Id,IsConverted FROM Lead WHERE IsConverted=TRUE];
        System.assertEquals(leads.size(), convertedLeads.size());
    }
}