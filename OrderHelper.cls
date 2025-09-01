public without sharing class OrderHelper {

    //função que assiste a atualização do pedido e guarda seu ID
    public static void AfterUpdate(List<Order> newList, List<Order> oldList){
        Set<Id> orderIds = new Set<Id>();
        for ( Integer i=0; i< newList.size(); i++ ){
            if ( newList[i].Status == Constants.ACTIVATED_ORDER_STATUS && oldList[i].Status == Constants.DRAFT_ORDER_STATUS ){
                orderIds.add(newList[i].Id);
            }
        }
        RollUpOrderItems(orderIds);
    }
    //função que olha todos os pedidos, cria uma lista de products únicos e inicializa a quantidade em 0
    public static void RollUpOrderItems(Set<Id> activatedOrderIds){
        Map<Id, Product2> productMap = new Map<Id, Product2>(); 
        for(OrderItem orderLine : [SELECT Id, Product2Id, Product2.Quantity_Ordered__c, Quantity, Order.ActivatedDate
                                   FROM OrderItem WHERE OrderId IN : activatedOrderIds]){ 
              if(!productMap.containsKey(orderLine.Product2Id))
                  productMap.put(orderLine.Product2Id, new Product2(Id =orderLine.Product2Id, Quantity_Ordered__c=0)); 
        }
        //trecho que soma as quantidades
        for(AggregateResult ag : [SELECT Sum(Quantity), Product2Id FROM OrderItem WHERE Product2Id IN : productMap.keySet() Group By Product2Id]){
            Id product2Id = (Id)ag.get('Product2Id');
            Product2 prod = productMap.get(product2Id);
            prod.Quantity_Ordered__c = (Decimal)ag.get('expr0');
            productMap.put(product2Id , prod);
        }
        try { 
            if(productMap.values() != null && productMap.values().size() > 0){ 
                update productMap.values(); 
            } 
        }catch ( Exception e ){ 
            System.debug('#### Exception Executed : '+e.getStackTraceString()); 
        }
    }
    
}
