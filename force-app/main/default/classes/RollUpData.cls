public class RollUpData {
    @InvocableMethod(label='Rollup Data' Description = 'Roll Up Sum')
    public static void execute(List<Request> requestLst) {
        RollUpData.updateRollups(JSON.serialize(requestLst));
    }
    @future
    public static void updateRollups(String reqStr) {
        try{
            List<Request> requestLst = (List<RollUpData.Request>) JSON.deserialize(
                reqStr,
                List<RollUpData.Request>.class
            );
            String soql =
                'SELECT COUNT(Id), ' +
                requestLst[0].rollupFunction +
                '(' +
                requestLst[0].rollupFieldApiName +
                '), ' +
                requestLst[0].lookupObjectApiName +
                ' FROM ' +
                requestLst[0].rollupObjectApiName;
            soql += ' WHERE ';
            if (requestLst[0].filter != '' && requestLst[0].filter != null) {
                soql += '(' + requestLst[0].filter + ') AND ';
            }
            List<String> recordIds = new List<String>();
            List<String> priorRecordIds = new List<String>();
            Map<String, String> recordIdMap = new Map<String, String>();
            for (Request req : requestLst) {
                recordIds.add(req.recordId);
                if (req.priorRecordId != null && req.priorRecordId != '') {
                    recordIds.add(req.priorRecordId);
                }
            }
            soql += requestLst[0].lookupFieldApiName + ' IN:recordIds';
            soql += ' GROUP BY ' + requestLst[0].lookupObjectApiName;
            List<AggregateResult> result = Database.query(soql);
            List<SObject> sObjLst = new List<SObject>();
            for (AggregateResult ar : result) {
                String recordId = (String) ar.get(requestLst[0].lookupObjectApiName);
                SObject sObj = ((Id) recordId).getSObjectType().newSObject(recordId);
                sObj.put(requestLst[0].fieldToUpdate, ar.get('expr1'));
                sObjLst.add(sObj);
            }
            update sObjLst;
        }
        catch(exception e){
            
        }
    }
    
    public class Request {
        @InvocableVariable(label='Field to update Api Name' required=true)
        public String fieldToUpdate;
        @InvocableVariable(label='Rollup Field Api Name' required=true)
        public String rollupFieldApiName;
        @InvocableVariable(label='Lookup Field Api Name' required=true)
        public String lookupFieldApiName;
        @InvocableVariable(label='Rollup Object Api Name' required=true)
        public String rollupObjectApiName;
        @InvocableVariable(label='Lookup Object Api Name' required=true)
        public String lookupObjectApiName;
        @InvocableVariable(label='Rollup Function' required=true)
        public String rollupFunction;
        @InvocableVariable(label='Filter' required=false)
        public String filter;
        @InvocableVariable(label='RecordId' required=true)
        public String recordId;
        @InvocableVariable(label='Prior RecordId' required=false)
        public String priorRecordId;
    }
}