@isTest
public class BusinessHoursControllerTest {
    
    @isTest
    static void testReturnsTrueDuringTest() {
        Test.startTest();
        List<BusinessHoursController.BusinessHoursOutput> results = BusinessHoursController.checkBusinessHours();
        Test.stopTest();

        System.assertEquals(1, results.size());
        System.assertEquals(true, results[0].isWithinBusinessHours);
        System.assertEquals('It\'s business hours.', results[0].strMessage);
    }
}