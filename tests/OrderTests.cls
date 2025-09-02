@isTest

public class OrderTests {
    @testSetup
    
    public static void SetupTestData(){
        TestDataFactory.InsertTestData(5);
    }
    
    static testmethod void OrderUpdate_UnitTest(){
        Test.startTest();
        
        Order rec = [SELECT Id, Status FROM Order LIMIT 1];
        Product2 prod = [SELECT Family, Id, Name, Quantity_Ordered__c, Quantity_Remaining__c FROM Product2 LIMIT 1];
        
        System.debug('###' + prod.Quantity_Ordered__c);
        
        rec.Status = Constants.ACTIVATED_ORDER_STATUS;
        
        Update rec;
        
        Product2 updateprod = [SELECT Family, Id, Name, Quantity_Ordered__c, Quantity_Remaining__c FROM Product2 LIMIT 1];
        
        System.debug('###' + updateprod.Quantity_Ordered__c);
        
        TestDataFactory.VerifyQuantityOrdered(prod,updateprod,Constants.DEFAULT_ROWS);
        
        Test.stopTest();
        
    }
}
