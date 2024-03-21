namespace StudyBuddySAP.Models.GroupModels
{
    public class GroupUpdateModel
    {
        public string ObjectId { get; set; }
        public string Title { get; set; }
        public string Subject { get; set; }
        public List<string>? Resources { get; set; }
        public DateTime CreatedDate { get; set; }
        public string CreatedBy { get; set; }
        public List<string> MemberUsers { get; set; }
        public List<string>? InvitedUsers { get; set; }
        public List<string>? Tasks { get; set; }
    }
}
