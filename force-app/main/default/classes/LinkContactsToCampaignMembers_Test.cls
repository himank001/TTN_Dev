@isTest
public class LinkContactsToCampaignMembers_Test {
    @isTest
    static void testGetContacts(){
        Test.startTest();
        List<Contact> result = LinkContactsToCampaignMembers.getContacts('Test');
        Test.stopTest();
    }
    @isTest
    static void testGetContacts2(){
        Test.startTest();
        List<Contact> result = LinkContactsToCampaignMembers.getContacts('');
        Test.stopTest();
    }
    @isTest
    static void testGetAllContacts(){
        Test.startTest();
        List<Contact> result = LinkContactsToCampaignMembers.getAllContacts();
        Test.stopTest();
    }
}