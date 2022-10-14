@isTest
global class GeocodeMockTester implements HttpCalloutMock {
    private Integer statusCode;
    private Boolean badJSON;

    global GeocodeMockTester (Integer statusCode, Boolean badJSON) {
        this.statusCode = statusCode;
        this.badJSON = badJSON;
    }

    global HttpResponse respond (HttpRequest request) {

        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(this.statusCode);

        if (this.badJSON)
            response.setBody('{"badKey":"BadValue"}');
        else {
            GeocodeAddress.AuthenticationResponse body = new GeocodeAddress.AuthenticationResponse();
            body.status = 'OK';
            body.externalId = 'externalId';
            response.setBody(JSON.serialize(body));
        }

        return response;
    }
}