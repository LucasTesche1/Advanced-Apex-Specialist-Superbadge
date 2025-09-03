/**
 * @name OrderExtension
 * @description This class is provided for you to facilitate the Super Badge
**/
public class OrderExtension {

    public Order orderRecord {get;set;}
    public List<OrderItem> orderItemList {get;set;}
    public String selectedFamily {get;set;}
    public List<chartHelper.chartData> pieData {get;set;}
    public Decimal total {get;set;}
    public Map<Id,OrderItem> orderItemMap;
    ApexPages.StandardSetController standardSetController;

    public OrderExtension(ApexPages.StandardController standardController){
        orderRecord = (Order)standardController.getRecord();
        orderItemMap = new Map<id,OrderItem>();
        if ( orderRecord.Id != null ){
            orderRecord = queryOrderRecord(orderRecord.Id);
        }
        resetSsc();
        total = 0;
        
        for(OrderItem oi : orderRecord.OrderItems){
            orderItemMap.put(oi.Product2Id, oi);
            if(oi.Quantity > 0){
                if(null == pieData){
                    pieData = new List<ChartHelper.ChartData>();
                }
                pieData.add(new chartHelper.ChartData(oi.Product2.Name,oi.Quantity * oi.UnitPrice));
                total += oi.UnitPrice * oi.Quantity;
            }
        }
        PopulateOrderItems();
    }
    void resetSsc(){
        String query = 'SELECT Name, Product2.Family, Product2.Name, Product2Id, UnitPrice, Product2.Quantity_Remaining__c' + ' FROM PricebookEntry WHERE isActive = TRUE';
        
        if(selectedFamily != null && selectedFamily != Constants.SELECT_ONE){
            query += ' AND Product2.Family = \'' + selectedFamily + '\'';
        }
        query += ' ORDER BY Name';
        standardSetController = new ApexPages.StandardSetController(Database.getQueryLocator(query));
        standardSetController.setPageSize(Constants.DEFAULT_ROWS);
    }
    //ToDo: Implement your own method to populate orderItemList
    //  that you will call after pagination and/or family selection
    void PopulateOrderItems(){
        orderItemList = new List <OrderItem>();
        for(SObject obj : standardSetController.getRecords()){
            PricebookEntry pbe = (PricebookEntry)obj;
            
            if(orderItemMap.containsKey(pbe.Product2Id)) {
                orderItemList.add(orderItemMap.get(pbe.Product2Id));
                
            }else{
                orderItemList.add(new OrderItem(
                    PricebookEntryId=pbe.Id,
                    Product2Id=pbe.Product2Id,
                    UnitPrice=pbe.UnitPrice,
                    Quantity=0,
                    Product2=pbe.Product2
                ));
            }
        }
    }

    /**
     * @name OnFieldChange
     * @description
    **/
    public void OnFieldChange(){
        //ToDo: Implement logic to store the values changed on the page
        for(OrderItem oi : orderItemList){
            orderItemMap.put(oi.Product2Id, oi);
        }
        //      and populate pieData
        pieData = null;
        total = 0;
        for(OrderItem oi : orderItemMap.values()){
            if(oi.Quantity > 0){
                if(null == pieData){
                    pieData = new List<chartHelper.ChartData>();
                }
                pieData.add(new chartHelper.ChartData(oi.Product2.Name, oi.Quantity * oi.UnitPrice));
                //      and populate total
                total += oi.UnitPrice * oi.Quantity;
            }
        }
    }

    /**
     * @name SelectFamily
     * @description
    **/
    public void SelectFamily(){
        //ToDo: Implement logic to filter based on the selected product family
        resetSsc();
        PopulateOrderItems();
    }

    /**
     * @name Save
     * @description
    **/
    public void Save(){
        //ToDo: Implement logic to save the Order and populated OrderItems
		System.Savepoint sp = Database.setSavepoint();
        try{
            if(null == orderRecord.Pricebook2Id){
                orderRecord.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;
            }
            upsert orderRecord;
            
            List<OrderItem> orderItemsToUpsert = new List<OrderItem>();
			List<OrderItem> orderItemsToDelete = new List<OrderItem>();       
            
            for(OrderItem oi : orderItemList){
                if(oi.Quantity > 0){
                    if(null == oi.OrderId){
                        oi.OrderId = orderRecord.Id;
                    }
                    orderItemsToUpsert.add(oi);
                }else if (oi.Id != null){
                    orderItemsToDelete.add(oi);
                }
            }
            upsert orderItemsToUpsert;
            delete orderItemsToDelete;
            
        }catch (Exception e) {
            Database.rollback(sp);
            apexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,Constants.ERROR_MESSAGE));
        }
    }


    /**
     * @name First
     * @description
    **/
    public void First(){
        standardSetController.first();
        PopulateOrderItems();

    }


    /**
     * @name Next
     * @description
    **/
    public void Next(){
        standardSetController.next();
        PopulateOrderItems();
    }


    /**
     * @name Previous
     * @description
    **/
    public void Previous(){
        standardSetController.previous();
        PopulateOrderItems();
    }

    /**
     * @name Last
     * @description
    **/
    public void Last(){
        standardSetController.last();
        PopulateOrderItems();
    }

    /**
     * @name GetHasPrevious
     * @description
    **/
    public Boolean GetHasPrevious(){
        return standardSetController.getHasPrevious();
    }

    /**
     * @name GetHasNext
     * @description
    **/
    public Boolean GetHasNext(){
        return standardSetController.getHasNext();
    }

    /**
     * @name GetTotalPages
     * @description
    **/
    public Integer GetTotalPages(){
        return (Integer)Math.ceil(standardSetController.getResultSize() / (Decimal)Constants.DEFAULT_ROWS);
    }

    /**
     * @name GetPageNumber
     * @description
    **/
    public Integer GetPageNumber(){
        return standardSetController.getPageNumber();
    }

    /**
     * @name GetFamilyOptions
     * @description
    **/
    public List<SelectOption> GetFamilyOptions(){
        List<SelectOption> options = new List<SelectOption>{
            new SelectOption(Constants.SELECT_ONE, Constants.SELECT_ONE)
        };
                    for (Schema.PicklistEntry ple : Constants.PRODUCT_FAMILY) {
                        options.add(new SelectOption(ple.getValue(), ple.getLabel()));
                    }
        return options;
    }

    /**
     * @name QueryOrderRecord
     * @description
    **/
    public static Order QueryOrderRecord(Id orderId){
        return [
            SELECT Id, AccountId, EffectiveDate, Name, Status, Pricebook2Id,
            (
                SELECT Id, OrderId, Quantity, UnitPrice, PricebookEntryId, Product2Id,
                Product2.Name, Product2.Family, Product2.Quantity_Remaining__c
                FROM OrderItems
            )
            FROM Order
            WHERE Id = :orderId
        ];
    }

}
