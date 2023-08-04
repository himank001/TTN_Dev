/* 
    This class is used to handle if a trigger is active or not 
    --------------------------------------------------------------------------------------
    Version#     Date                           Author                    Description
    --------------------------------------------------------------------------------------
    1.0          17-Feb-2020                    Rishi Patel               Initial Version
*/
public class TTN_TriggerHandler {
    /*
        This method is used to check if trigger switch is Active or not
    */
    public static Boolean run(String triggerName) {
        Set<String> triggerNames = new Set<String>();
        Boolean isTriggerActive = false;
        triggerNames.add('TTN_All_Trigger');
        if(triggerName != NULL && triggerName != '') {
            triggerNames.add(triggerName);
        }
        List<TTN_Feature_Control__mdt> featureControlMetaDatas = [SELECT Id,DeveloperName,
                                                                    TTN_Active__c
                                                                    FROM TTN_Feature_Control__mdt 
                                                                    WHERE DeveloperName IN:triggerNames];
        Map<String, TTN_Feature_Control__mdt> featureControlMap = 
            new Map<String, TTN_Feature_Control__mdt>();
        if(featureControlMetaDatas != NULL && !featureControlMetaDatas.isEmpty()) {
            for(TTN_Feature_Control__mdt featureControl : featureControlMetaDatas) {
                featureControlMap.put(featureControl.DeveloperName,featureControl);
            }
            if(
                featureControlMap.containsKey('TTN_All_Trigger') 
                && 
                featureControlMap.get('TTN_All_Trigger').TTN_Active__c 
                && 
                featureControlMap.containsKey(triggerName) 
                && 
                featureControlMap.get(triggerName).TTN_Active__c
            ) {
                isTriggerActive = true;
            }
        }
        return isTriggerActive;
    }
}