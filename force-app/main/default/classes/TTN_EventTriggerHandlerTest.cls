/*
 * Description: Test Class For TTN_EventTriggerHandler
 * By: Rishi
 * Date: 17/2/20
*/
@isTest(seeAllData = false)
public class TTN_EventTriggerHandlerTest {
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
        List<Event> events = TTN_TestData.createEvents(2, false);
        Test.startTest();
        events[0].whoId = contacts[0].Id;
        Insert events;
        events[1].whoId = contacts[1].Id;
        Update events; 
        Test.stopTest();
        List<Event> updatedEvents = [SELECT Id,whatId FROM Event];
        system.assertEquals(updatedEvents[0].whatId, contacts[0].AccountId);
        system.assertEquals(updatedEvents[1].whatId, contacts[0].AccountId);
    }
}