namespace StudyBuddySAP.Models.TaskModels
{
    public class TaskAddModel
    {
        public string Title { get; set; }
        public string Description { get; set; }
        public string CreatedBy { get; set; }
        public string? Group { get; set; }
        public DateTime Due { get; set; }
        public List<string> UsersAssigned { get; set; }

    }
}
