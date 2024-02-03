public without sharing class LeadChartController {
    @AuraEnabled(cacheable=true)
    public static List<LeadChartData> getLeadChartData() {
        List<LeadChartData> chartDataList = new List<LeadChartData>();

        Integer totalLeads = [SELECT COUNT() FROM Lead];
        chartDataList.add(new LeadChartData('', totalLeads));
        
        // Query Lead records grouped by Source field
        AggregateResult[] results = [SELECT LeadSource, COUNT(Id) c FROM Lead GROUP BY LeadSource];

        for (AggregateResult result : results) {
            String source = (String)result.get('LeadSource') == Null ? 'Leads with no lead source' : (String)result.get('LeadSource');
            Integer count = (Integer)result.get('c');
            chartDataList.add(new LeadChartData(source, count));
        }

        return chartDataList;
    }
    
    @AuraEnabled
    public static List<Property__c> getInventoryData() {
        return [SELECT Id, Name FROM Property__c Where Include_in_Newsletter__c	= true Order By Name];
    }

    public class LeadChartData {
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public Integer count { get; set; }

        public LeadChartData(String label, Integer count) {
            this.label = label;
            this.count = count;
        }
    }

    @AuraEnabled
    public static Boolean sendData(List<String> inventory, String leadSource, String channel, String message, String template, String freeText) {
        try {
                API_Setting__c apiCustomSetting;
                // Create the JSON payload
                Map<String, Object> payload = new Map<String, Object>();
                if (channel == 'Email') {
                    apiCustomSetting = API_Setting__c.getInstance('DataAPIEmail');
                } else {
                    apiCustomSetting = API_Setting__c.getInstance('DataAPISMS');
                    payload.put('message', message);
                }
                String endpointUrl = apiCustomSetting.Inventory_Data_Endpoint__c;

                payload.put('template', template);
                payload.put('freeText', freeText);
                payload.put('leadSource', leadSource);
                payload.put('properties', inventory);
                payload.put('sfObject', 'Lead');
                payload.put('accessToken', 'gf3xVju03YKfK8ranQ1sHY745L2BzDIkL9qifa');
                
                // Convert the payload to JSON string
                String payloadJson = JSON.serialize(payload);
                return APIUtility.sendHttpRequest(endpointUrl, payloadJson);
        } catch (Exception e) {
            System.debug('--Error--'+e);
            return false;
        }
    }
}