/*
 * Description: Test Class For TTN_TriggerHandler
 * By: Rishi
 * Date: 17/2/20
*/
@isTest(seeAllData = false)
public class TTN_TriggerHandlertest {
	@isTest
    static void runTest() {
        Test.startTest();
        Boolean isActive = TTN_TriggerHandler.run('TTN_Account_Trigger');
        Test.stopTest();
        System.assertEquals(isActive,true);
    }
    @isTest
    static void runTestNegativeTest() {
        Test.startTest();
        Boolean isActive = TTN_TriggerHandler.run('Test_Invalid_Data');
        Test.stopTest();
        System.assertEquals(isActive,false);
    }
}