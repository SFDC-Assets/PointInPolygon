//  GeocodeAddress Mock Class
//
//  Copyright (c) 2022, salesforce.com, inc.
//  All rights reserved.
//  SPDX-License-Identifier: BSD-3-Clause
//  For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//
//  Contact: j.galletta@salesforce.com

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
