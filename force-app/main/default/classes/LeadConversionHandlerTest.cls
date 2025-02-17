@isTest
public class LeadConversionHandlerTest {
    @testSetup
    static void setupTestData() {
        // Create the "Education Only Contacts" Account
        Account educationOnlyAccount = new Account(Name = 'Education Only Contacts');
        insert educationOnlyAccount;

        // Create a default workflow user
        User defaultWorkflowUser = new User(
            FirstName = 'Default',
            LastName = 'User',
            Alias = 'duser',
            Email = 'defaultuser@example.com',
            Username = 'defaultuser@example.com.salesforce',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            LanguageLocaleKey = 'en_US'
        );
        insert defaultWorkflowUser;

        // Create a Test Lead with required field
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Company = 'Test Company',
            Status = 'New', // Ensure it's a valid Lead Status
            Branch_Location__c = 'Santa Fe' // Required field to bypass validation
        );
        insert testLead;
    }

    @isTest
    static void testLeadConversion() {
        // Query the test lead
        Lead testLead = [SELECT Id FROM Lead WHERE LastName = 'Lead' LIMIT 1];
        User defaultWorkflowUser = [SELECT Id FROM User WHERE Email = 'defaultuser@example.com' LIMIT 1];

        // Call the Apex Action
        Test.startTest();
        List<Id> convertedContactIds = LeadConversionHandler.convertLeads(new List<Id>{testLead.Id});
        Test.stopTest();

        // Assertions to validate the conversion
        System.assertNotEquals(null, convertedContactIds, 'The returned Contact ID list should not be null.');
        System.assertEquals(1, convertedContactIds.size(), 'One Contact should be created.');

        // Validate that the Lead is converted
        Lead convertedLead = [SELECT Id, IsConverted, ConvertedContactId FROM Lead WHERE Id = :testLead.Id];
        System.assertEquals(true, convertedLead.IsConverted, 'Lead should be converted.');
        System.assertNotEquals(null, convertedLead.ConvertedContactId, 'Lead should have a Converted Contact Id.');

        // Validate that the Contact exists and is assigned to "Education Only Contacts"
        Contact newContact = [SELECT Id, AccountId, Branch_Location__c, OwnerId FROM Contact WHERE Id = :convertedContactIds[0]];
        System.assertNotEquals(null, newContact, 'The converted Contact should exist.');

        // Validate that the Contact is associated with "Education Only Contacts"
        Account associatedAccount = [SELECT Id, Name FROM Account WHERE Id = :newContact.AccountId];
        System.assertEquals('Education Only Contacts', associatedAccount.Name, 'The Contact should be assigned to Education Only Contacts.');
        
        // Validate that Homewise Branch Location is retained
        System.assertEquals('Santa Fe', newContact.Branch_Location__c, 'Homewise Branch Location should be set.');

    }
}