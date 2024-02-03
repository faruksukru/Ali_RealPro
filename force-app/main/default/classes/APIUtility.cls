public without sharing class APIUtility {

    public static Boolean sendHttpRequest(String endpoint, String payloadJson) {
        String endpointUrl = endpoint; 
        
        // Create the HTTP request
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpointUrl);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(payloadJson);
        
        // Send the HTTP request
        Http http = new Http();
        HttpResponse response = http.send(request);
        
        // Process the HTTP response
        if (response.getStatusCode() == 200) {
            // Request successful, do something with the response
            System.debug('HTTP request successful. Response: ' + response.getBody());
            return true;
        } else {
            // Request failed, handle the error
            System.debug('HTTP request failed. Status code: ' + response.getStatusCode());
            System.debug('Error message: ' + response.getBody());
            return false;
        }
    }
}