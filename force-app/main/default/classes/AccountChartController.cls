public without sharing class AccountChartController {
    @AuraEnabled(cacheable=true)
    public static List<AccountChartData> getAccountChartData() {
        List<AccountChartData> chartDataList = new List<AccountChartData>();

        Integer totalAccounts = [SELECT COUNT() FROM Account];
        chartDataList.add(new AccountChartData('', totalAccounts));
        // Query Account records grouped by Source field
        AggregateResult[] results = [SELECT LeadSource__c, COUNT(Id) c FROM Account GROUP BY LeadSource__c];

        for (AggregateResult result : results) {
            String source = (String)result.get('LeadSource__c') == Null ? 'Account with no lead source' : (String)result.get('LeadSource__c');
            Integer count = (Integer)result.get('c');
            chartDataList.add(new AccountChartData(source, count));
        }

        return chartDataList;
    }
    
    @AuraEnabled
    public static List<Property__c> getInventoryData() {
        return [SELECT Id, Name FROM Property__c Where Include_in_Newsletter__c	= true Order By Name];
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

                payload.put('leadSource', leadSource);
                payload.put('properties', inventory);
                payload.put('template', template);
                payload.put('freeText', freeText);
                payload.put('sfObject', 'Account');
                payload.put('accessToken', 'gf3xVju03YKfK8ranQ1sHY745L2BzDIkL9qifa');
                
                // Convert the payload to JSON string
                String payloadJson = JSON.serialize(payload);
                return APIUtility.sendHttpRequest(endpointUrl, payloadJson);
        } catch (Exception e) {
            System.debug('--Error--'+e);
            return false;
        }
    }

    public class AccountChartData {
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public Integer count { get; set; }

        public AccountChartData(String label, Integer count) {
            this.label = label;
            this.count = count;
        }
    }
}