//  GeocodeAddress Controller
//
//  Copyright (c) 2022, salesforce.com, inc.
//  All rights reserved.
//  SPDX-License-Identifier: BSD-3-Clause
//  For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//
//  Contact: j.galletta@salesforce.com

global class GeocodeAddress {
    public class AuthenticationResponse {
        public String status;
        public String externalId;
    }
    
    @future (callout = true)
    public static void ConvertAddress(string Address, String LeadId){
        Map<string,object> options = new Map<String,Object> {
        'version' => '1', // Required. Version of the API endpoint. Must be '1'.
            'address' => Address
            };
        String datastring;
        Object myData;
        if(!system.test.isRunningTest()){
            // Call the Geocode() method with the address.
            Map<String, Object> response = maps.API.Geocode(options);
        
            // Log the resulting geographical coordinates and formatted address. 
        	myData = response.get('data');
        }
        else{
           myData = '{city=Herndon, country=USA, fullAddress=717 Lynn St, Herndon, VA 20170, United States, houseNumber=717, matchLevel=Address, position={lat=38.96994, lng=-77.38584}, postal=20170, score=74, state=VA, street=Lynn St, ...}';
        }
        system.debug(myData);
        if(myData == null){
            system.debug('bad address data');
            Lead leadToUpdate = [SELECT Id, LastName FROM Lead WHERE ID =: LeadId];
            system.debug(leadtoUpdate.LastName);
            leadToUpdate.inLayer__c = 'BAD DATA';
            update leadToUpdate;
            return;
        }
        dataString = myData.toString();

        system.debug(dataString);

        Pattern r = Pattern.compile('position=\\{(.*)},');
        Matcher m = r.matcher(dataString);
        List<String> latlonglist = new List<String>();
        if(m.find()){
            String latlong = m.group(1);
            system.debug('latlong = ' +latlong);
            latlonglist = latlong.split(',');
            latlonglist[0] = latlonglist[0].substring(4);
            latlonglist[1] = latlonglist[1].substring(5);
            system.debug(latlonglist[0]);
            system.debug(latlonglist[1]);
        }
        else{
            system.debug('didnt find match');
        }
        
        //This section calls PointInPolygon to return the corresponding polygon that the address resides in
        List<Map<String, Object>> coordinateList = new List<Map<String, Object>> {
        new Map<String, Object> {
        'id' => LeadID,
        'lat' => latlonglist[0],
        'lng' => latlonglist[1]
        }
        };
        
        // Create a list of territory IDs.
        List<String> MATerritoryIds = new List<String>();
        SFMapsLayerFolder__c setting = [SELECT Folder_Name__c FROM SFMapsLayerFolder__c];
        for (maps__ShapeLayer__c sl : [SELECT Id FROM maps__ShapeLayer__c WHERE maps__Folder__r.Name =: setting.Folder_Name__c]) {
            MATerritoryIds.add(sl.Id);
        }
        
        // Build the request. Only version 2 is valid.
        Map<String, Object> request = new Map<String, Object> {
        'version' => '2',
        'points' => coordinateList,
        'MATerritoryIds' => MATerritoryIds
        };
        
        // Call the PointInPolygon() method.
        system.debug('made it here');
        String responseString;
        if(!system.test.isRunningTest()){
        Map<String,Object> responselayer = maps.Api.PointInPolygon(request);
        system.debug('made it past PIP');

        
        responseString= responselayer.get('results').toString();
        }
        else{
            responseString = '({point={id=00Q8G000001PhIJUA0, lat=38.96994, lng=-77.38584}, polygons=(a3d8G000000PJdDQAW-0)})';
        }
      	system.debug(responseString);
        Pattern r2 = Pattern.compile('polygons=\\((.*)-0\\)\\}');
        Matcher m2 = r2.matcher(responseString);
        if(m2.find()&& !System.test.isRunningTest()){
            String polygonId = m2.group(1);
            system.debug(polygonId);
            maps__ShapeLayer__c inLayer = [SELECT Id, Name FROM maps__ShapeLayer__c WHERE Id =: polygonId];
            system.debug(inLayer.Name);
            Lead leadToUpdate = [SELECT Id, LastName FROM Lead WHERE ID =: LeadId];
            system.debug(leadtoUpdate.LastName);
            leadToUpdate.inLayer__c = inLayer.Name;
            update leadToUpdate;
        }
        else{
            system.debug('didnt find match');
            Lead leadToUpdate = [SELECT Id, LastName FROM Lead WHERE ID =: LeadId];
            system.debug(leadtoUpdate.LastName);
            leadToUpdate.inLayer__c = 'NOT IN LAYER';
            update leadToUpdate;
        }
        
        
        return;
    }
}
