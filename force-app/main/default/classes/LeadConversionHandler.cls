public with sharing class LeadConversionHandler {
    @InvocableMethod
    public static List<Id> convertLeads(List<Id> leadIds) {
        List<Id> convertedContactIds = new List<Id>();
        
        for (Id leadId : leadIds) {
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(leadId);
            lc.setConvertedStatus('Active'); // Change to your actual converted status
            lc.setDoNotCreateOpportunity(true); // Set to false if you want an Opportunity
            
            // Convert the Lead
            Database.LeadConvertResult result = Database.convertLead(lc);
            
            // If conversion was successful, retrieve the new Contact Id
            if (result.isSuccess()) {
                convertedContactIds.add(result.getContactId());
            }
        }
        
        return convertedContactIds;
    }
}