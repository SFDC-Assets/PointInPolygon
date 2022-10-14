//  FindLayerFromLead Trigger
//
//  Copyright (c) 2022, salesforce.com, inc.
//  All rights reserved.
//  SPDX-License-Identifier: BSD-3-Clause
//  For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//
//  Contact: j.galletta@salesforce.com

trigger FindLayerFromLead on Lead (after insert, after update) { 
    if(!System.isFuture()){
    	Lead l = [SELECT Id, Address from Lead where Id = : trigger.new[0].id];
        if(l.Address !=null){
            //This section turns the address into a set of coordinates
            Address myAddr = l.Address;
            String fulladdress = myAddr.getStreet() + ', ' + myAddr.getCity() + ', '+myAddr.getState()+myAddr.getPostalCode()+myAddr.getCountry();
            String LeadID = l.Id;
            GeocodeAddress.ConvertAddress(fulladdress, LeadID);
        }
        else{
            system.debug('didnt run convert address');
            /*c.InLayer__c = 'ADDRESS REQUIRED TO FIND LAYER';
            update c;*/
        }
    }
}
