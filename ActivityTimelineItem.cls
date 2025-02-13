public with sharing class ActivityTimelineItem implements Comparable {

    @AuraEnabled
    public Id id { get; set; }
    @AuraEnabled
    public String type { get; set; }
    @AuraEnabled
    public Datetime activityDate { get; set; }
    @AuraEnabled
    public String subject { get; set; }
    @AuraEnabled
    public String description { get; set; }
    @AuraEnabled
    public String icon { get; set; }
    @AuraEnabled
    public Boolean upcoming { get; set; }
    @AuraEnabled
    public Boolean overdue { get; set; }
    @AuraEnabled
    public Boolean dateHasTime { get; set; }
    @AuraEnabled
    public String groupableMonth { get; set; }

    public ActivityTimelineItem(SObject sObj, Activity_Timeline__mdt metadata) {
        this.id = (Id) sObj.get('Id');
        this.type = ObjectHelper.getObjectNameByRecordId(this.id);
        this.activityDate = (Datetime) sObj.get(metadata.Activity_Date_API_Name__c);
        this.subject = getSubject(sObj, metadata);
        this.description = getDescription(sObj, metadata);
        this.icon = getIcon(sObj, metadata);
        this.upcoming = this.activityDate > Datetime.now();
        this.overdue = !this.upcoming && notCompletedTask(sObj);
        this.dateHasTime = ObjectHelper.getType(sObj.get(metadata.Activity_Date_API_Name__c)) == 'Datetime';
        this.groupableMonth = this.activityDate?.format('MMM yyyy');
    }

    private String getSubject(SObject sObj, Activity_Timeline__mdt metadata) {
        String subject = '';

        if (sObj.get(metadata.Subject_API_Name__c) != null) {
            subject += (String) sObj.get(metadata.Subject_API_Name__c);
        }
        if (String.isNotBlank(metadata.Fallback_Subject_API_Name__c) && sObj.get(metadata.Fallback_Subject_API_Name__c) != null) {
            if (String.isBlank(subject)) {
                subject += (String) sObj.get(metadata.Fallback_Subject_API_Name__c);
            }
            else {
                subject += ' - ' + (String) sObj.get(metadata.Fallback_Subject_API_Name__c);
            }
        }

        return String.isBlank(subject) ? '-' : subject;
    }

    private String getDescription(SObject sObj, Activity_Timeline__mdt metadata) {
        if (String.isNotBlank(metadata.Description_API_Name__c) && sObj.get(metadata.Description_API_Name__c) != null) {
            return (String) sObj.get(metadata.Description_API_Name__c);
        }
        return '';
    }

    private String getIcon(SObject sObj, Activity_Timeline__mdt metadata) {
        if (sObj instanceof Task) {
            Task task = (Task) sObj;
            List<String> taskIcons = metadata.Icon__c.split(',');
            return task.TaskSubtype == 'Call' ? taskIcons.get(1) : taskIcons.get(0);
        }
        else {
            return metadata.Icon__c;
        }
    }

    // private Boolean notCompletedTask(SObject sObj) {
    //     return sObj instanceof Task && ((Task) sObj).Status != 'Completed' && ((Task) sObj).Status != 'Genomförd';
    // }

    public Integer compareTo(Object obj) {
        Datetime activityDate = ((ActivityTimelineItem) obj).activityDate;
        if (this.activityDate < activityDate) return 1;
        if (this.activityDate > activityDate) return -1;
        return 0;
    }
}
