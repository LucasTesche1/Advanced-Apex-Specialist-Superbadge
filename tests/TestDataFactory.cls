/**
 * @name TestDataFactory
 * @description Contains methods to construct and/or validate commonly used records
**/
public with sharing class TestDataFactory {

    /**
     * @name ConstructCollaborationGroup
     * @description
    **/
    public static CollaborationGroup ConstructCollaborationGroup(){
        //ToDo: Ensure this method returns a single Chatter CollaborationGroup
        //    whose Name starts with 'TEST' followed by the INVENTORY_ANNOUNCEMENTS constant
        //    and configured so anyone can join, see and post updates.
        CollaborationGroup ChatterGroup = new CollaborationGroup(
              Name = 'TEST'+Constants.INVENTORY_ANNOUNCEMENTS,  
              CollaborationType = 'Public',
              IsArchived = false,
              IsAutoArchiveDisabled = true
        );
        return ChatterGroup;
    }

    /**
     * @name CreateProducts
     * @description Constructs a list of Product2 records for unit tests
    **/
    public static list<Product2> ConstructProducts(Integer cnt){
        //ToDo: Ensure this method returns a list, of size cnt, of uniquely named Product2 records
        //  with all the required fields populated
        //  and IsActive = true
        //  an Initial Inventory set to 10
        //  and iterating through the product family picklist values throughout the list.
        list<Product2> products=new list<Product2>();
        list<Schema.PicklistEntry> pEntries = Constants.PRODUCT_FAMILY;
        Integer pVal = 0;
        for(Integer i=0;i<cnt;i++){
            Product2 pd2=new Product2();
            pd2.Name='Product-'+i;
            pd2.IsActive = true;
            pd2.Initial_Inventory__c = 10;
            if(pVal == 4){
                pVal = 0;
            }
            pd2.Family = pEntries.get(pVal).getValue();
            pVal++;
            products.add(pd2);
        }
        return products;
    }

    /**
     * @name CreatePricebookEntries
     * @description Constructs a list of PricebookEntry records for unit tests
    **/
    public static list<PriceBookEntry> ConstructPricebookEntries(List<Product2> prods){
        //ToDo: Ensure this method returns a corresponding list of PricebookEntries records
        //  related to the provided Products
        //  with all the required fields populated
        //  and IsActive = true
        //  and belonging to the standard Pricebook
        list<PriceBookEntry> entries=new list<PriceBookEntry>();
        for(Product2 pd2: prods){
            PriceBookEntry pbe=new PriceBookEntry();
            pbe.isActive = true;
            pbe.UnitPrice = 100;
            pbe.Product2Id = pd2.id;
            pbe.PriceBook2Id = Constants.STANDARD_PRICEBOOK_ID;
            entries.add(pbe);
        }
        return entries;
    }

    /**
     * @name CreateAccounts
     * @description Constructs a list of Account records for unit tests
    **/
    public static list<Account> ConstructAccounts(Integer cnt){
        //ToDo: Ensure this method returns a list of size cnt of uniquely named Account records
        //  with all of the required fields populated.
        list<Account> accounts=new list<Account>();
        for(Integer i=0;i<cnt;i++){
            Account ac=new Account();
            ac.Name = 'Account'+i;
            accounts.add(ac);
        }
        return accounts;
    }

    /**
     * @name CreateContacts
     * @description Constructs a list of Contacxt records for unit tests
    **/
    public static list<Contact> ConstructContacts(Integer cnt, List<Account> accts){
        //ToDo: Ensure this method returns a list, of size cnt, of uniquely named Contact records
        //  related to the provided Accounts
        //  with all of the required fields populated.
        list<Contact> conts=new list<Contact>();
        for(Integer i=0;i<cnt;i++){
            contact con=new contact();
            con.LastName = 'Contact'+i;
            con.AccountId = accts.get(i).id;
            conts.add(con);
        }
        return conts;
    }

    /**
     * @name CreateOrders
     * @description Constructs a list of Order records for unit tests
    **/
    public static list<Order> ConstructOrders(Integer cnt, List<Account> accts){
        //ToDo: Ensure this method returns a list of size cnt of uniquely named Order records
        //  related to the provided Accounts
        //  with all of the required fields populated.
        list<Order> orders=new list<Order>();
        for(Integer i=0;i<cnt;i++){
            Order ord=new Order();
            ord.Name = 'Order'+i;
            ord.AccountId = accts.get(i).Id;
            ord.EffectiveDate = Date.Today();
            ord.Status = Constants.DRAFT_ORDER_STATUS;
            ord.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;
            orders.add(ord);
            
        }
        return orders;
    }

    /**
     * @name CreateOrderItems
     * @description Constructs a list of OrderItem records for unit tests
    **/
    public static list<OrderItem> ConstructOrderItems(integer cnt, list<pricebookentry> pbes, list<order> ords){
        //ToDo: Ensure this method returns a list of size cnt of OrderItem records
        //  related to the provided Pricebook Entries
        //  and related to the provided Orders
        //  with all of the required fields populated.
        //  Hint: Use the DEFAULT_ROWS constant for Quantity as it will be used in the next challenge
        list<OrderItem> orderItems=new list<OrderItem>();
        
        for(Integer i=0;i<cnt;i++){
            OrderItem oItem=new OrderItem();
            oItem.OrderId = ords.get(i).Id;
            oItem.PriceBookEntryId = pbes.get(i).Id;
            oItem.Quantity = Constants.DEFAULT_ROWS;
            oItem.UnitPrice = 10;
            orderItems.add(oItem);
        }
        return orderItems;
    }

    /**
     * @name SetupTestData
     * @description Inserts accounts, contacts, Products, PricebookEntries, Orders, and OrderItems.
    **/
    public static void InsertTestData(Integer cnt){
        //ToDo: Ensure this method calls each of the construct methods
        //  and inserts the results for use as test data.
         list<Account> accounts = ConstructAccounts(cnt);
        Insert accounts;
        
        list<Contact> contacts = ConstructContacts(cnt, accounts);
        insert contacts;
        
        list<Product2> prods= ConstructProducts(cnt);
        insert prods;
        
        list<PriceBookEntry> entries = ConstructPricebookEntries(prods);
        insert entries;
        
        list<Order> orders = ConstructOrders(cnt, accounts);
        insert orders;
        
        list<OrderItem> ordItems = ConstructOrderItems(cnt, entries, orders);
        insert ordItems;

    }

public static void VerifyQuantityOrdered(Product2 originalProduct, Product2 updatedProduct, Integer qtyOrdered){
        system.AssertEquals(updatedProduct.Quantity_Ordered__c,originalProduct.Quantity_Ordered__c  +qtyOrdered);
   
 }  

}
