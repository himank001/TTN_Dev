trigger CampaignContactTrigger on Campaign_Contacts__c (before insert,before update,after insert, after delete, before delete) {
    if(trigger.isAfter && trigger.isDelete){
        deleteCampaignContactAndAccount.deleteCampaignAccount(trigger.old);
    }
    if(trigger.isBefore && trigger.isInsert){
        campaignContactsDataLoad.insertCampaignContact(trigger.new);
        //campaignContactsDataLoad.checkIfAlreadyCampaignContactPresent(trigger.new);
    }
    /*if(trigger.isBefore && trigger.isDelete){
        deleteCampaignContactAndAccount.notDeleteCampConc(trigger.old);
    }*/
}