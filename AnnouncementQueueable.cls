/**
 * @name AnnouncementQueueable
 * @description This class posts Chatter Announcements
**/
public class AnnouncementQueueable implements System.Queueable{

    public List<ConnectApi.AnnouncementInput> toPost;
    public AnnouncementQueueable(List<ConnectApi.AnnouncementInput> toPost){
        this.toPost = toPost;
    }

    public void execute(QueueableContext context){
        PostAnnouncements(toPost);
    }
    
    /**
     * @name postAnnouncements
     * @description This method is provided for you to facilitate the Super Badge
    **/

    public static void PostAnnouncements(List<ConnectApi.AnnouncementInput> announcements){
        while ( announcements.size() > 0 ){
            if ( Limits.getDMLStatements() < Limits.getLimitDMLStatements() && !test.isRunningTest() ){
                ConnectApi.AnnouncementInput a = announcements.remove(0);
                ConnectApi.Announcements.postAnnouncement('Internal', a);
            } else {
                AnnouncementQueueable announcementQueuable 
                    = new AnnouncementQueueable(announcements);
                System.enqueueJob(announcementQueuable);
                break;
            }
        }

        if ( announcements.size() > 0 && !test.isRunningTest() ){
            AnnouncementQueueable q = 
                new AnnouncementQueueable(announcements);
            System.enqueueJob(q);
        }
    }

}
