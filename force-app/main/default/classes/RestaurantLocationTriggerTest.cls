@isTest
private class RestaurantLocationTriggerTest {
    


    @isTest
    static void testLiveDateSet() {
    	Restaurant_Location__c testLocation = new Restaurant_Location__c();
        testLocation.Name = 'Test Location 1';
        testLocation.Region__c = 'East';
        testLocation.Status__c = 'Active';
        insert testLocation;
        test.startTest();
        System.assertEquals(testLocation.Last_Visit_Date__c, Date.Today(), 'Last_Visit_Date__c should be set to Today');
        test.stopTest();
    }
}