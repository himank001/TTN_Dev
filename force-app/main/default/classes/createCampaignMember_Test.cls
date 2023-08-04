@isTest
public class createCampaignMember_Test {
    @isTest
    public static void testCreateCampMember() {
        //  try{
        Account acct=new Account();
        acct.Name='Test Account';
        acct.Website='www.test.com';
        acct.Type='ISV';
        acct.TTN_Account_by_size__c='StartUp (<50)';
        acct.Industry='Automobile';
        acct.TTN_Region_Geography__c='Africa';
        acct.TTN_Relation_Type__c='No Relation';
        insert acct;
        
        Contact con=new Contact();
        con.FirstName='Test';
        con.LastName='Contact';
        con.Email='TestContact@mail.com';
        con.AccountId=acct.Id;
        con.Title='Test Title';
        con.TTN_Department_List__c='Finance';
        con.Contact_Relationship_Type__c='Suspect';
        con.TTN_Region_Geography__c='Africa';
        con.TTN_Contact_Status__c='Target';
        con.LeadSource='OLG';
        insert con;
        
        Campaign__c c = new Campaign__c();
        c.Region_Geography__c = 'ANZ';
        c.Start_Date__c = system.today();
        c.EndDate__c = system.today();
        Insert c;
        
        createCampaignMember.Request request = new createCampaignMember.Request();
        request.campaignJson = '[{"Id":'+ '\"'+con.Id + '\"'+ ',"FirstName":"Test","LastName":"Contact","Email":"TestContact@mail.com","Phone":"725216872","AccountId":'+'\"'+acct.Id+'\"'+',"Account":{"Name":"Test Account","Id":'+'\"'+acct.Id+'\"}}]';
        system.debug('request JSOn--'+request.campaignJson);
        request.campaignId = c.Id;
        request.ownerId = UserInfo.getUserId();
        
        Test.startTest();
        createCampaignMember.createCampMember(new List<createCampaignMember.Request>{ request });
        Test.stopTest();
        //  }
        //   catch(exception e){
        
        //}
    }
}