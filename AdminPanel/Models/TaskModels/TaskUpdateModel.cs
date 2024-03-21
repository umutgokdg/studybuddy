namespace StudyBuddySAP.Models.TaskModels
{
    public class TaskUpdateModel
    {
        public string ObjectId { get; set; }
        public string TaskTitle { get; set; }
        public string TaskDescription { get; set; }
        public bool IsCompleted { get; set; }
        public DateTime CreatedAt { get; set; }
        public string CreatedBy { get; set; }
        public DateTime? DueAt { get; set; }
        public List<string>? UsersAssigned { get; set; }

    }
}
