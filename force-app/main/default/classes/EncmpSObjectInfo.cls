/**
 * Wrapper for the Schema; provides ability to access field info from child relationship string (ex. 'Account.Name')
 * @author      Brandon DeMatteis
 * @since       17/12/2021
 */
public with sharing class EncmpSObjectInfo {
    private static Map<String,Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();

    /**
     * Returns Schema.DescribeSObjectResult for given object Api Name
     * @param {String} objectApiName
     * @return {Schema.DescribeSObjectResult}
     * @link https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_methods_system_sobject_describe.htm 
     */
    public static Schema.DescribeSObjectResult getDescribeSObjectResult(String objectApiName) {
        return globalDescribe.get(objectApiName).getDescribe();
    }

    /**
     * Returns Schema.DescribeFieldResult for given object API name + field API name
     * Supports deep child relationships (ex. 'CampaignMember', 'Contact.Account.Name')
     * @param {String} objectApiName
     * @param {String} fieldApiName
     * @return {Schema.DescribeFieldResult}
     * @link https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_methods_system_fields_describe.htm
     */
    public static Schema.DescribeFieldResult getFieldInfo(String objectApiName, String fieldApiName) {
        fieldApiName = fieldApiName.replace('__r', '__c');
        String[] fieldApiNames = fieldApiName.split('\\.');
        return getFieldInfo(objectApiName, fieldApiNames);
    }

    private static Schema.DescribeFieldResult getFieldInfo(String objectApiName, String[] fieldApiNames) {
        String fieldApiName = fieldApiNames.remove(0);
        if (!fieldApiNames.isEmpty() && !fieldApiName.endsWith('__c')) { fieldApiName += 'Id'; }
        Schema.DescribeFieldResult describeFieldResult = getDescribeFieldResult(objectApiName, fieldApiName);
        if (fieldApiNames.isEmpty()) { return describeFieldResult; }

        String parentObjectApiName = describeFieldResult?.getReferenceTo()?.get(0)?.getDescribe()?.getName();
        return getFieldInfo(parentObjectApiName, fieldApiNames);
    }

    private static Schema.DescribeFieldResult getDescribeFieldResult(String objectApiName, String fieldApiName) {
        Schema.DescribeSObjectResult sObjDescribe = getDescribeSObjectResult(objectApiName);
        Map<String,Schema.SObjectField> sObjDescribeMap = sObjDescribe?.fields?.getMap();
        return sObjDescribeMap?.get(fieldApiName)?.getDescribe();
    }
}