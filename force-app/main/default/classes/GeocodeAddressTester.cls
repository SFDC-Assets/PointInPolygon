//  GeocodeAddress Tester
//
//  Copyright (c) 2022, salesforce.com, inc.
//  All rights reserved.
//  SPDX-License-Identifier: BSD-3-Clause
//  For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//
//  Contact: j.galletta@salesforce.com

@isTest
public class GeocodeAddressTester {
    /*@TestSetup
    static void makeData(){
        Lead a = new Lead (LastName = 'Test', 
                    Email = 'test@gmail.com',
                    mobilephone = '+1234567890',
                    Company = 'Test company', 
                    Street = '717 Lynn St',
                    City = 'Herndon',
                    State = 'VA',
                    PostalCode = '20170',
                    Country = 'US');
        //insert a;
    }*/
    @isTest(SeeAllData=true)static void TestSFAddr(){
        System.Test.startTest();
        System.Test.setMock(HttpCalloutMock.class, new GeocodeMockTester(200, false));
        //Lead a = [SELECT Id, Address, Company FROM Lead WHERE LastName = 'Test2'];
        //a.Company = 'hi';
        //update a;
        Lead a = new Lead (LastName = 'Test', 
                    Email = 'test@gmail.com',
                    mobilephone = '+1234567890',
                    Company = 'Test company', 
                    Street = '717 Lynn St',
                    City = 'Herndon',
                    State = 'VA',
                    PostalCode = '20170',
                    Country = 'US');
        insert a;
        //String address = a.Address.getStreet() + ', ' + a.Address.getCity() + ', '+a.Address.getState()+a.Address.getPostalCode()+a.Address.getCountry();
        //GeocodeAddress.ConvertAddress(address, a.Id);
        System.Test.stopTest();
    }
    @isTest(SeeAllData=true)static void TestNull(){
        System.Test.startTest();
        System.Test.setMock(HttpCalloutMock.class, new GeocodeMockTester(200, false));
        //Lead a = [SELECT Id, Address, Company FROM Lead WHERE LastName = 'Test2'];
        //a.Company = 'hi';
        //update a;
        Lead a = new Lead (LastName = 'Test', 
                    Email = 'test@gmail.com',
                    mobilephone = '+1234567890',
                    Company = 'Test company');
        insert a;
        //String address = a.Address.getStreet() + ', ' + a.Address.getCity() + ', '+a.Address.getState()+a.Address.getPostalCode()+a.Address.getCountry();
        //GeocodeAddress.ConvertAddress(address, a.Id);
        System.Test.stopTest();
    }
}
