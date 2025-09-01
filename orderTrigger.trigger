trigger orderTrigger on Order (after Update) 
{
    OrderHelper.AfterUpdate(Trigger.new,Trigger.old);
}
