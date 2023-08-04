@isTest
public class RollUpData_TEST {

    @isTest
    public static void testExecute() {
        // Create test data
        List<RollUpData.Request> requestList = new List<RollUpData.Request>();
        RollUpData.Request request = new RollUpData.Request();
        request.fieldToUpdate = 'FieldToUpdate__c';
        request.rollupFieldApiName = 'RollupField__c';
        request.lookupFieldApiName = 'LookupField__c';
        request.rollupObjectApiName = 'RollupObject__c';
        request.lookupObjectApiName = 'LookupObject__c';
        request.rollupFunction = 'SUM';
        request.filter = 'SomeFilter';
        request.recordId = '001XXXXXXXXXXXX';
        request.priorRecordId = '002XXXXXXXXXXXX';
        requestList.add(request);
        
        // Enqueue the test job
        Test.startTest();
        RollUpData.execute(requestList);
        Test.stopTest();
        
        // Perform assertions or verifications
        // ...
    }
}