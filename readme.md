![BSD 3-Clause License](https://img.shields.io/badge/license-BSD%203--Clause-success)
![Status](https://img.shields.io/badge/status-Complete-green)
![Geography](https://img.shields.io/badge/Geography-US-blue)

<h1 align="center">PointInPolygon Lead Trigger</h1>
<p align="center">This package contains an apex trigger and class that determines which Salesforce Maps layer that a given address resides in. The name of the SF Maps layer is stored in a custom field on the lead object called inLayer__c.  This package uses 2 methods from <a href="https://developer.salesforce.com/docs/atlas.en-us.maps_developer_guide.meta/maps_developer_guide/maps_apex_pointinpolygon.htm">this SF Maps developer documentation</a> to do so.  The SF Maps API Geocode method converts an address field into Lat/long and the PointInPolygon method determines the layer containing those coordinates. </p>

<!-- Sections below are Optional -->

---

## Summary

The original purpose of this component was to replace an inefficient piece of apex code that cycled through a set of hard coded ESRI layers.  This improved solution allows for the dynamic addition of new layers in Salesforce Maps, modification of existing layers, and deletion of layers all without having to modify the code.  By using a custom setting in Salesforce to store the folder name, users only have to modify a single value in Salesforce to point this code towards any Salesforce Maps layer folder.

![Map View](images/map_view.png)

The Apex mapping function is then embedded into a flow button that can be placed directly on the record page that you will call the action from, and then utilizes the <a href="https://unofficialsf.com/new-ways-to-open-web-pages-from-flow/">UnofficialSF OpenURL flow component</a> to open the layer in Salesforce Maps.

## Code Setup Instructions

Since this component relies heavily on the specific data model being used by the Salesforce org, some modification to the SOQL queries will be required in order to get this component working in your org.

First, ensure that the object you want to map (in this case inventory__c) is already defined in Salesforce Maps with a base object and both lat and long fields to store the geolocation.  This ensures that our inventory warehouse records can actually be read and mapped by the SF Maps application.

Next we want to determine what types of records we are looking for (line 21 of the apex class).  In this case, we queried each of the order line items off of the current sales order and stored them in a separate list.

```
List<PBSI__PBSI_Sales_Order_Line__c> salesorderlinelist = [SELECT Id, PBSI__Item__c,PBSI__Item__r.Name, PBSI__Quantity_Needed__c FROM PBSI__PBSI_Sales_Order_Line__c where PBSI__Sales_Order__c =: currentId];
```

Now that we have our line items, we can run another query to select all of the locations that have those items in stock (lines 25-30).  In our example, we iterate through all of the sales order lines, select the Inventory__c records where that item is in stock, and then add them to another list.

```
List<List<PBSI__PBSI_Inventory__c>> ilist = new List<List<PBSI__PBSI_Inventory__c>>();
            //iterate through salesorderlinelist
            for(PBSI__PBSI_Sales_Order_Line__c salesorderline:salesorderlinelist){
            	List<PBSI__PBSI_Inventory__c> myilist = [SELECT PBSI__qty__c, PBSI__location_lookup__c, PBSI__location_lookup__r.Name FROM PBSI__PBSI_Inventory__c WHERE PBSI__item_lookup__c =: salesorderline.PBSI__Item__c AND PBSI__qty__c > 0];
            	ilist.add(myilist);
            }
```

The rest of the code is essentially grabbing the base URL of the org, appending all of the records, and then defining other parameters like tooltips, the marker color, and the zoom level of the map when it loads (Line 54). Again, for more clarification on the syntax of building a Mapping URL, please see <a href="https://help.salesforce.com/s/articleView?id=000354507&type=1">this Salesforce Maps documentation</a>.

```
baseURL = baseURL+'&baseObjectId=a2E8Z0000077EolUAE&tooltipField=PBSI__location_lookup__r.Name&tooltipField2=PBSI__item_lookup__c&tooltipField3=PBSI__Description__c&tooltipField4=PBSI__qty__c&zoom=8&color='+color;
```

Now that our URL is built and returned at the end of the code, we can configure a basic flow to call our class and open the URL.



## Maintainer

Jack Galletta, Public Sector Solution Engineer

Please feel free to Slack me with any questions about setup, configuration, or general improvements to the project.
