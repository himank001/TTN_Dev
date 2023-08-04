/*****************************************************************************************
 --------------------------------------------------------------------------------------
    Version#       Date                           Author                    Description
    --------------------------------------------------------------------------------------
    1.0         17-Jan-2017                     Vivek Kumar               Initial Version
    --------------------------------------------------------------------------------------
*******************************************************************************************/
trigger LeadTrigger on Lead (after insert) {
    Boolean isActive = TTN_TriggerHandler.run('TTN_Lead_Trigger');
    if(isActive) {
        if(Trigger.isAfter && Trigger.isInsert)
        {
            TTN_LeadTriggerHandler.afterInsert(Trigger.New);
        }
    }
}