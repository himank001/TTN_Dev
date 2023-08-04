@isTest
public class deleteCampaignContactAndAccount_Test {
    @isTest
    static void testDeleteCampaignAccount(){
        
        Account acct=new Account();
        acct.Name='Test Account';
        acct.Website='www.test.com';
        acct.Type='ISV';
        acct.TTN_Account_by_size__c='StartUp (<50)';
        acct.Industry='Automobile';
        acct.TTN_Region_Geography__c='Africa';
        acct.TTN_Relation_Type__c='No Relation';
        insert acct;
        List<Contact> contacts = new List<Contact>();
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
        
        Campaign__c Cam=new Campaign__c();
        Cam.Name='Test Campaign';
        Cam.Region_Geography__c='Africa';
        Cam.Start_Date__c=system.today();
        Cam.EndDate__c=system.today()+10;
        cam.Source__c = 'OLG';
        insert Cam;
        
        List<Campaign_Accounts__c> CamAcctList=new List<Campaign_Accounts__c>();
        Campaign_Accounts__c CamAcct=new Campaign_Accounts__c();
        CamAcct.Name='Test Campaign';
        CamAcct.Campaign__c=Cam.Id;
        CamAcctList.add(CamAcct);
        insert CamAcctList;
        List<Campaign_Contacts__c> CamConList=new List<Campaign_Contacts__c>();
        Campaign_Contacts__c CamCon =new Campaign_Contacts__c();
        CamCon.Name='Test Contact';
        CamCon.Contact__c=con.Id;
        CamCon.Campaign_Accounts__c=CamAcct.Id;
        CamCon.Campaign_Contact_Source__c = 'OLG';
        CamCon.Campaign__c=Cam.Id;
        CamConList.add(CamCon);
        insert CamConList;
        
        Test.startTest();
        deleteCampaignContactAndAccount.deleteCampaignAccount(CamConList);
        Test.stopTest();
    }
}