public with sharing class LeadConversionHandler {
    @InvocableMethod
    public static List<Id> convertLeads(List<Id> leadIds) {
        List<Id> convertedContactIds = new List<Id>();

        // Query the Account ID for "Education Only Contacts"
        Account educationOnlyAccount = [
            SELECT Id FROM Account WHERE Name = 'Education Only Contacts' LIMIT 1
        ];

        // Query existing leads
        List<Lead> leadsToConvert = [
            SELECT Id, Homewise_Branch_Location__c FROM Lead WHERE Id IN :leadIds
        ];

        for (Lead lead : leadsToConvert) {
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(lead.Id);
            lc.setConvertedStatus('Active'); // Adjust to actual converted status
            lc.setDoNotCreateOpportunity(true); // Set to false if you want an Opportunity

            // Ensure required field is set on lead before conversion
            if (lead.Homewise_Branch_Location__c == null) {
                lead.Homewise_Branch_Location__c = 'Default Branch'; // Set default value
                update lead;
            }

            // Convert the Lead
            Database.LeadConvertResult result = Database.convertLead(lc);

            // If conversion was successful, retrieve the new Contact Id
            if (result.isSuccess()) {
                Id contactId = result.getContactId();
                convertedContactIds.add(contactId);
                
                // Ensure the Contact is associated with "Education Only Contacts"
                if (contactId != null) {
                    Contact updatedContact = new Contact(
                        Id = contactId,
                        AccountId = educationOnlyAccount.Id
                    );
                    update updatedContact;
                }
            }
        }
        return convertedContactIds;
    }
}