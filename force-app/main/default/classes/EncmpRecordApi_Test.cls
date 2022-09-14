/**
 * Tests EncmpRecordApi.cls
 * @author      Brandon DeMatteis, Enclude
 * @since       17/12/2021
 */
@isTest
public class EncmpRecordApi_Test {

    private static Map<String, Object> fields = new Map<String, Object>{
        'Name' => 'Test Account',
        'AnnualRevenue' => 55555.55
    };

    @isTest
    static void create() {

        Test.startTest();
        Id recordId = EncmpRecordApi.create('Account', fields);
        Test.stopTest();

        System.assertNotEquals(null, recordId, 'EncmpRecordApi.create should have returned the created record Id');

        Account acc = [SELECT FIELDS(STANDARD) FROM Account WHERE Id = :recordId LIMIT 1];

        for (String field : fields.keySet()) {
            System.assertEquals(fields.get(field), acc.get(field), 'EncmpRecordApi.create set a field to an unexpected value');
        }

    }

    @isTest
    static void edit() {
        Account acc = new Account(Name = 'Test', AnnualRevenue = 555.55);
        insert acc;

        Map<String, Object> editFields = new Map<String, Object>{
            'Name' => 'Test Edit',
            'AnnualRevenue' => 555.55
        };

        Test.startTest();
        Id editedRecordId = EncmpRecordApi.edit('Account', editFields, acc.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, editedRecordId, 'EncmpRecordApi.edit should have returned the edited record Id');
        
        Account accUpdated = [SELECT Name, AnnualRevenue FROM Account WHERE Id = :acc.Id LIMIT 1];
        
        for (String field : editFields.keySet()) {
            System.assertEquals(editFields.get(field), accUpdated.get(field), 'EncmpRecordApi.edit set a field to an unexpected value');
        }

    }

    @isTest
    static void errors() {
        Contact c = new Contact(LastName = 'Test');
        insert c;

        Map<String, Object> fields = new Map<String, Object> {
            'LastName' => 'Error Test',
            'Email' => 'invalid'
        };

        AuraHandledException createError;
        AuraHandledException updateError;

        Test.startTest();
        try {
            EncmpRecordApi.create('Contact', fields);
        } catch(AuraHandledException e) {
            createError = e;
        }
        try {
            EncmpRecordApi.edit('Contact', fields, c.Id); //NOPMD
        } catch(AuraHandledException e) {
            updateError = e;
        }
        Test.stopTest();
        
        String msg = createError.getMessage();
        System.assertNotEquals(null, createError.getMessage(), 'EncmpRecordApi.create should have thrown an AuraHandledException');
        System.assertNotEquals(null, updateError.getMessage(), 'EncmpRecordApi.update should have thrown an AuraHandledException');
    }

}
