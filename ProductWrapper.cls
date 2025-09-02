public class ProductWrapper {
    
    public product2 productRecord{get;set;}
    public pricebookEntry pricebookEntryRecord{get;set;}
    
    public productWrapper(){
    	productRecord = new product2 (Initial_Inventory__c = 0);
        pricebookEntryRecord = new PricebookEntry(Unitprice = 0.0);
    }
}
