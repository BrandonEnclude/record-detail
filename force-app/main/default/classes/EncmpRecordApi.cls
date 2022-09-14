/**
 * Generic record API
 * Allows a record to be created and edited. This is a duplication of the standard uiRecordApi but handles errors, including validation errors
 * @author      Brandon DeMatteis, Enclude
 * @since       15/12/2021
 * @link https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.reference_lightning_ui_api_record
 */
public with sharing class EncmpRecordApi {
    /**
     * Create a record
     * @param {String}  objectApiName
     * @param {Map<String,Object>} fields   Map of field API names and their values 
     * @return {Id} Id of the created record
     */
    @AuraEnabled 
    public static Id create(String objectApiName, Map<String, Object> fields) {
        SObject sObj = Schema.getGlobalDescribe().get(objectApiName).newSObject();
        mapSObjectFields(sObj, fields);

        Database.SaveResult result = Database.insert(sObj, false);

        if (result.isSuccess()) {
            return result.getId();
        } else {
            throw new AuraHandledException(result.getErrors().get(0).getMessage());
        }
    }
    /**
     * Edit a record
     * @param {String}  objectApiName
     * @param {Map<String,Object>} fields   Map of field API names and their values 
     * @param {Id} recordId     Id of record to up updated
     * @return {Id} Id of the edited record
     */
    @AuraEnabled 
    public static Id edit(String objectApiName, Map<String, Object> fields, Id recordId) {
        objectApiName = String.escapeSingleQuotes(objectApiName);
        String selectStmt = String.escapeSingleQuotes(selectStmt(fields.keySet()));
        recordId = String.escapeSingleQuotes(recordId);
        
        String q = 'SELECT ' + selectStmt + ' FROM ' + objectApiName + ' WHERE Id = :recordId';
        SObject sObj = Database.query(q); //NOPMD
        mapSObjectFields(sObj, fields);

        Database.SaveResult result = Database.update(sObj, false);

        if (result.isSuccess()) {
            return result.getId();
        } else {
            throw new AuraHandledException(result.getErrors().get(0).getMessage());
        }
    }

    private static String selectStmt(Set<String> fieldApiNames) {
        return String.join(new List<String>(fieldApiNames), ',');
    }

    private static void mapSObjectFields(SObject sObj, Map<String, Object> fields) {
        for (String key : fields.keySet()) {
            Schema.DescribeFieldResult fieldInfo = EncmpSObjectInfo.getFieldInfo(String.valueOf(sObj.getSObjectType()), key);
            String fieldType = String.valueOf(fieldInfo.getType());
            if (fieldType == 'DATE') {
                sObj.put(key, parseDate(fields.get(key)));
            } else if (fieldType == 'DATETIME') {
                sObj.put(key, parseDatetime(fields.get(key)));
            } else {
                sObj.put(key, fields.get(key));
            }
        }
    }

    private static Date parseDate(Object dateObj) {
        if (dateObj == null) { return null; }
        return Date.valueOf((String)dateObj);
    }

    private static Datetime parseDatetime(Object datetimeObj) {
        if (datetimeObj == null) { return null; }
        return Datetime.valueOf((String)datetimeObj);
    }

}
