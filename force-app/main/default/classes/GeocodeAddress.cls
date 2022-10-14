global class GeocodeAddress {
    @future (callout = true)
    public static void ConvertAddress(string Address, String LeadId){
        Map<string,object> options = new Map<String,Object> {
        'version' => '1', // Required. Version of the API endpoint. Must be '1'.
            'address' => Address
            };
                
        // Call the Geocode() method with the address.
        Map<String, Object> response = maps.API.Geocode(options);
    
        // Log the resulting geographical coordinates and formatted address. 
        Object myData = response.get('data');
        system.debug(myData);
        if(myData == null){
            system.debug('bad address data');
            Lead leadToUpdate = [SELECT Id, LastName FROM Lead WHERE ID =: LeadId];
            system.debug(leadtoUpdate.LastName);
            leadToUpdate.inLayer__c = 'BAD DATA';
            update leadToUpdate;
            return;
        }
        String dataString = myData.toString();
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
        for (maps__ShapeLayer__c sl : [SELECT Id FROM maps__ShapeLayer__c WHERE maps__Folder__r.Name = 'JGTestFolder']) {
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
        Map<String,Object> responselayer = maps.Api.PointInPolygon(request);
        system.debug('made it past PIP');

        String responseString = responselayer.get('results').toString();
      	system.debug(responseString);
        Pattern r2 = Pattern.compile('polygons=\\((.*)-0\\)\\}');
        Matcher m2 = r2.matcher(responseString);
        if(m2.find()){
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
        }
        
        
        return;
    }
}
