@isTest (seeAllData=true)
private class Product2Tests {

    /**
     * @name product2Extension_UnitTest
     * @description UnitTest for product2Extension
    **/
    @isTest
    static void Product2Extension_UnitTest(){
        PageReference pageRef = Page.Product2New;
        Test.setCurrentPage(pageRef);
        
        Product2 prod = new Product2(Name = 'Test', isActive = true);
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(prod);
        Product2Extension ext = new Product2Extension(stdController);
        
        System.assertEquals(Constants.DEFAULT_ROWS, ext.productsToInsert.size());
        
        ext.AddRows();
        System.assertEquals(Constants.DEFAULT_ROWS * 2, ext.productsToInsert.size());
        
        for(Integer i = 0; i < 5; i++){
            Product2Extension.ProductWrapper wrapper = ext.productsToInsert[i];
            
            Product2 testProduct = new Product2();
            testProduct.Name = 'Test Product_' + i;
            testProduct.IsActive = true;
            testProduct.Initial_Inventory__c = 20;
            testProduct.Family = Constants.PRODUCT_FAMILY[0].getValue();
            wrapper.productRecord = testProduct;
            
            PricebookEntry testEntry = new PricebookEntry();
            testEntry.IsActive = true;
            testEntry.UnitPrice = 10;
            wrapper.pricebookEntryRecord = testEntry;
        }
        
        Test.startTest();
        ext.Save();
        Test.stopTest();
 
    	ext.GetFamilyOptions();
    	ext.GetInventory();
        
        List<Product2> createdProducts = [SELECT Id FROM Product2 WHERE Name LIKE : 'Test Product%'];
    	System.assertEquals(5, createdProducts.size());
    }

}
