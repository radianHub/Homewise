public with sharing class LeadConversionHandler {
    @InvocableMethod
    public static List<Id> convertLeads(List<Id> leadIds) {
        List<Id> convertedContactIds = new List<Id>();
        
        // Query the Account ID for "Education Only Contacts"
        Account educationOnlyAccount = [
            SELECT Id FROM Account WHERE Name = 'Education Only Contacts' LIMIT 1
        ];
        
        for (Id leadId : leadIds) {
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(leadId);
            lc.setConvertedStatus('Active'); // Change to your actual converted status
            lc.setDoNotCreateOpportunity(true); // Set to false if you want an Opportunity
            
            // Convert the Lead
            Database.LeadConvertResult result = Database.convertLead(lc);
            
            // If conversion was successful, retrieve the new Contact Id
            if (result.isSuccess()) {
                Id contactId = result.getContactId();
                convertedContactIds.add(contactId);
                
                // Update the Contact to associate with the "Education Only Contacts" Account
                if (contactId != null) {
                    Contact updatedContact = new Contact(Id = contactId, AccountId = educationOnlyAccount.Id);
                    update updatedContact;
                }
            }
        }
        
        return convertedContactIds;
    }
}