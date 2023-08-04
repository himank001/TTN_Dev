/*
 * Description: Test Class For TTN_TaskTriggerHandler
 * By: Rishi
 * Date: 17/2/20
*/
@isTest(seeAllData = false)
public class TTN_TaskTriggerHandlerTest {
    @TestSetup
    static void setupData(){
        List<Account> accountList = TTN_TestData.createAccounts(1,false);
        accountList[0].Website = 'www.redlinetrading.com';
        
        INSERT accountList;
        
        List<Contact> contactsList = TTN_TestData.createContacts(2,false,accountList[0].Id);
        contactsList[0].Email = 'mark.laforest@redlinetrading.com';
        contactsList[1].Email = 'varun.mahendra@redlinetrading.com';
        
        INSERT contactsList;
    }
    @isTest
    static void tagAccountTest() {
        List<Contact> contacts = [SELECT Id,AccountId FROM Contact];
        List<Task> tasks = TTN_TestData.createTasks(2, false);
        Test.startTest();
        tasks[0].whoId = contacts[0].Id;
        Insert tasks;
        tasks[1].whoId = contacts[1].Id;
        Update tasks; 
        Test.stopTest();
        List<Task> updatedTasks = [SELECT Id,whatId FROM task];
        system.assertEquals(updatedTasks[0].whatId, contacts[0].AccountId);
        system.assertEquals(updatedTasks[1].whatId, contacts[0].AccountId);
    }
}