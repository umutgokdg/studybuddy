namespace StudyBuddySAP.Models.GroupModels
{
    public class GroupAddModel
    {
        public string Title { get; set; }
        public string Subject { get; set; }
        public List<string>? Resources { get; set; }
        public string CreatedBy { get; set; }
        public List<string> MemberUsers { get; set; }
        public List<string>? Tasks { get; set; }
    }
}
